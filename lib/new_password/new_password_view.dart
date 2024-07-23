import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:say_anything_to_muavia/new_password/new_password_model.dart';
import 'package:say_anything_to_muavia/widgets/text_fields.dart';
import 'package:say_anything_to_muavia/widgets/theme.dart';

import '../widgets/theme_provider.dart';

class NewPasswordView extends StatefulWidget {
  final String email;
  const NewPasswordView({super.key, required this.email});

  @override
  State<NewPasswordView> createState() => _NewPasswordViewState();
}

class _NewPasswordViewState extends State<NewPasswordView>
    with WidgetsBindingObserver {
  late NewPasswordModel model;

  @override
  void initState() {
    super.initState();
    model = NewPasswordModel();
    model.passwordFocus.addListener(_updateKeyboardVisibility);
    model.confirmPasswordFocus.addListener(_updateKeyboardVisibility);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    model.passwordFocus.removeListener(_updateKeyboardVisibility);
    model.confirmPasswordFocus.removeListener(_updateKeyboardVisibility);
    model.passwordFocus.dispose();
    model.confirmPasswordFocus.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _updateKeyboardVisibility() {
    setState(() {
      model.isKeyboardVisible =
          model.passwordFocus.hasFocus || model.confirmPasswordFocus.hasFocus;
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
          appBar: AppBar(backgroundColor: Colors.transparent,
            title: const Text(
              "New Password",
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
                          type: 'password',
                          hint: "Enter New Password",
                          label: 'New Password',
                          controller: model.password,
                          focusNode: model.passwordFocus,
                        ),
                        const Gap(10),
                        CustomTextField(
                          type: 'password',
                          hint: "Confirm New Password",
                          label: 'Confirm Password',
                          controller: model.confirmPassword,
                          focusNode: model.confirmPasswordFocus,
                        ),
                        const Gap(10),
                        GestureDetector(
                          onTap: () async {
                            await model.resetPassword(
                                context, widget.email, model.password.text);
                            if (context.mounted) {
                              model.navigateToHomePage(context);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey, width: 1),
                              color: const Color.fromARGB(255, 255, 255, 255),
                            ),
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 10),
                                child: Text("Update Password"),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
