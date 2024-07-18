import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';

import 'package:flutter/material.dart';
import 'package:say_anything_to_muavia/Login/login_screen_view.dart';
import 'package:say_anything_to_muavia/widgets/snackbar.dart';

import '../authentication/auth.dart';

class OtpScreenModel {
  final TextEditingController otptext = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
        if (context.mounted) {
          CustomSnackBar.showError(
              context, "Failed to send OTP", scaffoldMessengerKey);

          log("Failed to send OTP to $email");
        }
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.showError(
            context, "Error: ${e.toString()}", scaffoldMessengerKey);

        log("Error sending OTP: ${e.toString()}");
      }
    }
  }

  Future<void> verifyOtp(
      BuildContext context, String name, String email, String password) async {
    try {
      log("Verifying OTP: ${otptext.text}");
      bool isOtpValid = await myAuth.verifyOTP(otp: otptext.text);
      DocumentReference userDocRef =_firestore
          .collection('userEmailList')
          .doc('userList');
      if (isOtpValid) {
        log("OTP is valid, creating user.");
        if (context.mounted) {
          await _auth.createUserWithEmailAndPassword(
            context: context,
            name: name,
            email: email,
            password: password,
          );
        }

        bool docExists = (await userDocRef.get()).exists;
// Suggested code may be subject to a license. Learn more: ~LicenseLog:3010724091.
        if (docExists) {
          // Document exists, update the email list
          await userDocRef.update({
            'emails': FieldValue.arrayUnion([email]),
          });
        } else {
          // Document does not exist, create it with the email list
          await userDocRef.set({
            'emails': [email],
          });
        }
        if (context.mounted) {
          await navigateToLoginPage(context);
        }
        log("User Created Successfully");
      } else {
        if (context.mounted) {
          CustomSnackBar.showError(
              context, "Invalid OTP", scaffoldMessengerKey);

          log("Invalid OTP");
        }
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.showError(context,
            "Failed to verify OTP: ${e.toString()}", scaffoldMessengerKey);

        log("Error verifying OTP: ${e.toString()}");
      }
    }
  }
}
