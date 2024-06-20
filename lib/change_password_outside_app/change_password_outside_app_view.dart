import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:say_anything_to_muavia/widgets/text_fields.dart';

import 'change_password_outside_app_model.dart';
class ChangePasswordOutsideAppView extends StatefulWidget {
  const ChangePasswordOutsideAppView({super.key});

  @override
  State<ChangePasswordOutsideAppView> createState() => _ChangePasswordOutsideAppState();
}

class _ChangePasswordOutsideAppState extends State<ChangePasswordOutsideAppView> with WidgetsBindingObserver {
  late ChangePasswordOutsideAppModel model;

  @override
  void initState() {
    super.initState();
    model = ChangePasswordOutsideAppModel();
    model.emailFocus.addListener(_updateKeyboardVisibility);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    model.emailFocus.removeListener(_updateKeyboardVisibility);
    model.emailFocus.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _updateKeyboardVisibility() {
    setState(() {
      model.isKeyboardVisible = model.emailFocus.hasFocus;
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
      child: Scaffold(
        key: model.scaffoldMessengerKey,
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
                child: SingleChildScrollView(
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
                      const Gap(10),
                      GestureDetector(
                        onTap: model.isCooldownActive
                            ? null
                            : () async {
                                await model.sendMail(context);
                              },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey, width: 1),
                            color: model.isCooldownActive
                                ? Colors.grey
                                : const Color.fromARGB(255, 255, 255, 255),
                          ),
                          child: const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                              child: Text("Send Mail"),
                            ),
                          ),
                        ),
                      ),
                      const Gap(10),
                    ],
                  ),
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
                      "You're on a Forget Password Page!",
                      speed: const Duration(milliseconds: 200),
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
    );
  }
}
