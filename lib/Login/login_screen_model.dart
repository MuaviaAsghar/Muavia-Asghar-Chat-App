import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../authentication/auth.dart';

class LoginScreenModel {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  bool isKeyboardVisible = false;
  bool rememberMe = false;
  final AuthService _auth = AuthService();

  Future<void> loadSavedCredentials(
      Function(String, String, bool) updateState) async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email') ?? '';
    final savedPassword = prefs.getString('password') ?? '';
    final rememberMe = prefs.getBool('remember_me') ?? false;

    if (rememberMe) {
      updateState(savedEmail, savedPassword, rememberMe);
    }
  }

  Future<void> saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email.text);
    await prefs.setString('password', password.text);
    await prefs.setBool('remember_me', rememberMe);
  }

  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');
    await prefs.setBool('remember_me', rememberMe);
  }

  Future<void> login(
      BuildContext context, VoidCallback navigateToHomePage) async {
    final user = await _auth.loginUserWithEmailAndPassword(
      context,
      email.text,
      password.text,
    );

    if (user != null) {
      log("User Logged In");
      if (rememberMe) {
        await saveCredentials();
      } else {
        await clearCredentials();
      }
      navigateToHomePage();
    } else {
      // Handle login error
    }
  }
}
