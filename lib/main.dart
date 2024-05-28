import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapache_mqtt/pages/auth/login_page.dart';
import 'package:mapache_mqtt/pages/home/home_page.dart';
import 'package:mapache_mqtt/pages/tab_bar_controller.dart';
import 'package:mapache_mqtt/utils/config.dart';
import 'package:mapache_mqtt/utils/logger.dart';
import 'package:mapache_mqtt/utils/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return const Scaffold(
        body: Center(
            child: Text("Unexpected error. See log for details.")));
  };

  await dotenv.load(fileName: ".env");
  MAPBOX_PUBLIC_TOKEN = dotenv.env['MAPBOX_PUBLIC_TOKEN']!;
  MAPBOX_ACCESS_TOKEN = dotenv.env['MAPBOX_ACCESS_TOKEN']!;

  prefs = await SharedPreferences.getInstance();

  log("MapacheMQTT v${appVersion.toString()} – ${appVersion.getVersionCode()}");

  // ROUTE DEFINITIONS
  router.define("/", handler: Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return const LoginPage();
  }));

  router.define("/home", handler: Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return const TabBarController();
  }));

  runApp(MaterialApp(
    title: "MapacheMQTT",
    initialRoute: "/",
    onGenerateRoute: router.generator,
    theme: darkTheme,
    darkTheme: darkTheme,
    debugShowCheckedModeBanner: false,
    navigatorObservers: [
      routeObserver,
    ],
  ),);
}