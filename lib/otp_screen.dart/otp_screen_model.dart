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

  Future<void> sendOtp(BuildContext context, String email) async {
    try {
      bool isOtpSent = await myAuth.sendOTP();
      if (isOtpSent) {
        log("OTP sent to $email");
      } else {
              if(context.mounted){
        CustomSnackBar.showError(context ,"Failed to send OTP",scaffoldMessengerKey);
      
        log("Failed to send OTP to $email");}
      }
    } catch (e) {
      if(context.mounted){
       CustomSnackBar.showError(context,"Error: ${e.toString()}",scaffoldMessengerKey);
    
      log("Error sending OTP: ${e.toString()}");}
    }
  }

  Future<void> verifyOtp(
      BuildContext context, String name, String email, String password) async {
    try {
      log("Verifying OTP: ${otptext.text}");
      bool isOtpValid = await myAuth.verifyOTP(otp: otptext.text);
      if (isOtpValid) {
        log("OTP is valid, creating user.");
        if(context.mounted){
        await _auth.createUserWithEmailAndPassword(
          context:context,
          name: name,
          email: email,
          password: password, 
        );}
        if(context.mounted){
        navigateToLoginPage(context );
        log("User Created Successfully");
        }
      } else {
        if(context.mounted){
        CustomSnackBar.showError(context ,"Invalid OTP",scaffoldMessengerKey);
      
        log("Invalid OTP");}
      }
    } catch (e) {
          if(context.mounted){
      CustomSnackBar.showError(context ,"Failed to verify OTP: ${e.toString()}",scaffoldMessengerKey);

      log("Error verifying OTP: ${e.toString()}");}
    }
  }
}
