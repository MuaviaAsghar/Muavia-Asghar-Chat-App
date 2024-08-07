import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:say_anything_to_muavia/Models/json_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../authentication/auth.dart';

class HomeScreenModel extends ChangeNotifier {
  final AuthService auth = AuthService();
  final _firebaseauth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String? userId;
  String? name;
  String? email;
  String? about;
  String? image;

  HomeScreenModel() {
    userId = _firebaseauth.currentUser?.uid;
  }

  final customCacheManager = CacheManager(Config('customcachekey',
      stalePeriod: const Duration(days: 30), maxNrOfCacheObjects: 100));

  late final List<ChatUser> list = [];
  final List<ChatUser> searchlist = [];
  bool isSearching = false;
  List<ChatUser> allUsers = [];
  List<String> chatUserIds = [];
  bool isSelectingTile = false;

  final List<ChatUser> _selectedItems = [];
  List<ChatUser> get selectedItems => _selectedItems;

  void addSelectedItem(ChatUser user) {
    log("addSelectedItem  calling");

    _selectedItems.add(user);
    isSelectingTile = true;
    notifyListeners();
  }

  void removeSelectedItem(ChatUser user) {
    log("removeSelectedItem  calling");

    _selectedItems.remove(user);
    if (_selectedItems.isEmpty) {
      isSelectingTile = false;
    }
    notifyListeners();
  }

  void clearSelectedItems() {
    log("clearSelectedItems  calling");

    _selectedItems.clear();
    isSelectingTile = false;
    notifyListeners();
  }

  void toggleSearching() {
    log("clearSelectedItems  calling");

    isSearching = !isSearching;
    notifyListeners();
  }
  // late final List<ChatUser> list = [];

  // final List<ChatUser> searchlist = [];
  // bool isSearching = false;
  // List<ChatUser> allUsers = [];
  // List<String> chatUserIds = [];
  // List<ChatUser> selectedItems = [];
  // bool isSelectingTile = false;
  Future<void> fetchUserData() async {
    if (userId != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('usersData').doc(userId).get();
        if (userDoc.exists) {
          name = userDoc['name'] ?? 'Unknown';
          email = userDoc['email'] ?? 'Unknown';
          image = userDoc['image'] ?? '';
          about = userDoc['about'] ?? '';
          log('Fetched user data: name=$name, email=$email, imageUrl=$image,about=$about,');
        } else {
          log('User document does not exist');
        }
      } catch (e) {
        log('Error fetching user data: $e');
      }
    } else {
      log('User ID is null');
    }
  }

  Future<List<ChatUser>> fetchAllUsers() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('usersData').get();
      List<ChatUser> users = snapshot.docs
          .map((doc) => ChatUser.fromJson(doc.data()))
          .where((user) =>
              user.id != userId &&
              user.id != 'chatbot') // Filter out current user and chatbot
          .toList();
      return users;
    } catch (e) {
      log('Error fetching all users: $e');
      return [];
    }
  }

  Future<void> addChatUser(ChatUser user) async {
    try {
      await _firestore.collection('chatUsers').doc(userId).set({
        'chatUsers': FieldValue.arrayUnion([user.id])
      }, SetOptions(merge: true));

      log('Added user to chat list: ${user.name}');
    } catch (e) {
      log('Error adding user to chat list: $e');
    }
  }

  Future<List<String>> fetchChatUsers() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await _firestore.collection('chatUsers').doc(userId).get();
      List<String> chatUsers = doc.data()?['chatUsers']?.cast<String>() ?? [];
      return chatUsers;
    } catch (e) {
      log('Error fetching chat users: $e');
      return [];
    }
  }

  Future<void> logout(
      BuildContext context, VoidCallback navigateToLogin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context.mounted) {
      await auth.signOut(context);
    }
    navigateToLogin();
  }
}
