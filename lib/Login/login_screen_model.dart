import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:say_anything_to_muavia/widgets/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../authentication/auth.dart';

class LoginScreenModel {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  bool isKeyboardVisible = false;
  bool rememberMe = false;
  final AuthService _auth = AuthService();
  final _firestore = FirebaseFirestore.instance;
  final _firebaseauth = FirebaseAuth.instance;

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
void clearText() {
  password.clear();
  email.clear();
}

  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');
    await prefs.setBool('remember_me', rememberMe);
  }

 Future<void> login(
      BuildContext context, VoidCallback navigateToHomePage) async {
    try {
      final user = await _auth.loginUserWithEmailAndPassword(
        email.text,
        password.text,
        context,
      );

      if (user != null) {
        dynamic userId = _firebaseauth.currentUser?.uid;

        DocumentSnapshot userDoc =
            await _firestore.collection('usersData').doc(userId).get();

        if (userDoc.exists) {
          String storedPassword = userDoc.get('password');
          if (password.text == storedPassword) {
            log("Password matches, proceeding with login.");
            if (rememberMe) {
              await saveCredentials();
            } else {
              await clearCredentials();
            }
              navigateToHomePage();
          } else {
            log("Password does not match, updating the password in Firestore.");
            await _firestore.collection('usersData').doc(userId).update({
              'password': password.text,
            });

            if (rememberMe) {
              await saveCredentials();
            } else {
              await clearCredentials();
            }
                navigateToHomePage();
          }
        } else {
          log("User document does not exist.");
          if (context.mounted) {
            CustomSnackBar.showError(
                context, "User document does not exist", scaffoldMessengerKey);
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.showError(
            context, "Error logging in: ${e.toString()}", scaffoldMessengerKey);
      }
      log("Error logging in: ${e.toString()}");
    }
}
}