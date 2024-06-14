import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:say_anything_to_muavia/Login/login_screen_view.dart';

import '../widgets/text_fields.dart';

class OtpScreenView extends StatefulWidget {
  const OtpScreenView({super.key});

  @override
  State<OtpScreenView> createState() => _OtpScreenViewState();
}

class _OtpScreenViewState extends State<OtpScreenView>
    with WidgetsBindingObserver {
  final TextEditingController otp = TextEditingController();

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final EmailOTP myAuth = EmailOTP();
  final FocusNode _otpFocus = FocusNode();

  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();

    _otpFocus.addListener(_updateKeyboardVisibility);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _otpFocus.removeListener(_updateKeyboardVisibility);

    _otpFocus.dispose();
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
      _isKeyboardVisible = _otpFocus.hasFocus;
    });
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
                      type: 'number',
                      hint: "One Time Password",
                      label: 'Email',
                      controller: otp,
                      focusNode: _otpFocus,
                    ),
                    const Gap(10),
                    GestureDetector(
                      onTap: () => myAuth.verifyOTP(otp: otp),
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
            if (!_isKeyboardVisible)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.10,
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

Future<void> navigateToOtpPage(BuildContext context) {
  return Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute<void>(
      builder: (BuildContext context) => const LoginScreenView(),
    ),
    (Route<dynamic> route) => false,
  );
}
