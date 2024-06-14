import 'dart:developer';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:say_anything_to_muavia/Home/home_screen_view.dart';
import 'package:say_anything_to_muavia/Signup/signup_screen_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../authentication/auth.dart';
import '../widgets/text_fields.dart';

class LoginScreenView extends StatefulWidget {
  const LoginScreenView({super.key});

  @override
  State<LoginScreenView> createState() => _LoginScreenViewState();
}

class _LoginScreenViewState extends State<LoginScreenView>
    with WidgetsBindingObserver {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  final _auth = AuthService();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool _isKeyboardVisible = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(_updateKeyboardVisibility);
    _passwordFocus.addListener(_updateKeyboardVisibility);
    _loadSavedCredentials();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _emailFocus.removeListener(_updateKeyboardVisibility);
    _passwordFocus.removeListener(_updateKeyboardVisibility);
    _emailFocus.dispose();
    _passwordFocus.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    setState(() {
      _isKeyboardVisible = bottomInset > 0;
    });
  }

  void _updateKeyboardVisibility() {
    setState(() {
      _isKeyboardVisible = _emailFocus.hasFocus || _passwordFocus.hasFocus;
    });
  }

  void _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email') ?? '';
    final savedPassword = prefs.getString('password') ?? '';
    final rememberMe = prefs.getBool('remember_me') ?? false;

    if (rememberMe) {
      setState(() {
        email.text = savedEmail;
        password.text = savedPassword;
        _rememberMe = rememberMe;
      });
    }
  }

  void _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email.text);
    await prefs.setString('password', password.text);
    await prefs.setBool('remember_me', _rememberMe);
  }

  void _clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');
    await prefs.setBool('remember_me', _rememberMe);
  }

  _login() async {
    final user = await _auth.loginUserWithEmailAndPassword(
      context,
      email.text,
      password.text,
    );

    if (user != null) {
      log("User Logged In");
      if (_rememberMe) {
        _saveCredentials();
      } else {
        _clearCredentials();
      }
      navigateToHomePage(context);
    } else {
      // Handle login error
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "AMA",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          toolbarHeight: 110,
        ),
        body: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      type: 'email',
                      hint: "Enter Your Email",
                      label: 'Email',
                      controller: email,
                      focusNode: _emailFocus,
                    ),
                    const Gap(20),
                    CustomTextField(
                      type: 'password',
                      hint: "Enter Your Password",
                      label: 'Password',
                      controller: password,
                      focusNode: _passwordFocus,
                    ),
                    const Gap(10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value!;
                            });
                          },
                        ),
                        const Text("Remember Me"),
                      ],
                    ),
                    const Gap(10),
                    GestureDetector(
                      onTap: () => _login(),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            child: Text("Login"),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("New To This App?"),
                    InkWell(
                      child: TextButton(
                        onPressed: () {
                          navigateToSignupPage(context);
                        },
                        child: const Text(
                          ' SIGN-UP NOW',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!_isKeyboardVisible)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.10,
                left: 20,
                right: 20,
                child: AnimatedTextKit(
                  repeatForever: true,
                  animatedTexts: [
                    TyperAnimatedText(
                      "You're on a login page!",
                      speed: const Duration(milliseconds: 200),
                      curve: Curves.easeInOutBack,
                      textStyle: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Future<void> navigateToSignupPage(BuildContext context) {
  return Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (BuildContext context) => const SignupScreenView(),
    ),
  );
}

Future<void> navigateToHomePage(BuildContext context) {
  return Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute<void>(
      builder: (BuildContext context) => const HomeScreenView(),
    ),
    (Route<dynamic> route) => false,
  );
}
