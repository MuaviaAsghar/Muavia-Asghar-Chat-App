import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:say_anything_to_muavia/Home/home_screen_view.dart';
import 'package:say_anything_to_muavia/Login/login_screen_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Colors/colors.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) async {
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseFirestore.instance;

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
        print('Auto-login failed: $e');
      }
    }

    runApp(MyApp(initialScreen: initialScreen));
  });
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: CustomColors.colors.secondaryColor,
      ),
      dark: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: CustomColors.colors.primaryColor,
      ),
      initial: AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => MaterialApp(
        title: 'Adaptive Theme Demo',
        theme: theme,
        darkTheme: darkTheme,
        home: initialScreen,
      ),
    );
  }
}
