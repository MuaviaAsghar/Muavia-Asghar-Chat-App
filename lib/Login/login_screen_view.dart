import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:say_anything_to_muavia/Home/home_screen_view.dart';
import 'package:say_anything_to_muavia/Signup/signup_screen_view.dart';

import '../change_password_outside_app/change_password_outside_app_view.dart';
import '../widgets/text_fields.dart';
import '../widgets/theme.dart';
import '../widgets/theme_provider.dart';
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
    model.password.dispose();
    model.email.dispose();

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
    final bottomInset = View.of(context).viewInsets.bottom;
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
          builder: (BuildContext context) => const HomeScreenView()),
      (Route<dynamic> route) => false,
    );
  }

  void navigateToChangePassword() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const ChangePasswordOutsideAppView()));
  }

  Future<void> navigateToSignupPage() {
    return Navigator.push(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) => const SignupScreenView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child:  Container( decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Provider.of<Themeprovider>(context).themeData == darkmode
                ? [const Color(0xff2b5876), const Color(0xff4e4376)]
                : [const Color(0xfffff1eb), const Color(0xfface0f9)],
          )),
        child: Scaffold(backgroundColor: Colors.transparent,
          appBar: AppBar(
            
            backgroundColor: Colors.transparent,
            title: const Text(
              "ChatApp",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            toolbarHeight: 110,
          ),
          body: Column(
            
            children: [
              Expanded(
                child: Stack(
                
                  children: [
                    Align(                    alignment: Alignment.center,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
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
                                InkWell(
                                  child: TextButton(
                                    onPressed: () {
                                      navigateToChangePassword();
                                    },
                                    child: const Text(
                                      'Forget Password',
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(10),
                            GestureDetector(
                              onTap: () {
                                    model.login(context, navigateToHomePage);
                           
                              },
          
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
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
                    if (!model.isKeyboardVisible)
                      Positioned(
                        top: MediaQuery.of(context).size.height * 7 / 100,
                        left: 20,
                        right: 20,
                        child: AnimatedTextKit(
                          repeatForever: true,
                          animatedTexts: [
                            TyperAnimatedText(
                              "You're on a Login page!",
                              speed: const Duration(milliseconds: 100),
                              curve: Curves.easeInOutBack,
                              textStyle: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (!model.isKeyboardVisible)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("New To This App?"),
                      InkWell(
                        child: GestureDetector(
                          onTap: () {
                            navigateToSignupPage();
                            model.clearText();
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
            ],
          ),
        ),
      ),
    );
  }
}
