import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../authentication/auth.dart';

class HomeScreenModel {
  final AuthService _auth = AuthService();

  Future<void> logout(
      BuildContext context, VoidCallback navigateToLogin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    await _auth.signout(context);

    navigateToLogin();
  }
}
