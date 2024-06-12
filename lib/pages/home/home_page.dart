import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:mapache_mqtt/models/message.dart';
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

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin<HomePage> {

  String connectionStatus = "Disconnected";
  Timer? pingTimer;

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

  void signOut() {
    mqttClient.disconnect();
    prefs.remove("mqtt_password");
    router.navigateTo(context, "/", replace: true, clearStack: true, transition: TransitionType.fadeIn);
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
        final msg = Message(c![0].payload as MqttPublishMessage);
        log("[${msg.topic}] ${msg.bytes}");
        setState(() {
          lastMessage = msg;
        });
        if (!messageMap.containsKey(msg.topic)) {
          setState(() {
            messageMap[msg.topic] = [msg];
          });
        } else {
          setState(() {
            messageMap[msg.topic]!.add(msg);
          });
        }
        if (c[0].topic == "meta/mapache_mqtt_ping") {
          final ping = DateTime.now().difference(DateTime.parse(msg.messageString)).inMilliseconds;
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
      MqttClientConnectionStatus? status = mqttClient.connectionStatus;
      if (status?.state == MqttConnectionState.disconnected) {
        log("MQTT client disconnected. Attempting to reconnect...");
        mqttClient.connect();
      }
      mqttClient.publishMessage("meta/mapache_mqtt_ping", MqttQos.atMostOnce, MqttClientPayloadBuilder().addString(DateTime.now().toIso8601String()).payload!);
    });
  }

  List<Widget> getLatestMessagesForTopic(String topic) {
    List<Message> lastMessages = messageMap[topic] ?? [];
    lastMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (lastMessages.length > 5) {
      lastMessages = lastMessages.sublist(0, 5);
    }
    return lastMessages.map((msg) => Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(msg.stringContainsUnknownUnicode() ? msg.bytes : msg.messageString),
                Text(DateFormat("HH:mm:ss.SS").format(msg.timestamp.toLocal()), style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Text("${msg.message.payload.message.length} bytes", style: const TextStyle(color: Colors.grey)),
        ],
      ),
    )).toList();
  }

  double getAverageMessagesPerSecond() {
    List<Message> totalMessages = [];
    messageMap.values.forEach((m) {
      totalMessages.addAll(m);
    });
    int num = totalMessages.where((m) => DateTime.now().difference(m.timestamp.toLocal()).inSeconds < 5).length;
    return (num / 5);
  }

  double getAverageBytesPerSecond() {
    List<Message> totalMessages = [];
    messageMap.values.forEach((m) {
      totalMessages.addAll(m);
    });
    int num = totalMessages.where((m) => DateTime.now().difference(m.timestamp.toLocal()).inSeconds < 5).fold(0, (prev, m) => prev + m.message.payload.message.length);
    return (num / 5);
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
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                signOut();
              },
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
                const Text("Latency:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                const Padding(padding: EdgeInsets.all(4)),
                Text("${latency.last}ms", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey),),
              ],
            ),
            Row(
              children: [
                const Text("Last Message:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                const Padding(padding: EdgeInsets.all(4)),
                Text(DateFormat("HH:mm:ss.SS").format(lastMessage.timestamp.toLocal()), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey),),
              ],
            ),
            Row(
              children: [
                const Text("Avg msg/s:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                const Padding(padding: EdgeInsets.all(4)),
                Text("${getAverageMessagesPerSecond()} (${getAverageBytesPerSecond()} bytes)", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey),),
              ],
            ),
            const Padding(padding: EdgeInsets.all(8)),
            Column(
              children: messageMap.entries.map((e) => ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),)),
                    Text("${e.value.length} msg", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
                  ],
                ),
                children: getLatestMessagesForTopic(e.key),
              )).toList(),
            )
          ],
        ),
      )
    );
  }
}
