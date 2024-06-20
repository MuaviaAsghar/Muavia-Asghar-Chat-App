import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../authentication/auth.dart';

class ChatScreenModel{
  //   final AuthService _auth = AuthService();
  // final _firebaseauth = FirebaseAuth.instance;
  // final _firestore = FirebaseFirestore.instance;

  // String? userId;
  // String? name;
  // String? email;

  // HomeScreenModel() {
  //   userId = _firebaseauth.currentUser?.uid;
  // }

  // Future<void> fetchUserData() async {
  //   if (userId != null) {
  //     DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
  //     if (userDoc.exists) {
  //       name = userDoc['name'];
  //       email = userDoc['email'];
  //     }
  //   }
  // }

}