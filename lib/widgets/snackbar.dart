import 'package:flutter/material.dart';

class CustomSnackBar {

  static showError(BuildContext context, String message,var scaffoldMessengerKey) {
    
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}