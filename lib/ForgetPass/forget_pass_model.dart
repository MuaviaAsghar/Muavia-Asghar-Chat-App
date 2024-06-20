import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import '../new_password/new_password_view.dart';
import '../widgets/snackbar.dart';

class ForgetPassModel {
  final TextEditingController email = TextEditingController();
  final TextEditingController code = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final EmailOTP myAuth = EmailOTP();
  final FocusNode emailFocus = FocusNode();
  final FocusNode codeFocus = FocusNode();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isKeyboardVisible = false;
  bool isOtpSent = false;
  bool isEmailSent = false;
  bool emailSendError = false;
  bool isCooldownActive = false; // Cooldown state
  int cooldownSeconds = 60; // Cooldown period in seconds

  Future<void> sendMail(BuildContext context) async {
    if (isCooldownActive) {
      CustomSnackBar.showError(context, "Please wait before trying again", scaffoldMessengerKey);
      return;
    }

    try {
      bool emailExists = await checkEmail(email.text.trim());
      if (emailExists) {
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
          log("OTP sent to ${email.text.trim()}");
          if (context.mounted) {
            CustomSnackBar.showSuccess(context, "OTP sent to your email", scaffoldMessengerKey);
          }
          startCooldown(); // Start cooldown after successful email send
        } else {
          isEmailSent = false;
          emailSendError = true;
          log("Failed to send OTP to ${email.text.trim()}");
          if (context.mounted) {
            CustomSnackBar.showError(context, "Failed to send OTP", scaffoldMessengerKey);
          }
        }
      } else {
        log("Email does not exist");
        if (context.mounted) {
          CustomSnackBar.showError(context, "Email does not exist", scaffoldMessengerKey);
        }
      }
    } catch (e) {
      isEmailSent = false;
      emailSendError = true;
      log("Error sending OTP: ${e.toString()}");
      if (context.mounted) {
        CustomSnackBar.showError(context, "Error: ${e.toString()}", scaffoldMessengerKey);
      }
    }
  }

  Future<void> verifyOTP(BuildContext context) async {
    try {
      bool otpValid = await myAuth.verifyOTP(otp: code.text.trim());
      if (otpValid) {
        if (context.mounted) {
          CustomSnackBar.showSuccess(context, "OTP verified successfully", scaffoldMessengerKey);
        }
        if (context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => NewPasswordView(email: email.text.trim())),
          );
        }
      } else {
        if (context.mounted) {
          CustomSnackBar.showError(context, "Invalid OTP", scaffoldMessengerKey);
        }
      }
    } catch (e) {
      log("Error verifying OTP: $e");
      if (context.mounted) {
        CustomSnackBar.showError(context, "Error: $e", scaffoldMessengerKey);
      }
    }
  }

  Future<bool> checkEmail(String email) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('usersEmailList').doc('userList').get();
      if (doc.exists) {
        List<dynamic> emails = doc.get('email');
        return emails.contains(email);
      }
    } catch (e) {
      log("Error checking email existence: $e");
    }
    return false;
  }

  void startCooldown() {
    isCooldownActive = true;
    Timer(Duration(seconds: cooldownSeconds), () {
      isCooldownActive = false;
    });
  }
}
