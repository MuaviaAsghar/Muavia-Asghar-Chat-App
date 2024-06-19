import 'dart:developer';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../widgets/text_fields.dart';
import 'otp_screen_model.dart';

class OtpScreenView extends StatefulWidget {
  final String name;
  final String email;
  final String password;

  const OtpScreenView({
    super.key,
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  State<OtpScreenView> createState() => _OtpScreenViewState();
}

class _OtpScreenViewState extends State<OtpScreenView>
    with WidgetsBindingObserver {
  late OtpScreenModel model;

  @override
  void initState() {
    super.initState();
    model = OtpScreenModel();
    model.otpFocus.addListener(_updateKeyboardVisibility);
    WidgetsBinding.instance.addObserver(this);

    model.myAuth.setConfig(
      appEmail: "newgamer445@gmail.com",
      appName: "Chat app",
      userEmail: widget.email,
      otpLength: 6,
      otpType: OTPType.digitsOnly,
    );
    // Send OTP when the screen is initialized
    model.sendOtp(context, widget.email);
  }

  @override
  void dispose() {
    model.otpFocus.removeListener(_updateKeyboardVisibility);
    model.otpFocus.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _updateKeyboardVisibility() {
    setState(() {
      model.isKeyboardVisible = model.otpFocus.hasFocus;
    });
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      type: 'otp',
                      hint: "One Time Password",
                      label: 'OTP',
                      controller: model.otptext,
                      focusNode: model.otpFocus,
                    ),
                    const Gap(10),
                    GestureDetector(
                      onTap: () {
                        log("Verify button tapped");
                        model.verifyOtp(
                          context,
                          widget.name,
                          widget.email,
                          widget.password,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            child: Text("Verify"),
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
                      "Enter your OTP!",
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
