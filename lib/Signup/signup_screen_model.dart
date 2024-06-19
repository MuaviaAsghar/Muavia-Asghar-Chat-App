import 'dart:developer';

import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';

import '../authentication/auth.dart';
import '../otp_screen.dart/otp_screen_view.dart';
import '../widgets/snackbar.dart';

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
  bool isSignupButtonDisabled = false;

  bool _validateEmail(String email) {
    return email.contains('@');
  }

  bool _validatePassword(String password) {
    return password.length >= 6;
  }

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
    if (isSignupButtonDisabled) return;

    isSignupButtonDisabled = true;

    try {
      String emailText = email.text.trim();
      String passwordText = password.text.trim();
      String nameText = name.text.trim();

      if (!_validateEmail(emailText)) {
        if (context.mounted) {
          CustomSnackBar.showError(
              context, "Invalid Mail", scaffoldMessengerKey);
        }
        isSignupButtonDisabled = false;
        return;
      }

      if (!_validatePassword(passwordText)) {
        if (context.mounted) {
          CustomSnackBar.showError(context,
              "Password must be at least 6 characters.", scaffoldMessengerKey);
        }
        isSignupButtonDisabled = false;
        return;
      }

      bool emailExists = await _auth.isEmailInUse(emailText);
      if (emailExists) {
        if (context.mounted) {
          CustomSnackBar.showError(
              context, "Email already in use.", scaffoldMessengerKey);
        }
        isSignupButtonDisabled = false;
        return;
      }

      if (context.mounted) {
        await navigateToOtpPage(context, nameText, emailText, passwordText);
      }

      log("Sending OTP to $emailText");
      log("OTP sent to $emailText");
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.showError(context,
            "Failed to create user: ${e.toString()}", scaffoldMessengerKey);
      }
      log("Error during signup: $e");
      isSignupButtonDisabled = false;
    }
  }
}
