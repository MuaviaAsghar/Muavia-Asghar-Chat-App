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
        'createdAt': Timestamp.now(),
      });

      await _firestore.collection('usersEmailList').doc('userList').set({
        'email': FieldValue.arrayUnion([email]),
      });

      return cred.user;
    } catch (e) {
      log("Something went wrong: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong"),
        ),
      );
    }
    return null;
  }

  Future<User?> loginUserWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      log("Something went wrong: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong"),
        ),
      );
    }
    return null;
  }

  Future<void> signout(BuildContext context) async {
    try {
      await _auth.signOut();
    } catch (e) {
      log("Something went wrong: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong"),
        ),
      );
    }
  }

  Future<void> resetPassword(String email, String newPassword) async {
    try {
      User? user =
          (await _auth.signInWithEmailLink(email: email, emailLink: email))
              .user;
      if (user != null) {
        await user.updatePassword(newPassword);
        log("Password reset successfully for $email");
      }
    } catch (e) {
      log("Error resetting password: $e");
    }
  }

  Future<bool> isEmailInUse(String email) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('usersEmailList').doc('userList').get();
      if (doc.exists) {
        List<dynamic> emails = doc.get('email');
        return emails.contains(email);
      }
    } catch (e) {
      log("Error checking email existence: $e");
    }
    return false;
  }
}
