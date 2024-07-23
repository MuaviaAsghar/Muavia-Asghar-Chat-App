import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:say_anything_to_muavia/ForgetPass/forget_pass_view.dart';
import 'package:say_anything_to_muavia/widgets/theme.dart';
import 'package:say_anything_to_muavia/widgets/theme_provider.dart';

class SettingScreenView extends StatefulWidget {
  const SettingScreenView({super.key});

  @override
  State<SettingScreenView> createState() => _SettingScreenViewState();
}

class _SettingScreenViewState extends State<SettingScreenView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Setting"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text("Change Password"),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ForgetPassView(),
              ),
            ),
            trailing: const Icon(Icons.arrow_right),
          ),
          ListTile(
            title: const Text("Change Theme"),
            trailing: Switch(
              value: Provider.of<Themeprovider>(context).themeData == darkmode,
              onChanged: (value) {
                Provider.of<Themeprovider>(context, listen: false)
                    .changeTheme();
              },
            ),
          ),
        ],
      ),
    );
  }
}
