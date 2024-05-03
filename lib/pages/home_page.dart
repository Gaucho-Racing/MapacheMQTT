import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:mapache_mqtt/utils/alert_service.dart';
import 'package:mapache_mqtt/utils/logger.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mapache_mqtt/utils/config.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String connectionStatus = "Disconnected";
  Timer? pingTimer;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    initializeMqtt();
  }

  void onConnected() {
    log("Connected to MQTT server @ $mqttHost");
    setState(() {
      connectionStatus = "Connected";
    });
  }

  void onDisconnected() {
    log("Disconnected from MQTT server @ $mqttHost");
    setState(() {
      connectionStatus = "Disconnected";
    });
  }

  void onReconnecting() {
    log("Reconnecting to MQTT server @ $mqttHost");
    setState(() {
      connectionStatus = "Reconnecting";
    });
  }

  void onReconnected() {
    log("Reconnected to MQTT server @ $mqttHost");
    setState(() {
      connectionStatus = "Connected";
    });
  }

  Future<void> initializeMqtt() async {
    try {
      mqttClient = MqttServerClient.withPort(mqttHost, mqttUser, int.tryParse(mqttPort) ?? 1883);
      final connectMessage = MqttConnectMessage()
          .authenticateAs(mqttUser, mqttPassword)
          .withClientIdentifier("mapache_mqtt_${(1 + Random().nextInt(100))}")
          .startClean()
          .withWillQos(MqttQos.atMostOnce);
      mqttClient.connectionMessage = connectMessage;
      mqttClient.onConnected = onConnected;
      mqttClient.onDisconnected = onDisconnected;
      mqttClient.onAutoReconnect = onReconnecting;
      mqttClient.onAutoReconnected = onReconnected;
      await mqttClient.connect();

      mqttClient.resubscribeOnAutoReconnect = true;
      mqttClient.subscribe("#", MqttQos.atMostOnce);
      mqttClient.updates!.listen((List<MqttReceivedMessage<MqttMessage>>? c) {
        final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
        final String pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        log("[${c[0].topic}] $pt");

        if (c[0].topic == "meta/mapache_mqtt_ping") {
          final ping = DateTime.now().difference(DateTime.parse(pt)).inMilliseconds;
          log("Ping: $ping ms");
          setState(() {
            latency.add(ping);
          });
        }
      });

      initializePing();
    } catch(err) {
      log("Failed to connect to MQTT server: $err", LogLevel.error);
      AlertService.showErrorSnackbar(context, err.toString());
    }
  }

  void initializePing() {
    pingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      mqttClient.subscribe("meta", MqttQos.atMostOnce);
      mqttClient.publishMessage("meta/mapache_mqtt_ping", MqttQos.atMostOnce, MqttClientPayloadBuilder().addString(DateTime.now().toIso8601String()).payload!);
    });
  }

  @override
  void dispose() {
    super.dispose();
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
            const Text("MQTT"),
          ],
        ),
        centerTitle: false,
        actions: [
          Card(
            // color: Colors.greenAccent,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: [
                  Icon(Icons.circle, color: connectionStatus == "Connected" ? Colors.greenAccent : connectionStatus == "Disconnected" ? Colors.redAccent : Colors.amberAccent, size: 12),
                  const Padding(padding: EdgeInsets.all(4)),
                  Text(connectionStatus, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.all(4)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Row(
                  children: [
                    const Text("Latency:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),),
                    const Padding(padding: EdgeInsets.all(4)),
                    Text("${latency.last}ms", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.grey),),
                  ],
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}
