import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:mapache_mqtt/models/message.dart';
import 'package:mapache_mqtt/utils/alert_service.dart';
import 'package:mapache_mqtt/utils/logger.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mapache_mqtt/utils/config.dart';
import 'package:mapache_mqtt/utils/theme.dart';
import 'package:mapache_mqtt/widgets/loading.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  MapboxMapController? mapController;
  Location location = Location();

  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;

  Timer? pingTimer;
  bool isSending = false;

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
  }

  @override
  void dispose() {
    super.dispose();
    pingTimer?.cancel();
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
      double delta = calculateDistance(currentPosition?.latitude ?? 0, currentPosition?.longitude?? 0, newPosition.latitude!, newPosition.longitude!);
      log("Position update delta: ${delta}m");
      setState(() {
        currentPosition = newPosition;
      });
      mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(currentPosition!.latitude!, currentPosition!.longitude!), 16.0));
      log("Current location: ${currentPosition!.latitude}, ${currentPosition!.longitude}");
    });
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    double p = 0.017453292519943295;
    double a = 0.5 - cos((lat2 - lat1) * p)/2 + cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a)) * 1000;
  }

  void sendMobilePacket() {
    setState(() {
      lastGpsUpdate = DateTime.now();
    });
  }

  void startPing() {
    setState(() => isSending = true);
    pingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      sendMobilePacket();
    });
  }

  void stopPing() {
    setState(() => isSending = false);
    pingTimer?.cancel();
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
                  const Text("Last GPS Update:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                  const Padding(padding: EdgeInsets.all(4)),
                  Text(DateFormat("HH:mm:ss.SS").format(lastGpsUpdate.toLocal()), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey),),
                ],
              ),
              const Padding(padding: EdgeInsets.all(8)),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  borderRadius: BorderRadius.circular(16),
                  color: isSending ? GR_PURPLE : Colors.black,
                  child: Text(isSending ? "Stop Sending" : "Start Sending", style: TextStyle(color: isSending ? Colors.white : GR_PURPLE),),
                  onPressed: () {
                    if (isSending) {
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
