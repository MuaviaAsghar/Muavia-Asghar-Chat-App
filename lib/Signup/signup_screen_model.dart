import 'dart:developer';

import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:say_anything_to_muavia/widgets/snackbar.dart';

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
    if (isSignupButtonDisabled) return; // Prevent multiple taps

    isSignupButtonDisabled = true; // Disable button on tap

    try {
      String emailText = email.text.trim();
      String passwordText = password.text.trim();
      String nameText = name.text.trim();

      if (!_validateEmail(emailText)) {
     CustomSnackBar.showError(context,"Invalid Mail",scaffoldMessengerKey);
        isSignupButtonDisabled = false; // Re-enable button
        return;
      }

      if (!_validatePassword(passwordText)) {
        CustomSnackBar.showError(context, "Password must be at least 6 characters.",scaffoldMessengerKey);
        isSignupButtonDisabled = false; // Re-enable button
        return;
      }

      bool emailExists = await _auth.isEmailInUse(emailText);
      if (emailExists) {
    CustomSnackBar.showError(context.mounted as BuildContext, "Email already in use.",scaffoldMessengerKey);
        isSignupButtonDisabled = false; // Re-enable button
        return;
      }

      navigateToOtpPage(context.mounted as BuildContext, nameText, emailText, passwordText);
      log("Sending OTP to $emailText");

 
        log("OTP sent to $emailText");
 
    } catch (e) {
        CustomSnackBar.showError(context.mounted as BuildContext, "Failed to create user: ${e.toString()}",scaffoldMessengerKey);
      log("Error during signup: $e");
      isSignupButtonDisabled = false; // Re-enable button
    }
  

  
    }}
