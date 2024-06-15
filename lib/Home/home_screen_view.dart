import 'package:flutter/material.dart';
import 'package:say_anything_to_muavia/Login/login_screen_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../authentication/auth.dart';

class HomeScreenView extends StatefulWidget {
  const HomeScreenView({super.key});

  @override
  State<HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<HomeScreenView> {
  final _auth = AuthService();

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    await _auth.signout(context);

    navigateToLogin(context);
  }

  Future<void> navigateToLogin(BuildContext context) {
    return Navigator.pushAndRemoveUntil(
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
        title: const Text("Home"),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.black),
              accountName: Text(
                "Abhishek Mishra",
                style: TextStyle(fontSize: 18),
              ),
              accountEmail: Text("abhishekm977@gmail.com"),
              currentAccountPictureSize: Size.square(50),
              currentAccountPicture: CircleAvatar(
                child: Text('A'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.workspace_premium),
              title: const Text('Go Premium'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Spacer(), // This pushes the following ListTile to the bottom
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('LogOut'),
                onTap: () {
                  _logout(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
