import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:mapache_mqtt/models/message.dart';
import 'package:mapache_mqtt/models/mobile_node.dart';
import 'package:mapache_mqtt/models/version.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

final router = FluroRouter();
final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

var httpClient = http.Client();

late SharedPreferences prefs;

Version appVersion = Version("1.5.3+1");

MqttClient mqttClient = MqttClient("", "");

String mqttHost = "";
String mqttPort = "";
String mqttUser = "";
String mqttPassword = "";

LocationData? currentPosition;

String MAPBOX_PUBLIC_TOKEN = "mapbox-public-token";
String MAPBOX_ACCESS_TOKEN = "mapbox-access-token";

List<int> latency = [0];
Map<String, List<Message>> messageMap = {};
Message lastMessage = Message(MqttPublishMessage());
int maxMessages = 100;

int mobileNodeInterval = 200;
String carClass = "gr24";
String carID = "test";
String mobileNodeTopic = "mobile";

int speedCalcInterval = 500;
Timer? mobileNodeTimer;
bool isSendingMobileNode = false;

DateTime lastGpsUpdate = DateTime.now();
double accelerometerX = 0.0;
double accelerometerY = 0.0;
double accelerometerZ = 0.0;
double gyroscopeX = 0.0;
double gyroscopeY = 0.0;
double gyroscopeZ = 0.0;
double magnetometerX = 0.0;
double magnetometerY = 0.0;
double magnetometerZ = 0.0;

double mbLatitude = 0.0;
double mbLongitude = 0.0;
double mbHeading = 0.0;
double speed = 0.0;
