import 'dart:developer';

import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';

import '../authentication/auth.dart';

class ForgetPassModel {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  final TextEditingController code = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final EmailOTP myAuth = EmailOTP();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();
  final FocusNode codeFocus = FocusNode();
  final AuthService _auth = AuthService();
  bool isKeyboardVisible = false;
  bool isOtpSent = false;

  Future<void> forgetPass(BuildContext context) async {
    try {
      String emailText = email.text.trim();

      if (!_validateEmail(emailText)) {
        _showError(context, "Invalid email address.");
        return;
      }

      // Check if the email already exists in Firestore
      bool emailExists = await _auth.isEmailInUse(emailText);
      if (!emailExists) {
        _showError(context, "Email not found.");
        return;
      }

      myAuth.setConfig(
        appEmail: "newgamer445@gmail.com",
        appName: "ChatApp",
        userEmail: emailText,
        otpLength: 6,
        otpType: OTPType.digitsOnly,
      );

      bool otpSent = await myAuth.sendOTP();
      if (otpSent) {
        log("OTP sent to $emailText");
        isOtpSent = true;
      } else {
        _showError(context, "Failed to send OTP.");
        log("Failed to send OTP to $emailText");
      }
    } catch (e) {
      _showError(context, "Failed to send OTP: ${e.toString()}");
      log("Error during Sending OTP: $e");
    }
  }

  Future<void> resetPassword(BuildContext context) async {
    try {
      String otpCode = code.text.trim();
      String newPassword = password.text.trim();
      String confirmNewPassword = confirmPassword.text.trim();

      if (newPassword != confirmNewPassword) {
        _showError(context, "Passwords do not match.");
        return;
      }

      if (newPassword.isEmpty || otpCode.isEmpty) {
        _showError(context, "OTP and new password fields cannot be empty.");
        return;
      }

      bool isOtpValid = await myAuth.verifyOTP(otp: otpCode);
      if (isOtpValid) {
        log("OTP is valid, resetting password.");
        await _auth.resetPassword(email.text.trim(), newPassword);
        log("Password reset successfully.");
        _showError(context, "Password reset successfully.", Colors.green);
      } else {
        _showError(context, "Invalid OTP.");
        log("Invalid OTP");
      }
    } catch (e) {
      _showError(context, "Failed to reset password: ${e.toString()}");
      log("Error resetting password: ${e.toString()}");
    }
  }

  bool _validateEmail(String email) {
    return email.contains('@');
  }

  void _showError(BuildContext context, String message,
      [Color color = Colors.red]) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }
}
