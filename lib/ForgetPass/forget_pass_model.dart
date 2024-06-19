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
  bool isEmailSent = false;
  bool emailSendError = false;

  Future<void> forgetPass(context) async {
    if (!_validateEmail(email.text.trim())) {
      _showError("Invalid email address.");
      return;
    }

    try {
      myAuth.setConfig(
        appEmail: "newgamer445@gmail.com",
        appName: "ChatApp",
        userEmail: email.text.trim(),
        otpLength: 6,
        otpType: OTPType.digitsOnly,
      );

      bool emailSent = await myAuth.sendOTP();
      if (emailSent) {
        isEmailSent = true;
        emailSendError = false;
        _showSuccess("OTP sent successfully.");
      } else {
        isEmailSent = false;
        emailSendError = true;
        _showError("Failed to send OTP.");
      }
    } catch (e) {
      isEmailSent = false;
      emailSendError = true;
      _showError("Error occurred while sending OTP.");
      log("Error during forgetPass: $e");
    }
  }

  Future<void> resetPassword(context) async {
    String otpCode = code.text.trim();
    String newPassword = password.text.trim();
    String confirmNewPassword = confirmPassword.text.trim();

    if (newPassword != confirmNewPassword) {
      _showError("Passwords do not match.");
      return;
    }

    if (newPassword.isEmpty || otpCode.isEmpty) {
      _showError("OTP and new password fields cannot be empty.");
      return;
    }

    try {
      bool isOtpValid = await myAuth.verifyOTP(otp: otpCode);
      if (!isOtpValid) {
        _showError("Invalid OTP.");
        return;
      }

      bool passwordReset =
          await _auth.resetPassword(email.text.trim(), newPassword);
      if (passwordReset) {
        _showSuccess("Password reset successful.");
      } else {
        _showError("Password reset failed.");
      }
    } catch (e) {
      _showError("Failed to reset password: ${e.toString()}");
      log("Error during Reset Password: $e");
    }
  }

  void _showError(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  bool _validateEmail(String email) {
    final emailRegex = RegExp(
        r'^[a-zA-Z0-9.a-zA-Z0-9.!#$%&*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+$');
    return emailRegex.hasMatch(email);
  }
}
