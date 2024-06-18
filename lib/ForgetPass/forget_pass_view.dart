import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:say_anything_to_muavia/ForgetPass/forget_pass_model.dart';
import 'package:say_anything_to_muavia/widgets/text_fields.dart';

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
    model.passwordFocus.addListener(_updateKeyboardVisibility);
    model.confirmPasswordFocus.addListener(_updateKeyboardVisibility);
    model.codeFocus.addListener(_updateKeyboardVisibility);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    model.emailFocus.removeListener(_updateKeyboardVisibility);
    model.passwordFocus.removeListener(_updateKeyboardVisibility);
    model.confirmPasswordFocus.removeListener(_updateKeyboardVisibility);
    model.codeFocus.removeListener(_updateKeyboardVisibility);
    model.emailFocus.dispose();
    model.passwordFocus.dispose();
    model.confirmPasswordFocus.dispose();
    model.codeFocus.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _updateKeyboardVisibility() {
    setState(() {
      model.isKeyboardVisible = model.emailFocus.hasFocus ||
          model.passwordFocus.hasFocus ||
          model.confirmPasswordFocus.hasFocus ||
          model.codeFocus.hasFocus;
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
                        type: 'email',
                        hint: "Enter Your Email",
                        label: 'email',
                        focusNode: model.emailFocus),
                    const Gap(10),
                    if (model.isOtpSent) ...[
                      CustomTextField(
                          type: 'code',
                          hint: "Enter OTP",
                          label: 'OTP',
                          focusNode: model.codeFocus,
                          controller: model.code),
                      const Gap(10),
                      CustomTextField(
                          type: 'password',
                          hint: "Enter New Password",
                          label: 'New Password',
                          focusNode: model.passwordFocus,
                          controller: model.password),
                      const Gap(10),
                      CustomTextField(
                          type: 'password',
                          hint: "Confirm New Password",
                          label: 'Confirm New Password',
                          focusNode: model.confirmPasswordFocus,
                          controller: model.confirmPassword),
                      const Gap(10),
                      GestureDetector(
                        onTap: () {
                          model.resetPassword(context);
                          setState(() {});
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey, width: 1),
                            color: Colors.black,
                          ),
                          child: const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 10),
                              child: Text("Reset Password"),
                            ),
                          ),
                        ),
                      ),
                    ] else
                      GestureDetector(
                        onTap: () {
                          model.forgetPass(context);
                          setState(() {});
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey, width: 1),
                            color: Colors.black,
                          ),
                          child: const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 10),
                              child: Text("Send Mail"),
                            ),
                          ),
                        ),
                      ),
                    // if (model.isOtpSent) ...[
                    //   CustomTextField(
                    //     label: "otp",
                    //     type: 'otp',
                    //     controller: model.code,
                    //     focusNode: model.codeFocus,
                    //     hint: 'OTP Code',
                    //   ),
                    //   const Gap(30),
                    //   CustomTextField(
                    //     hint: "New Password",
                    //     label: 'new password',
                    //     type: 'password',
                    //     controller: model.password,
                    //     focusNode: model.passwordFocus,
                    //   ),
                    //   const Gap(30),
                    //   CustomTextField(
                    //     hint: "Confirm New Password",
                    //     type: 'password',
                    //     label: 'confirm new password',
                    //     controller: model.confirmPassword,
                    //     focusNode: model.confirmPasswordFocus,
                    //   ),
                    //   const Gap(30),
                    // ],
                    ElevatedButton(
                      onPressed: model.isOtpSent
                          ? () => model.resetPassword(context)
                          : () => model.forgetPass(context),
                      child:
                          Text(model.isOtpSent ? 'Reset Password' : 'Send OTP'),
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
                      "You're on a Forget Password Page!",
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
