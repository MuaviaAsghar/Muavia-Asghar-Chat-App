import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:say_anything_to_muavia/authentication/auth.dart';

import '../widgets/snackbar.dart';

class ChangePasswordOutsideAppModel {
  final TextEditingController email = TextEditingController();

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final EmailOTP myAuth = EmailOTP();
  final FocusNode emailFocus = FocusNode();
  final AuthService _auth = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isKeyboardVisible = false;
  bool isOtpSent = false;
  bool isEmailSent = false;
  bool emailSendError = false;
  bool isCooldownActive = false; // Cooldown state
  int cooldownSeconds = 2; // Cooldown period in seconds

  Future<void> sendMail(BuildContext context) async {
    if (isCooldownActive) {
      CustomSnackBar.showError(
          context, "Please wait before trying again", scaffoldMessengerKey);
      return;
    }

    try {
      bool emailExists = await _auth.isEmailInUse(email.text.trim());
      if (emailExists) {
        if (context.mounted) {
          await _auth.sendPasswordResetMail(
              context, email.text.trim(), scaffoldMessengerKey);
        }
        if (context.mounted) {
          CustomSnackBar.showSuccess(
              context, "Email does not exist", scaffoldMessengerKey);
        }
        startCooldown(); // Start cooldown after successful email send
      } else {
        log("Email does not exist");
        if (context.mounted) {
          CustomSnackBar.showError(
              context, "Email does not exist", scaffoldMessengerKey);
        }
      }
    } catch (e) {
      log("Error sending password reset email: ${e.toString()}");
      if (context.mounted) {
        CustomSnackBar.showError(
            context, "Error: ${e.toString()}", scaffoldMessengerKey);
      }
    }
  }

  void startCooldown() {
    isCooldownActive = true;
    Timer(Duration(seconds: cooldownSeconds), () {
      isCooldownActive = false;
    });
  }

  Future<bool> checkEmail(String email) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('usersEmailList').doc('userList').get();
      if (doc.exists) {
        List<dynamic> emails = doc.get('email');
        return emails.contains(email);
      }
    } catch (e) {
      log("Error checking email existence: $e");
    }
    return false;
  }
}
