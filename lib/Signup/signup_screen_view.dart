import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../otp_screen.dart/otp_screen_view.dart';
import '../widgets/text_fields.dart';

class SignupScreenView extends StatefulWidget {
  const SignupScreenView({super.key});

  @override
  State<SignupScreenView> createState() => _SignupScreenViewState();
}

class _SignupScreenViewState extends State<SignupScreenView>
    with WidgetsBindingObserver {
  final _auth = FirebaseAuth.instance;
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController name = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final EmailOTP myAuth = EmailOTP();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(_updateKeyboardVisibility);
    _passwordFocus.addListener(_updateKeyboardVisibility);
    _nameFocus.addListener(_updateKeyboardVisibility);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _emailFocus.removeListener(_updateKeyboardVisibility);
    _passwordFocus.removeListener(_updateKeyboardVisibility);
    _nameFocus.removeListener(_updateKeyboardVisibility);
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _nameFocus.dispose();
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
      _isKeyboardVisible = _emailFocus.hasFocus ||
          _passwordFocus.hasFocus ||
          _nameFocus.hasFocus;
    });
  }

  Future<void> navigateToOtpPage(
      BuildContext context, String email, String password) {
    return Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => OtpScreenView(
          email: email,
          password: password,
        ),
      ),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _signup() async {
    try {
      String emailText = email.text.trim();
      String passwordText = password.text.trim();

      if (!_validateEmail(emailText)) {
        _showError("Invalid email address.");
        return;
      }

      if (!_validatePassword(passwordText)) {
        _showError("Password must be at least 6 characters.");
        return;
      }

      // Configure EmailOTP
      myAuth.setConfig(
        appEmail: "newgamer445@gmail.com",
        appName: "Free Niggas",
        userEmail: emailText,
        otpLength: 6,
        otpType: OTPType.digitsOnly,
      );

      bool otpSent = await myAuth.sendOTP();
      if (otpSent) {
        navigateToOtpPage(context, emailText, passwordText);
      } else {
        _showError("Failed to send OTP.");
      }
    } catch (e) {
      _showError("Failed to create user: ${e.toString()}");
      print(e);
    }
  }

  bool _validateEmail(String email) {
    return email.contains('@');
  }

  bool _validatePassword(String password) {
    return password.length >= 6;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
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
                      type: 'username',
                      hint: "Enter Your Name",
                      label: 'Name',
                      controller: name,
                      focusNode: _nameFocus,
                    ),
                    const Gap(20),
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
                    GestureDetector(
                      onTap: () => _signup(),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            child: Text("Signup"),
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
                      "You're on a Sign-up page!",
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
