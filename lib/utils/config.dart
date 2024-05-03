import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:mapache_mqtt/models/message.dart';
import 'package:mapache_mqtt/models/version.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

final router = FluroRouter();
final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

var httpClient = http.Client();

late SharedPreferences prefs;

Version appVersion = Version("1.0.0+1");

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