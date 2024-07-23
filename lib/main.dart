import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
// Suggested code may be subject to a license. Learn more: ~LicenseLog:3668231451.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:say_anything_to_muavia/Home/home_screen_view.dart';
import 'package:say_anything_to_muavia/Login/login_screen_view.dart';

import 'package:say_anything_to_muavia/widgets/theme_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final savedEmail = prefs.getString('email') ?? '';
  final savedPassword = prefs.getString('password') ?? '';
  final rememberMe = prefs.getBool('remember_me') ?? false;

  Widget initialScreen = const LoginScreenView();

  if (rememberMe && savedEmail.isNotEmpty && savedPassword.isNotEmpty) {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: savedEmail,
        password: savedPassword,
      );
      if (userCredential.user != null) {
        initialScreen = const HomeScreenView();
      }
    } catch (e) {
      // Handle login error here if needed
      log('Auto-login failed: $e');
    }
  }

  runApp(ChangeNotifierProvider(
    create: (context) => Themeprovider(),
    child: MyApp(
      initialScreen: initialScreen,
    ),
  ));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Adaptive Theme Demo',
      theme: Provider.of<Themeprovider>(context).themeData,
      home: initialScreen,
    );
  }
}
