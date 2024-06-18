import 'dart:developer';

import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';

import '../authentication/auth.dart';
import '../otp_screen.dart/otp_screen_view.dart';

class SignupScreenModel {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController name = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final EmailOTP myAuth = EmailOTP();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode nameFocus = FocusNode();
  final AuthService _auth = AuthService();
  bool isKeyboardVisible = false;
  bool isSignupButtonDisabled = false; // Add this variable

  Future<void> navigateToOtpPage(
      BuildContext context, String name, String email, String password) {
    return Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => OtpScreenView(
          name: name,
          email: email,
          password: password,
        ),
      ),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> signup(BuildContext context) async {
    if (isSignupButtonDisabled) return; // Prevent multiple taps

    isSignupButtonDisabled = true; // Disable button on tap

    try {
      String emailText = email.text.trim();
      String passwordText = password.text.trim();
      String nameText = name.text.trim();

      if (!_validateEmail(emailText)) {
        _showError(context, "Invalid email address.");
        isSignupButtonDisabled = false; // Re-enable button
        return;
      }

      if (!_validatePassword(passwordText)) {
        _showError(context, "Password must be at least 6 characters.");
        isSignupButtonDisabled = false; // Re-enable button
        return;
      }

      // Check if the email already exists in Firestore
      bool emailExists = await _auth.isEmailInUse(emailText);
      if (emailExists) {
        _showError(context, "Email already in use.");
        isSignupButtonDisabled = false; // Re-enable button
        return;
      }

      // Navigate to OTP page and send OTP
      navigateToOtpPage(context, nameText, emailText, passwordText);
      log("Sending OTP to $emailText");

      myAuth.setConfig(
        appEmail: "newgamer445@gmail.com",
        appName: "Bachi na mili",
        userEmail: emailText,
        otpLength: 6,
        otpType: OTPType.digitsOnly,
      );

      bool otpSent = await myAuth.sendOTP();
      if (otpSent) {
        log("OTP sent to $emailText");
      } else {
        _showError(context, "Failed to send OTP.");
        log("Failed to send OTP to $emailText");
        isSignupButtonDisabled = false; // Re-enable button
      }
    } catch (e) {
      _showError(context, "Failed to create user: ${e.toString()}");
      log("Error during signup: $e");
      isSignupButtonDisabled = false; // Re-enable button
    }
  }

  bool _validateEmail(String email) {
    return email.contains('@');
  }

  bool _validatePassword(String password) {
    return password.length >= 6;
  }

  void _showError(BuildContext context, String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
