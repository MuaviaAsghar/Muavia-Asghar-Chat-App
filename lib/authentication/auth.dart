import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> sendEmailVerification() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<User?> createUserWithEmailAndPassword(
    BuildContext context, {
      required String name,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
           email: email, password: password);

      // Add user information to Firestore
      await _firestore.collection('users').doc(cred.user?.uid).set({
        'name': name,
        'email': email,
        'password': password,
        'createdAt': Timestamp.now(),
      });
      await _firestore.collection('usersEmailList').doc('userList').set({
        'email': email,
      });
      return cred.user;
    } catch (e) {
      log("Something went wrong: $e");
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
      log("Something went wrong: $e");
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
      log("Something went wrong: $e");
      const snackBar = SnackBar(
        content: Text("Something went wrong"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<User?> fetchSignInMethodsForEmail(String email) async {
    try {
      List<String> signInMethods =
          await _auth.fetchSignInMethodsForEmail(email);
      if (signInMethods.isNotEmpty) {
        return _auth.currentUser;
      }
      return null;
    } catch (e) {
      log("Error fetching sign-in methods for email: $e");
      return null;
    }
  }
}
