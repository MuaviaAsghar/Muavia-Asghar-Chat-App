// import 'dart:developer';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class AuthService {
//   final _auth = FirebaseAuth.instance;
//   final _firestore = FirebaseFirestore.instance;

//   Future<void> sendEmailVerification() async {
//     User? user = _auth.currentUser;
//     if (user != null && !user.emailVerified) {
//       await user.sendEmailVerification();
//     }
//   }

//   Future<void> updateUser(String newPassword, BuildContext context) async {
//     try {
//       CollectionReference users = FirebaseFirestore.instance.collection('users');
//       return users
//           .doc('users')
//           .update({'password': newPassword})
//           .then((value) => print("User Updated"))
//           .catchError((error) => print("Failed to update user: $error"));
//     } catch (e) {
//       log("Error resetting password: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Something went wrong"),
//         ),
//       );
//     }
//   }

//   Future<User?> createUserWithEmailAndPassword(
//     BuildContext context, {
//     required String name,
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final cred = await _auth.createUserWithEmailAndPassword(
//           email: email, password: password);

//       await _firestore.collection('users').doc(cred.user?.uid).set({
//         'name': name,
//         'email': email,
//         'password': password,
//         'createdAt': Timestamp.now(),
//       });

//       await _firestore.collection('usersEmailList').doc('userList').set({
//         'email': FieldValue.arrayUnion([email]),
//       });

//       return cred.user;
//     } catch (e) {
//       log("Something went wrong: $e");
//       ScaffoldMessenger.of(context.mounted as BuildContext).showSnackBar(
//         const SnackBar(
//           content: Text("Something went wrong"),
//         ),
//       );
//     }
//     return null;
//   }

//   Future<User?> loginUserWithEmailAndPassword(
//       BuildContext context, String email, String password) async {
//     try {
//       final cred = await _auth.signInWithEmailAndPassword(
//           email: email, password: password);
//       return cred.user;
//     } catch (e) {
//       log("Something went wrong: $e");
//       ScaffoldMessenger.of(context.mounted as BuildContext).showSnackBar(
//         const SnackBar(
//           content: Text("Something went wrong"),
//         ),
//       );
//     }
//     return null;
//   }

//   Future<void> signout(BuildContext context) async {
//     try {
//       await _auth.signOut();
//     } catch (e) {
//       log("Something went wrong: $e");
//       ScaffoldMessenger.of(context.mounted as BuildContext).showSnackBar(
//         const SnackBar(
//           content: Text("Something went wrong"),
//         ),
//       );
//     }
//   }

//   Future<bool> resetPassword(String email, String newPassword, BuildContext context) async {
//     try {
//       User? user = (await _auth.signInWithEmailLink(email: email, emailLink: '')).user;
//       if (user != null) {
//         await user.updatePassword(newPassword);
//         await updateUser(newPassword, context.mounted as BuildContext);
//         return true;
//       }
//     } catch (e) {
//       log("Error resetting password: $e");
//       ScaffoldMessenger.of(context.mounted as BuildContext).showSnackBar(
//         const SnackBar(
//           content: Text("Something went wrong"),
//         ),
//       );
//     }
//     return false;
//   }

//   Future<bool> isEmailInUse(String email) async {
//     try {
//       DocumentSnapshot doc =
//           await _firestore.collection('usersEmailList').doc('userList').get();
//       if (doc.exists) {
//         List<dynamic> emails = doc.get('email');
//         return emails.contains(email);
//       }
//     } catch (e) {
//       log("Error checking email existence: $e");
//     }
//     return false;
//   }
// }
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

  Future<void> updateUser(String newPassword) async {
    try {
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');
      return users
          .doc('users')
          .update({'password': newPassword})
          .then((value) => print("User Updated"))
          .catchError((error) => print("Failed to update user: $error"));
    } catch (e) {
      log("Error resetting password: $e");
    }
  }

  Future<User?> createUserWithEmailAndPassword(
      {required String name,
      required String email,
      required String password,
      required BuildContext context}) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      await _firestore.collection('users').doc(cred.user?.uid).set({
        'name': name,
        'email': email,
        'password': password,
        'createdAt': Timestamp.now(),
      });

      await _firestore.collection('usersEmailList').doc('userList').set({
        'email': FieldValue.arrayUnion([email]),
      });

      return cred.user;
    } catch (e) {
      log("Something went wrong: $e");
    }
    return null;
  }

  Future<User?> loginUserWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      log("Something went wrong: $e");
    }
    return null;
  }

  Future<void> signout(context) async {
    try {
      await _auth.signOut();
    } catch (e) {
      log("Something went wrong: $e");
    }
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      User? user =
          (await _auth.signInWithEmailLink(email: email, emailLink: '')).user;
      if (user != null) {
        await user.updatePassword(newPassword);
        await updateUser(newPassword);
        return true;
      }
    } catch (e) {
      log("Error resetting password: $e");
    }
    return false;
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
