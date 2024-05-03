import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
        actions: const [
          Card(
            // color: Colors.greenAccent,
            child: Padding(
              padding: EdgeInsets.all(4.0),
              child: Row(
                children: [
                  Icon(Icons.circle, color: Colors.greenAccent, size: 12),
                  Padding(padding: EdgeInsets.all(4)),
                  Text("Connected", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          Padding(padding: EdgeInsets.all(4)),
        ],
      ),
    );
  }
}
