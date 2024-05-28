import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:mapache_mqtt/pages/home/home_page.dart';
import 'package:mapache_mqtt/pages/settings/settings_page.dart';
import 'package:mapache_mqtt/utils/theme.dart';

import 'map/map_page.dart';

class TabBarController extends StatefulWidget {
  const TabBarController({super.key});

  @override
  State<TabBarController> createState() => _TabBarControllerState();
}

class _TabBarControllerState extends State<TabBarController> {

  PageController controller = PageController();
  int currTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        onPageChanged: (index) => setState(() => currTab = index),
        controller: controller,
        children: const [
          HomePage(),
          MapPage(),
          SettingsPage()
        ],
      ),
      bottomNavigationBar: SnakeNavigationBar.color(
        backgroundColor: Colors.black,
        behaviour: SnakeBarBehaviour.floating,
        snakeShape: SnakeShape.circle,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        padding: const EdgeInsets.only(left: 8, right: 8),
        snakeViewColor: GR_PURPLE,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[700],
        showUnselectedLabels: false,
        showSelectedLabels: false,
        currentIndex: currTab,
        onTap: (index) {
         controller.animateToPage(index, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.gps_fixed_rounded), label: 'Node'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}
