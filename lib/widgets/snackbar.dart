
import 'package:flutter/material.dart';

class CustomSnackBar {
  static void showError(BuildContext context, String message, GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  static void showSuccess(BuildContext context, String message, GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}