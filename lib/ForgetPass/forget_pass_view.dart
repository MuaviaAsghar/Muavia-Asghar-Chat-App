import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:say_anything_to_muavia/ForgetPass/forget_pass_model.dart';
import 'package:say_anything_to_muavia/widgets/text_fields.dart';
import 'package:say_anything_to_muavia/widgets/theme.dart';
import 'package:say_anything_to_muavia/widgets/theme_provider.dart';

class ForgetPassView extends StatefulWidget {
  const ForgetPassView({super.key});

  @override
  State<ForgetPassView> createState() => _ForgetPassViewState();
}

class _ForgetPassViewState extends State<ForgetPassView>
    with WidgetsBindingObserver {
  late ForgetPassModel model;

  @override
  void initState() {
    super.initState();
    model = ForgetPassModel();
    model.emailFocus.addListener(_updateKeyboardVisibility);
    model.codeFocus.addListener(_updateKeyboardVisibility);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    model.emailFocus.removeListener(_updateKeyboardVisibility);
    model.codeFocus.removeListener(_updateKeyboardVisibility);
    model.emailFocus.dispose();
    model.codeFocus.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _updateKeyboardVisibility() {
    setState(() {
      model.isKeyboardVisible = model.emailFocus.hasFocus || model.codeFocus.hasFocus;
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
      child: Container( decoration: BoxDecoration(
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
                        CustomTextField(
                          type: 'otp',
                          hint: "Enter the OTP",
                          label: 'OTP',
                          controller: model.code,
                          focusNode: model.codeFocus,
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
                        GestureDetector(
                          onTap: () async {
                            await model.verifyOTP(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey, width: 1),
                              color: const Color.fromARGB(255, 255, 255, 255),
                            ),
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                child: Text("Verify OTP"),
                              ),
                            ),
                          ),
                        ),
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
      ),
    );
  }
}