import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:mapache_mqtt/models/mobile_node.dart';
import 'package:mapache_mqtt/utils/alert_service.dart';
import 'package:mapache_mqtt/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:mapache_mqtt/utils/config.dart';
import 'package:mapache_mqtt/utils/theme.dart';
import 'package:mapache_mqtt/widgets/loading.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:typed_data/src/typed_buffer.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with AutomaticKeepAliveClientMixin<MapPage> {

  MapboxMapController? mapController;
  Location location = Location();

  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;

  @override
  bool get wantKeepAlive => true;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    getUserLocation();
    sensorListeners();
  }

  @override
  void dispose() {
    super.dispose();
    mobileNodeTimer?.cancel();
  }

  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;
  }

  Future<void> getUserLocation() async {
    location.enableBackgroundMode(enable: true);
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        AlertService.showErrorSnackbar(context, "Please enable location access while the app is in the background to use this app!");
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        AlertService.showErrorSnackbar(context, "Please enable location access while the app is in the background to use this app!");
        return;
      }
    }
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    location.onLocationChanged.listen((LocationData newPosition) {
      setState(() {
        currentPosition = newPosition;
      });
      mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(currentPosition!.latitude!, currentPosition!.longitude!), 16.0));
      log("Current location: ${currentPosition!.latitude}, ${currentPosition!.longitude}");
    });
  }

  void sensorListeners() {
    accelerometerEventStream().listen((AccelerometerEvent event) {
        // log("accelerometer: (${event.x}, ${event.y}, ${event.z})");
        setState(() {
          accelerometerX = event.x;
          accelerometerY = event.y;
          accelerometerZ = event.z;
        });
      },
      onError: (error) {},
      cancelOnError: false,
    );
    gyroscopeEventStream().listen((GyroscopeEvent event) {
      // log("gyroscope: (${event.x}, ${event.y}, ${event.z})");
      setState(() {
        gyroscopeX = event.x;
        gyroscopeY = event.y;
        gyroscopeZ = event.z;
      });
      },
      onError: (error) {},
      cancelOnError: false,
    );

    magnetometerEventStream().listen((MagnetometerEvent event) {
      // log("magnetometer: (${event.x}, ${event.y}, ${event.z})");
      setState(() {
        magnetometerX = event.x;
        magnetometerY = event.y;
        magnetometerZ = event.z;
      });
      },
      onError: (error) {},
      cancelOnError: false,
    );
  }

  void sendMobilePacket() {
    MobileNode node = MobileNode();
    node.latitude = currentPosition?.latitude ?? 0;
    node.longitude = currentPosition?.longitude ?? 0;
    node.altitude = currentPosition?.altitude ?? 0;
    node.speed = currentPosition?.speed ?? 0;
    node.accelerometerX = accelerometerX;
    node.accelerometerY = accelerometerY;
    node.accelerometerZ = accelerometerZ;
    node.gyroscopeX = gyroscopeX;
    node.gyroscopeY = gyroscopeY;
    node.gyroscopeZ = gyroscopeZ;
    node.magnetometerX = magnetometerX;
    node.magnetometerY = magnetometerY;
    node.magnetometerZ = magnetometerZ;
    node.millis = DateTime.now().millisecondsSinceEpoch;
    Uint8Buffer buffer = Uint8Buffer();
    buffer.addAll(node.toBytes());
    mqttClient.publishMessage("$carClass/$carID/$mobileNodeTopic", MqttQos.atMostOnce, buffer);
    setState(() {
      lastGpsUpdate = DateTime.now();
    });
  }

  void startPing() {
    setState(() => isSendingMobileNode = true);
    mobileNodeTimer = Timer.periodic(Duration(milliseconds: mobileNodeInterval), (timer) {
      sendMobilePacket();
    });
  }

  void stopPing() {
    setState(() => isSendingMobileNode = false);
    mobileNodeTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset("images/icons/mapache.png", height: 32,),
              const Padding(padding: EdgeInsets.all(4)),
              const Text("Mobile Node"),
            ],
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: SizedBox(
                  height: 300,
                  child: currentPosition != null ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: MapboxMap(
                      accessToken: MAPBOX_ACCESS_TOKEN,
                      styleString: MAPBOX_DARK_THEME,
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(currentPosition!.latitude!, currentPosition!.longitude!),
                        zoom: 14.0,
                      ),
                      attributionButtonMargins: const Point(-32, -32),
                      myLocationEnabled: true,
                      dragEnabled: false,
                      compassEnabled: false,
                      zoomGesturesEnabled: false,
                      logoViewMargins: const Point(-100, 0),
                      trackCameraPosition: true,
                    ),
                  ) : const Center(child: LoadingIndicator()),
                )
              ),
              const Padding(padding: EdgeInsets.all(8)),
              Row(
                children: [
                  const Text("Latitude:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                  const Padding(padding: EdgeInsets.all(4)),
                  Text("${currentPosition?.latitude}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey),),
                ],
              ),
              Row(
                children: [
                  const Text("Latency:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                  const Padding(padding: EdgeInsets.all(4)),
                  Text("${currentPosition?.longitude}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey),),
                ],
              ),
              Row(
                children: [
                  const Text("Altitude:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                  const Padding(padding: EdgeInsets.all(4)),
                  Text("${currentPosition?.altitude}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey),),
                ],
              ),
              Row(
                children: [
                  const Text("Speed:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                  const Padding(padding: EdgeInsets.all(4)),
                  Text("${currentPosition?.speed}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey),),
                ],
              ),
              Row(
                children: [
                  const Text("Last GPS Update:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                  const Padding(padding: EdgeInsets.all(4)),
                  Text(DateFormat("HH:mm:ss.SS").format(lastGpsUpdate.toLocal()), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey),),
                ],
              ),
              const Padding(padding: EdgeInsets.all(8)),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text("Sensor Debug", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),)),
                  ],
                ),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Accelerometer:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                      Text("$accelerometerX\n$accelerometerY\n$accelerometerZ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Gyroscope:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                      Text("$gyroscopeX\n$gyroscopeY\n$gyroscopeZ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Magnetometer:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                      Text("$magnetometerX\n$magnetometerY\n$magnetometerZ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),),
                    ],
                  ),
                ]
              ),
              const Padding(padding: EdgeInsets.all(8)),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  borderRadius: BorderRadius.circular(16),
                  color: isSendingMobileNode ? GR_PURPLE : Colors.black,
                  child: Text(isSendingMobileNode ? "Stop Sending" : "Start Sending", style: TextStyle(color: isSendingMobileNode ? Colors.white : GR_PURPLE),),
                  onPressed: () {
                    if (isSendingMobileNode) {
                      stopPing();
                    } else {
                      startPing();
                    }
                  },
                ),
              )
            ],
          ),
        )
    );
  }
}
