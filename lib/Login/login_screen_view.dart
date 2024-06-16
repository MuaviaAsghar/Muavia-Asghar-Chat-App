import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:say_anything_to_muavia/Home/home_screen_view.dart';
import 'package:say_anything_to_muavia/Signup/signup_screen_view.dart';

import '../widgets/text_fields.dart';
import 'login_screen_model.dart';

class LoginScreenView extends StatefulWidget {
  const LoginScreenView({super.key});

  @override
  State<LoginScreenView> createState() => _LoginScreenViewState();
}

class _LoginScreenViewState extends State<LoginScreenView>
    with WidgetsBindingObserver {
  late LoginScreenModel model;

  @override
  void initState() {
    super.initState();
    model = LoginScreenModel();
    model.emailFocus.addListener(_updateKeyboardVisibility);
    model.passwordFocus.addListener(_updateKeyboardVisibility);
    model.loadSavedCredentials(_updateCredentials);

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    model.emailFocus.removeListener(_updateKeyboardVisibility);
    model.passwordFocus.removeListener(_updateKeyboardVisibility);
    model.emailFocus.dispose();
    model.passwordFocus.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _updateKeyboardVisibility() {
    setState(() {
      model.isKeyboardVisible =
          model.emailFocus.hasFocus || model.passwordFocus.hasFocus;
    });
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    setState(() {
      model.isKeyboardVisible = bottomInset > 0;
    });
  }

  void _updateCredentials(String email, String password, bool rememberMe) {
    setState(() {
      model.email.text = email;
      model.password.text = password;
      model.rememberMe = rememberMe;
    });
  }

  void navigateToHomePage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const HomeScreenView(),
      ),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> navigateToSignupPage() {
    return Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const SignupScreenView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "ChatApp",
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
                      controller: model.email,
                      focusNode: model.emailFocus,
                    ),
                    const Gap(20),
                    CustomTextField(
                      type: 'password',
                      hint: "Enter Your Password",
                      label: 'Password',
                      controller: model.password,
                      focusNode: model.passwordFocus,
                    ),
                    const Gap(10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: model.rememberMe,
                          onChanged: (value) {
                            setState(() {
                              model.rememberMe = value!;
                            });
                          },
                        ),
                        const Text("Remember Me"),
                      ],
                    ),
                    const Gap(10),
                    GestureDetector(
                      onTap: () => model.login(context, navigateToHomePage),
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
                          navigateToSignupPage();
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
            if (!model.isKeyboardVisible)
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
