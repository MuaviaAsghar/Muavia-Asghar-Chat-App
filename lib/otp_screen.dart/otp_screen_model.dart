import 'dart:developer';

import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:say_anything_to_muavia/Login/login_screen_view.dart';

import '../authentication/auth.dart';

class OtpScreenModel {
  final TextEditingController otptext = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final EmailOTP myAuth = EmailOTP();
  final FocusNode otpFocus = FocusNode();
  final AuthService _auth = AuthService();
  bool isKeyboardVisible = false;

  Future<void> navigateToLoginPage(BuildContext context) {
    return Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const LoginScreenView(),
      ),
      (Route<dynamic> route) => false,
    );
  }

  void showError(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> sendOtp(String email) async {
    try {
      myAuth.setConfig(
        appEmail: "newgamer445@gmail.com",
        appName: "Free Chat",
        userEmail: email,
        otpLength: 6,
        otpType: OTPType.digitsOnly,
      );
      bool isOtpSent = await myAuth.sendOTP();
      if (isOtpSent) {
        log("OTP sent to $email");
      } else {
        showError("Failed to send OTP");
        log("Failed to send OTP to $email");
      }
    } catch (e) {
      showError("Error: ${e.toString()}");
      log("Error sending OTP: ${e.toString()}");
    }
  }

  Future<void> verifyOtp(
      BuildContext context, String name, String email, String password) async {
    try {
      log("Verifying OTP: ${otptext.text}");
      bool isOtpValid = await myAuth.verifyOTP(otp: otptext.text);
      if (isOtpValid) {
        log("OTP is valid, creating user.");
        await _auth.createUserWithEmailAndPassword(
          context,
          name: name,
          email: email,
          password: password,
        );
        navigateToLoginPage(context);
        log("User Created Successfully");
      } else {
        showError("Invalid OTP");
        log("Invalid OTP");
      }
    } catch (e) {
      showError("Failed to verify OTP: ${e.toString()}");
      log("Error verifying OTP: ${e.toString()}");
    }
  }
}
