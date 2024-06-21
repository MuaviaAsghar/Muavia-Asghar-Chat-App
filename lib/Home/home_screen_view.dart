import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:say_anything_to_muavia/Login/login_screen_view.dart';
import 'package:say_anything_to_muavia/setting_screen/setting_screen_view.dart';

import '../chat_screen/chat_screen_view.dart';
import 'home_screen_model.dart';

class HomeScreenView extends StatefulWidget {
  const HomeScreenView({super.key});

  @override
  State<HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<HomeScreenView> {
  late HomeScreenModel model;

  @override
  void initState() {
    super.initState();
    model = HomeScreenModel();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await model.fetchUserData();
    setState(() {});
  }

  void navigateToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const LoginScreenView(),
      ),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       
  actions: [IconButton(onPressed: (){}, icon: Icon(Icons.search))],
        title: const Text("ChatApp"),
        centerTitle: true,
        
      ),
      body: ListView(
        children: [
          ListTile(
            onTap: (){Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const ChatScreenView())) ;},
            leading: CircleAvatar(child: Text(model.name !=null?model.name![0]:''),),
            title: Text(model.name ?? "Loading..."),
            subtitle:const Text("LastMessage"),
            trailing: 
              
              
     
                  const Column(mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                    Text('Last Sent at: 12:00 PM'),
                   Gap(5)
                    ],  
                  ),
            
              ),
         
        
        ]  ),
                   drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.black),
              accountName: Text(
                model.name ?? "Loading...",
                style: const TextStyle(fontSize: 18),
              ),
              accountEmail: Text(model.email ?? "Loading..."),
              currentAccountPictureSize: const Size.square(50),
              currentAccountPicture: CircleAvatar(
                child: Text(
                  model.name != null ? model.name![0] : '',
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My Profile'),
              onTap: () {
                // Navigate to Profile Page
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
              onTap: () {
                // Navigate to Edit Profile Page
              },
            ),
            const Spacer(), // This pushes the following ListTile to the bottom
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingScreenView(),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('LogOut'),
                onTap: () {
                  model.logout(context, navigateToLogin);
                },
              ),
            ),
          ],
        ),
      ),
      
    );
  }
}
