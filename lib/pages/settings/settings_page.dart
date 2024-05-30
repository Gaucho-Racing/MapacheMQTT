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
import 'package:mapache_mqtt/utils/theme.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
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
              const Text("Settings"),
            ],
          ),
          centerTitle: false,
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
                      enabled: false,
                      textAlign: TextAlign.end,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: mqttHost,
                      ),
                      keyboardType: TextInputType.url,
                      autocorrect: false,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
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
                      enabled: false,
                      textAlign: TextAlign.end,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: mqttPort,
                      ),
                      keyboardType: TextInputType.number,
                      autocorrect: false,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
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
                      enabled: false,
                      textAlign: TextAlign.end,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: mqttUser,
                      ),
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                  ),
                ],
              ),
              const Row(
                children: [
                  Text("Password", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                  Padding(padding: EdgeInsets.all(2)),
                  Expanded(
                    child: TextField(
                      enabled: false,
                      textAlign: TextAlign.end,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "*******"
                      ),
                      textCapitalization: TextCapitalization.none,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                  ),
                ],
              ),
              Divider(color: GR_PURPLE),
              Row(
                children: [
                  const Text("Car Class", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                  const Padding(padding: EdgeInsets.all(2)),
                  Expanded(
                    child: TextField(
                      controller: TextEditingController()..text = carClass,
                      textAlign: TextAlign.end,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "gr24"
                      ),
                      textCapitalization: TextCapitalization.none,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                      onChanged: (input) {
                        carClass = input;
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text("Car ID", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                  const Padding(padding: EdgeInsets.all(2)),
                  Expanded(
                    child: TextField(
                      controller: TextEditingController()..text = carID,
                      textAlign: TextAlign.end,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "main"
                      ),
                      textCapitalization: TextCapitalization.none,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                      onChanged: (input) {
                        carID = input;
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text("Mobile Topic", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                  const Padding(padding: EdgeInsets.all(2)),
                  Expanded(
                    child: TextField(
                      controller: TextEditingController()..text = mobileNodeTopic,
                      textAlign: TextAlign.end,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "mobile"
                      ),
                      textCapitalization: TextCapitalization.none,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                      onChanged: (input) {
                        mobileNodeTopic = input;
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text("Send Delay", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                  const Padding(padding: EdgeInsets.all(2)),
                  Expanded(
                    child: TextField(
                      controller: TextEditingController()..text = mobileNodeInterval.toString(),
                      textAlign: TextAlign.end,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "200"
                      ),
                      textCapitalization: TextCapitalization.none,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                      onChanged: (input) {
                        mobileNodeInterval = int.tryParse(input) ?? 200;
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text("Speed Calc Delay", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                  const Padding(padding: EdgeInsets.all(2)),
                  Expanded(
                    child: TextField(
                      controller: TextEditingController()..text = speedCalcInterval.toString(),
                      textAlign: TextAlign.end,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "500"
                      ),
                      textCapitalization: TextCapitalization.none,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                      onChanged: (input) {
                        speedCalcInterval = int.tryParse(input) ?? 500;
                        prefs.setInt("speedCalcInterval", speedCalcInterval);
                      },
                    ),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.all(8)),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  borderRadius: BorderRadius.circular(16),
                  color: GR_PURPLE,
                  child: const Text("Sign Out", style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    mqttClient.disconnect();
                    prefs.remove("mqtt_password");
                    router.navigateTo(context, "/", replace: true, clearStack: true, transition: TransitionType.fadeIn);
                  },
                ),
              )
            ],
          ),
        )
    );
  }
}
