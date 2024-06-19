import 'dart:developer';

import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:say_anything_to_muavia/Login/login_screen_view.dart';
import 'package:say_anything_to_muavia/widgets/snackbar.dart';

import '../authentication/auth.dart';

class OtpScreenModel {
  final TextEditingController otptext = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final EmailOTP myAuth = EmailOTP();
  final FocusNode otpFocus = FocusNode();
  final AuthService _auth = AuthService();
  bool isKeyboardVisible = false;
  late String email;
  Future<void> navigateToLoginPage(BuildContext context) {
    return Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const LoginScreenView(),
      ),
      (Route<dynamic> route) => false,
    );
  }


  Future<void> sendOtp(BuildContext context,String email) async {
    try {
      bool isOtpSent = await myAuth.sendOTP();
      if (isOtpSent) {
        log("OTP sent to $email");
      } else {
        CustomSnackBar.showError(context.mounted as BuildContext,"Failed to send OTP",scaffoldMessengerKey);
      
        log("Failed to send OTP to $email");
      }
    } catch (e) {
       CustomSnackBar.showError(context.mounted as BuildContext,"Error: ${e.toString()}",scaffoldMessengerKey);
    
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
          context.mounted as BuildContext,
          name: name,
          email: email,
          password: password,
        );
        navigateToLoginPage(context.mounted as BuildContext);
        log("User Created Successfully");
      } else {
        CustomSnackBar.showError(context.mounted as BuildContext,"Invalid OTP",scaffoldMessengerKey);
      
        log("Invalid OTP");
      }
    } catch (e) {
      CustomSnackBar.showError(context.mounted as BuildContext,"Failed to verify OTP: ${e.toString()}",scaffoldMessengerKey);

      log("Error verifying OTP: ${e.toString()}");
    }
  }
}
