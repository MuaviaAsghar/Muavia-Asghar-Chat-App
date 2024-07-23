import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../widgets/text_fields.dart';
import '../widgets/theme.dart';
import '../widgets/theme_provider.dart';
import 'signup_screen_model.dart';

class SignupScreenView extends StatefulWidget {
  const SignupScreenView({super.key});

  @override
  State<SignupScreenView> createState() => _SignupScreenViewState();
}

class _SignupScreenViewState extends State<SignupScreenView>
    with WidgetsBindingObserver {
  late SignupScreenModel model;

  @override
  void initState() {
    super.initState();
    model = SignupScreenModel();
    model.emailFocus.addListener(_updateKeyboardVisibility);
    model.passwordFocus.addListener(_updateKeyboardVisibility);
    model.nameFocus.addListener(_updateKeyboardVisibility);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    model.emailFocus.removeListener(_updateKeyboardVisibility);
    model.passwordFocus.removeListener(_updateKeyboardVisibility);
    model.nameFocus.removeListener(_updateKeyboardVisibility);
    model.emailFocus.dispose();
    model.passwordFocus.dispose();
    model.nameFocus.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _updateKeyboardVisibility() {
    setState(() {
      model.isKeyboardVisible = model.emailFocus.hasFocus ||
          model.passwordFocus.hasFocus ||
          model.nameFocus.hasFocus;
    });
  }

  @override
  void didChangeMetrics() {
  final bottomInset = View.of(context).viewInsets.bottom;
    setState(() {
      model.isKeyboardVisible = bottomInset > 0;
    });
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
          key: model.scaffoldMessengerKey,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
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
                        type: 'username',
                        hint: "Enter Your Name",
                        label: 'Name',
                        controller: model.name,
                        focusNode: model.nameFocus,
                      ),
                      const Gap(20),
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
                      GestureDetector(
                        onTap: model.isSignupButtonDisabled
                            ? null
                            : () {
                                model.signup(context);
                                setState(() {}); // Trigger rebuild to update UI
                              },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey, width: 1),
                            color: model.isSignupButtonDisabled
                                ? Colors.grey
                                : const Color.fromARGB(255, 255, 255, 255),
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
              if (!model.isKeyboardVisible)
                Positioned(
                  top: MediaQuery.of(context).size.height * 7 / 100,
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
                            fontSize: 30, fontWeight: FontWeight.bold),
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
