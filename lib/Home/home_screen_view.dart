import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Login/login_screen_view.dart';
import '../Models/json_model.dart';
import '../profile_screen/profile_screen.dart';
import '../setting_screen/setting_screen_view.dart';
import '../widgets/chat_screen.dart';
import 'home_screen_model.dart';

class HomeScreenView extends StatefulWidget {
  const HomeScreenView({super.key});

  @override
  State<HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<HomeScreenView> {
  late final List<ChatUser> _list = [];

  late HomeScreenModel model;
  final List<ChatUser> _searchlist = [];
  bool _isSearching = false; // Removed 'final' to allow changes
  @override
  void initState() {
    super.initState();
    model = HomeScreenModel();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: PopScope(
        canPop: !_isSearching,
        onPopInvoked: (_) async {
          if (_isSearching) {
            setState(() => _isSearching = !_isSearching);
          } else {
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: Icon(_isSearching
                    ? CupertinoIcons.clear_circled_solid
                    : Icons.search),
              )
            ],
            title: _isSearching
                ? TextField(
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: 'Name, Email, ...'),
                    autofocus: true,
                    style: const TextStyle(fontSize: 16, letterSpacing: 0.5),
                    onChanged: (val) {
                      _searchlist.clear();
                      for (var i in _list) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                            i.email.toLowerCase().contains(val.toLowerCase())) {
                          _searchlist.add(i);
                        }
                        setState(() {
                          _searchlist;
                        });
                      }
                    },
                  )
                : const Text("ChatApp"),
            centerTitle: true,
          ),
          body: StreamBuilder(
            stream: model.auth.getAllUsers([]),
            builder: (
              context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
            ) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text("Error loading data"));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No data found"));
              }

              final data = snapshot.data!.docs;
              _list.clear();
              for (var doc in data) {
                try {
                  log('Document data: ${doc.data()}');
                  var chatUserModel = ChatUser.fromJson(doc.data());
                  _list.add(chatUserModel);
                } catch (e) {
                  log("Error parsing document ${doc.id}: ${e.toString()}");
                }
              }

              if (_list.isEmpty) {
                return const Center(child: Text("No data found"));
              } else {
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * .01,
                  ),
                  itemCount: _isSearching ? _searchlist.length : _list.length,
                  itemBuilder: (context, index) {
                    return ChatScreenCard(
                        user: _isSearching ? _searchlist[index] : _list[index]);
                  },
                );
              }
            },
          ),
          drawer: Drawer(
            child: FutureBuilder(
              future: model.auth.initializeMe(),
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else {
                  return Column(
                    children: [
                      UserAccountsDrawerHeader(
                        decoration: const BoxDecoration(color: Colors.black),
                        accountName: Text(
                          model.auth.me?.name ?? 'No Name',
                          style: const TextStyle(fontSize: 18),
                        ),
                        accountEmail: Text(model.auth.me?.email ?? ''),
                        currentAccountPictureSize: const Size.square(50),
                        currentAccountPicture: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              MediaQuery.of(context).size.height * .1),
                          child: model.auth.me?.image != null &&
                                  model.auth.me!.image.isNotEmpty
                              ? CachedNetworkImage(
                                  width: MediaQuery.sizeOf(context).width * 2,
                                  height: MediaQuery.sizeOf(context).height * 2,
                                  fit: BoxFit.cover,
                                  imageUrl: model.auth.me!.image,
                                  errorWidget: (context, url, error) =>
                                      CircleAvatar(
                                    child: Text(model.auth.me!.name[0]),
                                  ),
                                )
                              : CircleAvatar(
                                  radius: MediaQuery.sizeOf(context).height * 2,
                                  child: Text(model.auth.me!.name[0]),
                                ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('My Profile'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProfileScreen(user: model.auth.me),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.edit),
                        title: const Text('Edit Profile'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProfileScreen(user: model.auth.me),
                            ),
                          );
                        },
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: ListTile(
                          leading: const Icon(Icons.settings),
                          title: const Text('Settings'),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const SettingScreenView()),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: ListTile(
                          leading: const Icon(Icons.logout),
                          title: const Text('LogOut'),
                          onTap: () {
                            model.logout(context, navigateToLogin);
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  void navigateToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const LoginScreenView(),
      ),
      (Route<dynamic> route) => false,
    );
  }
}
