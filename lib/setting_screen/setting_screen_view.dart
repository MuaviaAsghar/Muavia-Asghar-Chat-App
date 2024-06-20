import 'package:flutter/material.dart';
import 'package:say_anything_to_muavia/ForgetPass/forget_pass_view.dart';

class SettingScreenView extends StatefulWidget {
  const SettingScreenView({super.key});

  @override
  State<SettingScreenView> createState() => _SettingScreenViewState();
}

class _SettingScreenViewState extends State<SettingScreenView> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text("Setting"),
        centerTitle: true,
      ),
      body: Column(children: [ListTile(title: Text("Setting"),onTap: () =>  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ForgetPassView())),leading: Icon(Icons.settings),trailing: Icon(Icons.arrow_right),)],)
    );
  }
}