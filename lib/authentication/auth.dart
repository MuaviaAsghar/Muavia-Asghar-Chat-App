import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<User?> createUserWithEmailAndPassword(BuildContext context,
      {required email, required password}) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      log("Something went wrong");
      const snackBar = SnackBar(
        content: Text("Something went wrong"),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    return null;
  }

  Future<User?> loginUserWithEmailAndPassword(
      context, String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      log("Something went wrong");
      const snackBar = SnackBar(
        content: Text("Something went wrong"),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    return null;
  }

  Future<void> signout(context) async {
    try {
      await _auth.signOut();
    } catch (e) {
      log("Something went wrong");
      const snackBar = SnackBar(
        content: Text("Something went wrong"),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
