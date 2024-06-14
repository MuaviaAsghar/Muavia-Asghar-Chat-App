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
    // Clear saved credentials
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Sign out from Firebase
    await _auth.signout(context);

    // Navigate to login screen
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
        child: IconButton(
            onPressed: () => _logout(context), icon: const Icon(Icons.logout)),
      ),
    );
  }
}
