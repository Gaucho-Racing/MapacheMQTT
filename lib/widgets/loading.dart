import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mapache_mqtt/utils/theme.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(color: Colors.white)
    );
  }
}
