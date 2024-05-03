import 'dart:math';

import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mapache_mqtt/utils/alert_service.dart';
import 'package:mapache_mqtt/utils/config.dart';
import 'package:mapache_mqtt/utils/logger.dart';
import 'package:mapache_mqtt/utils/theme.dart';
import 'package:mapache_mqtt/widgets/loading.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool isLoading = false;

  String host = "";
  String port = "";
  String user = "";
  String password = "";

  TextEditingController hostController = TextEditingController();
  TextEditingController portController = TextEditingController();
  TextEditingController userController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  initState() {
    super.initState();
    checkSavedCredentials();
  }

  Future<void> login() async {
    if (user == "" || password == "" || host == "" || port == "") {
      AlertService.showErrorSnackbar(context, "Please make sure to fill out all the fields!");
      return;
    }
    setState(() => isLoading = true);
    try {
      mqttClient = MqttServerClient.withPort(host, user, int.tryParse(port) ?? 1883);
      final connectMessage = MqttConnectMessage()
          .authenticateAs(user, password)
          .withClientIdentifier("mapache_mqtt_${(1 + Random().nextInt(100))}")
          .startClean()
          .withWillQos(MqttQos.atMostOnce);
      mqttClient.connectionMessage = connectMessage;
      await mqttClient.connect();
      if (mqttClient.connectionStatus!.state == MqttConnectionState.connected) {
        log("Connected to MQTT server @ $host", LogLevel.info);
        mqttHost = host;
        mqttPort = port;
        mqttUser = user;
        mqttPassword = password;
        prefs.setString("mqtt_host", host);
        prefs.setString("mqtt_port", port);
        prefs.setString("mqtt_user", user);
        prefs.setString("mqtt_password", password);
        AlertService.showSuccessSnackbar(context, "Connected to MQTT server!");
        mqttClient.disconnect();
        router.navigateTo(context, "/home", transition: TransitionType.fadeIn, replace: true, clearStack: true);
      } else {
        log("Failed to connect to MQTT server", LogLevel.error);
        mqttClient.disconnect();
      }
    } catch(err) {
      log("Failed to connect to MQTT server: $err", LogLevel.error);
      AlertService.showErrorSnackbar(context, err.toString());
    }
    setState(() => isLoading = false);
  }

  Future<void> checkSavedCredentials() async {
    final savedHost = prefs.getString("mqtt_host");
    final savedPort = prefs.getString("mqtt_port");
    final savedUser = prefs.getString("mqtt_user");
    final savedPassword = prefs.getString("mqtt_password");
    if (savedHost != null && savedPort != null && savedUser != null && savedPassword != null) {
      hostController.text = savedHost;
      portController.text = savedPort;
      userController.text = savedUser;
      passwordController.text = savedPassword;
      host = savedHost;
      port = savedPort;
      user = savedUser;
      password = savedPassword;
      login();
    }
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text("Host", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                const Padding(padding: EdgeInsets.all(2)),
                Expanded(
                  child: TextField(
                    controller: hostController,
                    textAlign: TextAlign.end,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "mapache-mqtt.com",
                    ),
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    onChanged: (input) {
                      host = input;
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text("Port", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                const Padding(padding: EdgeInsets.all(2)),
                Expanded(
                  child: TextField(
                    controller: portController,
                    textAlign: TextAlign.end,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "1883",
                    ),
                    keyboardType: TextInputType.number,
                    autocorrect: false,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    onChanged: (input) {
                      port = input;
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text("User", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                const Padding(padding: EdgeInsets.all(2)),
                Expanded(
                  child: TextField(
                    controller: userController,
                    textAlign: TextAlign.end,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "admin",
                    ),
                    keyboardType: TextInputType.text,
                    autocorrect: false,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    onChanged: (input) {
                      user = input;
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text("Password", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                const Padding(padding: EdgeInsets.all(2)),
                Expanded(
                  child: TextField(
                    controller: passwordController,
                    textAlign: TextAlign.end,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "*******"
                    ),
                    textCapitalization: TextCapitalization.none,
                    obscureText: true,
                    keyboardType: TextInputType.text,
                    autocorrect: false,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    onChanged: (input) {
                      password = input;
                    },
                  ),
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.all(16.0)),
            SizedBox(
              height: 50.0,
              width: double.infinity,
              child: CupertinoButton(
                color: GR_PURPLE,
                borderRadius: BorderRadius.circular(16),
                onPressed: isLoading ? null : () {
                  login();
                },
                child: isLoading ? const LoadingIndicator() : const Text("Login", style: TextStyle()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
