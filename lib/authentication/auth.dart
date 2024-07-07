import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:say_anything_to_muavia/widgets/snackbar.dart';
import '../Models/json_model.dart';
import '../Models/message_model.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  FirebaseMessaging fMessaging = FirebaseMessaging.instance;
  User? get user => _auth.currentUser;

  ChatUser? me;
  String? displayName;

  AuthService() {
    initializeMe();
  }

  Future<void> updateUserInfo(String name, String about) async {
    await _firestore.collection('usersData').doc(user!.uid).update({
      'name': name,
      'about': about,
    });
  }

  Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();
    await fMessaging.getToken().then((t) {
      if (t != null) {
        me?.pushToken = t;
        log('Push Token: $t');
      }
    });
  }

  Future<void> initializeMe() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot doc =
          await _firestore.collection('usersData').doc(currentUser.uid).get();
      final displayName = doc.get('name') as String?;
      final about = doc.get('about') as String?;
      final photoUrl = doc.get('image') as String?;

      me = ChatUser(
        id: currentUser.uid,
        name: displayName ?? 'No name found',
        email: currentUser.email ?? '',
        about: about ?? "Hey, I'm using We Chat!",
        image: photoUrl ?? '',
        createdAt: '',
        isOnline: false,
        lastActive: '',
        pushToken: '',
      );
    } else {
      log('No user is currently signed in.');
    }
  }

  Future<bool> userExists() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      return (await _firestore
              .collection('usersData')
              .doc(currentUser.uid)
              .get())
          .exists;
    }
    return false;
  }

  Future<void> addInfoToFirebase({required String displayName}) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      String now = DateTime.now().millisecondsSinceEpoch.toString();
      ChatUser newUser = ChatUser(
        id: currentUser.uid,
        name: displayName,
        email: currentUser.email ?? '',
        about: "Hey, I'm using We Chat!",
        image: currentUser.photoURL ?? '',
        createdAt: now,
        isOnline: false,
        lastActive: '',
        pushToken: '',
      );
      await _firestore
          .collection('usersData')
          .doc(currentUser.uid)
          .set(newUser.toJson());
    }
  }

  Future<void> sendPasswordResetMail(
    BuildContext context,
    String email,
    GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
  ) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (context.mounted) {
        CustomSnackBar.showSuccess(
            context, "Password reset email sent to $email", scaffoldMessengerKey);
      }
    } catch (e) {
      log("Error sending password reset email: $e");
      if (context.mounted) {
        CustomSnackBar.showError(
            context, "Error sending email to $email", scaffoldMessengerKey);
      }
    }
  }

  Future<void> sendEmailVerification() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<User?> createUserWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await addInfoToFirebase(displayName: name).then((value) => getSelfInfo());
      return cred.user;
    } catch (e) {
      log("Something went wrong: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong"),
          ),
        );
      }
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong"),
          ),
        );
      }
    }
    return null;
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
    } catch (e) {
      log("Something went wrong: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong"),
          ),
        );
      }
    }
  }

  Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    log('Extension: $ext');

    final ref = storage.ref().child('profile_pictures/${user!.uid}.$ext');

    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    me?.image = await ref.getDownloadURL();
    await _firestore
        .collection('usersData')
        .doc(user?.uid)
        .update({'image': me?.image});
  }

  Future<bool> resetPasswordFromSetting(
      String email, String newPassword, BuildContext context) async {
    try {
      User? user = _auth.currentUser;
      await user?.updatePassword(newPassword);

      await _firestore.collection('usersData').doc(user?.uid).update({
        'password': newPassword,
        'passwordUpdatedAt': Timestamp.now(),
      });

      return true;
    } catch (e) {
      log("Error resetting password: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong"),
          ),
        );
      }
    }
    return false;
  }

  Future<void> getSelfInfo() async {
    await _firestore
        .collection('usersData')
        .doc(user?.uid)
        .get()
        .then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();

        //for setting user status to active
        await updateActiveStatus(true);
        log('My Data: ${user.data()}');
      } else {
        log('User data not found.');
      }
    });
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

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(List<String> userIds) {
    log('\nUserIds: $userIds');

    return _firestore
        .collection('usersData')
        .where('id', isNotEqualTo: user?.uid)
        .snapshots();
  }

  Future<void> updateUserImageURL(String id, String url) async {
    try {
      await _firestore.collection('usersData').doc(id).update({'image': url});
      log('User image URL updated successfully');
    } catch (e) {
      log('Error updating user image URL: $e');
    }
  }

  String getConversationID(String id) => user!.uid.hashCode <= id.hashCode
      ? '${user?.uid}_$id'
      : '${id}_${user?.uid}';

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser user) {
    return _firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  Future<void> sendFirstMessage(ChatUser chatUser, String msg, Type type) async {
    await _firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user?.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  Future<void> sendMessage(ChatUser chatUser, String msg, Type type) async {
    //message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    //message to send
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromId: user!.uid,
        sent: time);

    final ref = _firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson());
    //updating message read status
    // await updateMessageReadStatus(message);
  }

  Future<void> updateMessageReadStatus(Message message) async {
    _firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  //get only last message of a specific chat
  Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(ChatUser user) {
    return _firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  Future<void> updateMessage(Message message, String updatedMsg) async {
    await _firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }

  Future<void> sendChatImage(ChatUser chatUser, File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });
    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  Future<void> deleteMessage(Message message) async {
    await _firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(ChatUser chatUser) {
    return _firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  // update online or last active status of user
  Future<void> updateActiveStatus(bool isOnline) async {
    _firestore.collection('users').doc(user?.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me?.pushToken,
    });
  }
}
