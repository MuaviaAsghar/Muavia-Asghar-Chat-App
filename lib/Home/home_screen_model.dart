import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../authentication/auth.dart';

class HomeScreenModel {
  final AuthService _auth = AuthService();
  final _firebaseauth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String? userId;
  String? name;
  String? email;

  HomeScreenModel() {
    userId = _firebaseauth.currentUser?.uid;
  }

  Future<void> fetchUserData() async {
    if (userId != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        name = userDoc['name'];
        email = userDoc['email'];
      }
    }
  }

  Future<void> logout(BuildContext context, VoidCallback navigateToLogin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context.mounted) {
      await _auth.signout(context);
    }
    navigateToLogin();
  }
}
