import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:say_anything_to_muavia/Home/home_screen_view.dart';

import 'package:say_anything_to_muavia/widgets/snackbar.dart';
import '../authentication/auth.dart';

class NewPasswordModel {

  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  final FocusNode confirmPasswordFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final AuthService _auth = AuthService();
  bool isKeyboardVisible = false;
  bool emailSendError = false;

  void navigateToHomePage(context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const HomeScreenView(),
      ),
      (Route<dynamic> route) => false,
    );
  }
  Future<void> resetPassword(BuildContext context, String userEmail, String newPassword) async {
    try {
      String confirmNewPassword = confirmPassword.text.trim();

      if (newPassword != confirmNewPassword) {
        CustomSnackBar.showError(context, "Passwords do not match.", scaffoldMessengerKey);
        return;
      }

      if (newPassword.isEmpty) {
        CustomSnackBar.showError(context, "New password fields cannot be empty.", scaffoldMessengerKey);
        return;
      }

      bool passwordReset = await _auth.resetPasswordFromSetting(userEmail, newPassword, context);
      if (passwordReset) {
        if (context.mounted) {
          CustomSnackBar.showSuccess(context, "Password reset successful.", scaffoldMessengerKey);
        }
      } else {
        if (context.mounted) {
          CustomSnackBar.showError(context, "Password reset failed.", scaffoldMessengerKey);
        }
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.showError(context, "Failed to reset password: ${e.toString()}", scaffoldMessengerKey);
      }
      log("Error during Reset Password: $e");
    }
  }
}
