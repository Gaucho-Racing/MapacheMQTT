import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';

class AlertService {

  static showSuccessSnackbar(context, String message) {
    AnimatedSnackBar(
      mobileSnackBarPosition: MobileSnackBarPosition.bottom,
      desktopSnackBarPosition: DesktopSnackBarPosition.bottomRight,
      builder: (context) {
        return Card(
          color: Colors.greenAccent,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const Padding(padding: EdgeInsets.all(4)),
                Expanded(child: Text(message, style: const TextStyle(color: Colors.white),)),
              ],
            ),
          ),
        );
      },
    ).show(context);
  }

  static showInfoSnackbar(context, String message) {
    AnimatedSnackBar(
      mobileSnackBarPosition: MobileSnackBarPosition.bottom,
      desktopSnackBarPosition: DesktopSnackBarPosition.bottomRight,
      builder: (context) {
        return Card(
          color: Theme.of(context).cardColor,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.info_rounded, color: Colors.white),
                const Padding(padding: EdgeInsets.all(4)),
                Expanded(child: Text(message, style: const TextStyle(color: Colors.white),)),
              ],
            ),
          ),
        );
      },
    ).show(context);
  }

  static showErrorSnackbar(context, String message) {
    AnimatedSnackBar(
      mobileSnackBarPosition: MobileSnackBarPosition.bottom,
      desktopSnackBarPosition: DesktopSnackBarPosition.bottomRight,
      builder: (context) {
        return Card(
          color: Colors.redAccent,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.warning_rounded, color: Colors.white),
                const Padding(padding: EdgeInsets.all(4)),
                Expanded(child: Text(message, style: const TextStyle(color: Colors.white),)),
              ],
            ),
          ),
        );
      },
    ).show(context);
  }

}