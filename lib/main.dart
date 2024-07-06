import 'dart:developer';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:say_anything_to_muavia/Home/home_screen_view.dart';
import 'package:say_anything_to_muavia/Login/login_screen_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Colors/colors.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await _initializeFirebase();

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

  runApp(MyApp(initialScreen: initialScreen));
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

_initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  var result = await FlutterNotificationChannel().registerNotificationChannel(
      description: 'For Showing Message Notification',
      id: 'chats',
      importance: NotificationImportance.IMPORTANCE_HIGH,
      name: 'Chats');

  log('\nNotification Channel Result: $result');
}
