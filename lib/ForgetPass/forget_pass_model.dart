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

  Future<void> forgetPass(BuildContext context) async {
    try {
      
      // Assuming forgetPass method sends the email
      myAuth.setConfig(
        appEmail: "newgamer445@gmail.com",
        appName: "ChatApp",
        userEmail: email.text.trim(),
        otpLength: 6,
        otpType: OTPType.digitsOnly,
      );
_validateEmail(email.text.trim());
      bool emailSent = await myAuth.sendOTP();
      if (emailSent) {
        isEmailSent = true;
        emailSendError = false;
      } else {
        isEmailSent = false;
        emailSendError = true;
      }
    } catch (e) {
      isEmailSent = false;
      emailSendError = true;
    }
    (context as Element).markNeedsBuild();
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
      if (!isOtpValid) {
        _showError(context.mounted as BuildContext, "Invalid OTP.");
        return;
      }

      bool passwordReset = await _auth.resetPassword(email.text.trim(), newPassword, context);
      if (passwordReset) {
        _showSuccess(context.mounted as BuildContext, "Password reset successful.");
      } else {
        _showError(context.mounted as BuildContext, "Password reset failed.");
      }
    } catch (e) {
      _showError(context.mounted as BuildContext, "Failed to reset password: ${e.toString()}");
      log("Error during Reset Password: $e");
    }
  }

  void _showError(BuildContext context, String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(BuildContext context, String message) {
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
