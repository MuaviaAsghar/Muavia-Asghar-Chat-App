import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';
import 'package:say_anything_to_muavia/widgets/theme.dart';

import '../Login/login_screen_view.dart';
import '../Models/json_model.dart';
import '../chat_screen/chat_screen_view.dart';
import '../profile_screen/profile_screen.dart';
import '../setting_screen/setting_screen_view.dart';
import '../widgets/chat_screen.dart';
import '../widgets/theme_provider.dart';
import 'home_screen_model.dart';

class HomeScreenView extends StatefulWidget {
  const HomeScreenView({super.key});

  @override
  State<HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<HomeScreenView> {
  final customcCacheManager = CacheManager(Config('customcachekey',
      stalePeriod: const Duration(days: 30), maxNrOfCacheObjects: 100));

  late final List<ChatUser> _list = [];
  late HomeScreenModel model;
  final List<ChatUser> _searchlist = [];
  bool _isSearching = false;
  List<ChatUser> _allUsers = [];
  List<String> _chatUserIds = [];

  @override
  void initState() {
    super.initState();
    model = HomeScreenModel();
    model.auth.addChatbotUser();
    _loadChatUsers();
  }

  void _showUserDialog(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Select a user to chat with:'),
              const SizedBox(height: 15),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _allUsers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_allUsers[index].name),
                    subtitle: Text(_allUsers[index].email),
                    onTap: () async {
                      await model.addChatUser(_allUsers[index]);
                      if (context.mounted) {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                ChatScreenView(user: _allUsers[index]),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadChatUsers() async {
    List<String> chatUserIds = await model.fetchChatUsers();
    setState(() {
      _chatUserIds = chatUserIds;
    });
  }

  Future<void> _loadAllUsers() async {
    List<ChatUser> allUsers = await model.fetchAllUsers();
    setState(() {
      _allUsers = allUsers;
    });
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
        child: Center(
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: Provider.of<Themeprovider>(context).themeData == darkmode
                  ? [const Color(0xff2b5876), const Color(0xff4e4376)]
                  : [const Color(0xfffff1eb), const Color(0xfface0f9)],
            )),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
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
                            border: InputBorder.none,
                            hintText: 'Name, Email, ...'),
                        autofocus: true,
                        style:
                            const TextStyle(fontSize: 16, letterSpacing: 0.5),
                        onChanged: (val) {
                          _searchlist.clear();
                          for (var i in _list) {
                            if (i.name
                                    .toLowerCase()
                                    .contains(val.toLowerCase()) ||
                                i.email
                                    .toLowerCase()
                                    .contains(val.toLowerCase())) {
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
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  await _loadAllUsers();
                  if (context.mounted) {
                    _showUserDialog(context);
                  }
                },
                child: const Icon(Icons.add),
              ),
              body: StreamBuilder(
                stream: model.auth.getAllUsers(),
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
                      if (_chatUserIds.contains(chatUserModel.id) ||
                          chatUserModel.id == 'chatbot') {
                        _list.add(chatUserModel);
                      }
                    } catch (e) {
                      log("Error parsing document ${doc.id}: ${e.toString()}");
                    }
                  }

                  // Ensure the Chatbot user is always at the top
                  _list.sort((a, b) {
                    if (a.id == 'chatbot') return -1;
                    if (b.id == 'chatbot') return 1;
                    return 0;
                  });

                  if (_list.isEmpty) {
                    return const Center(child: Text("No data found"));
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * .01,
                      ),
                      itemCount:
                          _isSearching ? _searchlist.length : _list.length,
                      itemBuilder: (context, index) {
                        return ChatScreenCard(
                            myuser: _isSearching
                                ? _searchlist[index]
                                : _list[index]);
                      },
                    );
                  }
                },
              ),
              drawer: Drawer(
                child: FutureBuilder(
                  future: model.fetchUserData(),
                  builder:
                      (BuildContext context, AsyncSnapshot<void> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: SizedBox(
                          height: 100,
                          width: 100,
                          child: CircularProgressIndicator(
                            strokeWidth: 10,
                            color: Colors.purple,
                            valueColor: AlwaysStoppedAnimation(Colors.black),
                            semanticsValue: 'Loading',
                            semanticsLabel: 'Loading',
                          ),
                        ),
                      );
                    } else {
                      return Column(
                        children: [
                          UserAccountsDrawerHeader(
                            decoration:
                                const BoxDecoration(color: Colors.black),
                            accountName: Text(
                              model.name ?? 'No Name',
                              style: const TextStyle(fontSize: 18),
                            ),
                            accountEmail: Text(model.email ?? ''),
                            currentAccountPictureSize: const Size.square(50),
                            currentAccountPicture: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  MediaQuery.of(context).size.height * .1),
                              child: model.image != null &&
                                      model.image!.isNotEmpty
                                  ? CachedNetworkImage(
                                      cacheManager: customcCacheManager,
                                      key: UniqueKey(),
                                      width:
                                          MediaQuery.sizeOf(context).width * 2,
                                      height:
                                          MediaQuery.sizeOf(context).height * 2,
                                      fit: BoxFit.cover,
                                      imageUrl: model.image!,
                                      errorWidget: (context, url, error) =>
                                          CircleAvatar(
                                        child: Text(model.name![0]),
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius:
                                          MediaQuery.sizeOf(context).height * 2,
                                      child: Text(model.name![0]),
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
                              title: const Text('Setting'),
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




//   showDialog<String>(
// // Suggested code may be subject to a license. Learn more: ~LicenseLog:74299352.
//                 context: context,
//                 builder: (BuildContext context) => Dialog(
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: <Widget>[
//                         const Text('Select a user to chat with:'),
//                         const SizedBox(height: 15),
//                         ListView.builder(
//                           shrinkWrap: true,
//                           itemCount: _allUsers.length,
//                           itemBuilder: (context, index) {
//                             return ListTile(
//                               title: Text(_allUsers[index].name),
//                               subtitle: Text(_allUsers[index].email),
//                               onTap: () async {
//                                 await model.addChatUser(_allUsers[index]);
//                                 if (context.mounted) {
//                                   Navigator.pop(context);
//                                   Navigator.push(
//                                       context,
//                                       MaterialPageRoute<void>(
//                                           builder: (BuildContext context) =>
//                                               ChatScreenView(
//                                                   user: _allUsers[index])));
//                                 }
//                               },
//                             );
//                           },
//                         ),
//                         TextButton(
//                           onPressed: () {
//                             Navigator.pop(context);
//                           },
//                           child: const Text('Close'),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );