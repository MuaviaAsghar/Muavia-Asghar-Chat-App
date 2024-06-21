import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:say_anything_to_muavia/Login/login_screen_view.dart';
import 'package:say_anything_to_muavia/widgets/chat_screen.dart';

import '../setting_screen/setting_screen_view.dart';
import 'home_screen_model.dart';

class HomeScreenView extends StatefulWidget {
  const HomeScreenView({super.key});

  @override
  State<HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<HomeScreenView> {
  late HomeScreenModel model;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    model = HomeScreenModel();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await model.fetchUserData();
    setState(() {});
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
        title: const Text("ChatApp"),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: _firestore.collection('UsersList').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found'));
          } else {
            final data = snapshot.data!.docs;
            final nameList = data.map((doc) => doc['name'] as String).toList();
            final lastMessageList =
                data.map((doc) => doc['lastMessage'] as String).toList();

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * .01),
              itemCount: data.length,
              itemBuilder: (context, index) {
                return ChatScreenCard(
                  name: nameList[index],
                  firstLetter: nameList[index][0],
                  lastMessage: lastMessageList[index],
                );
              },
            );
          }
        },
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.black),
              accountName: Text(
                model.name ?? "Loading...",
                style: const TextStyle(fontSize: 18),
              ),
              accountEmail: Text(model.email ?? "Loading..."),
              currentAccountPictureSize: const Size.square(50),
              currentAccountPicture: CircleAvatar(
                child: Text(
                  model.name != null ? model.name![0] : '',
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My Profile'),
              onTap: () {
                // Navigate to Profile Page
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
              onTap: () {
                // Navigate to Edit Profile Page
              },
            ),
            const Spacer(), // This pushes the following ListTile to the bottom
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingScreenView(),
                    ),
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
        ),
      ),
    );
  }
}
