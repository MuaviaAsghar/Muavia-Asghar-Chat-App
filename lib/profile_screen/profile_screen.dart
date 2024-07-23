import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Home/home_screen_model.dart';
import '../Login/login_screen_view.dart';
import '../Models/json_model.dart';
import '../authentication/auth.dart';
import '../widgets/dialogs/dialogs.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser? user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final customcCacheManager = CacheManager(Config('customcachekey',
      stalePeriod: const Duration(days: 30), maxNrOfCacheObjects: 1000));
  final _formKey = GlobalKey<FormState>();
  String? _image;
  late HomeScreenModel model;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();
  final String userID = AuthService().user!.uid;

  @override
  void initState() {
    super.initState();
    model = HomeScreenModel();
    loadUserData();
  }

  Future<void> loadUserData() async {
    await model.fetchUserData();
    setState(() {
      // Set the text controllers with the fetched data
      nameController.text = model.name ?? '';
      aboutController.text = model.about ?? '';
    });
  }

  final AuthService _auth = AuthService();
  final storage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        appBar: AppBar(title: const Text('Profile Screen')),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.redAccent,
            onPressed: () async {
              Dialogs.showProgressBar(context);
              logout(context, navigateToLogin);
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.sizeOf(context).width * .05,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    height: MediaQuery.sizeOf(context).height * .03,
                  ),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          MediaQuery.sizeOf(context).height * .1,
                        ),
                        child: model.image != null && model.image!.isNotEmpty
                            ? CachedNetworkImage(
                                cacheManager: customcCacheManager,
                    key: UniqueKey(),
                                width: MediaQuery.sizeOf(context).height * .2,
                                height: MediaQuery.sizeOf(context).height * .2,
                                fit: BoxFit.cover,
                                imageUrl: model.image!,
                                errorWidget: (context, url, error) =>
                                    CircleAvatar(
                                  child: Text(
                                    model.name != null ? model.name![0] : '',
                                  ),
                                ),
                              )
                            : CircleAvatar(
                                radius: MediaQuery.sizeOf(context).height * .1,
                                child: Text(
                                  model.name != null ? model.name![0] : '',
                                ),
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          elevation: 1,
                          onPressed: _showBottomSheet,
                          shape: const CircleBorder(),
                          color: Colors.white,
                          child: const Icon(Icons.edit, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.sizeOf(context).height * .03),
                  Text(
                    widget.user!.email,
                    style: const TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  SizedBox(height: MediaQuery.sizeOf(context).height * .05),
                  TextFormField(
                    controller: nameController,
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'eg. Happy Singh',
                      label: const Text('Name'),
                    ),
                  ),
                  SizedBox(height: MediaQuery.sizeOf(context).height * .02),
                  TextFormField(
                    controller: aboutController,
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                    decoration: InputDecoration(
                      prefixIcon:
                          const Icon(Icons.info_outline, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'eg. Feeling Happy',
                      label: const Text('About'),
                    ),
                  ),
                  SizedBox(height: MediaQuery.sizeOf(context).height * .05),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      minimumSize: Size(
                        MediaQuery.sizeOf(context).width * .5,
                        MediaQuery.sizeOf(context).height * .06,
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        _auth
                            .updateUserInfo(
                                nameController.text, aboutController.text)
                            .then((value) {
                          Dialogs.showSnackbar(
                              context, 'Profile Updated Successfully!');
                        });
                      }
                    },
                    icon: const Icon(Icons.edit, size: 28),
                    label: const Text('UPDATE', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> logout(
      BuildContext context, VoidCallback navigateToLogin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context.mounted) {
      await _auth.signOut(context);
    }
    navigateToLogin();
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

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(
            top: MediaQuery.sizeOf(context).height * .03,
            bottom: MediaQuery.sizeOf(context).height * .05,
          ),
          children: [
            const Text(
              'Pick Profile Picture',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * .02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    fixedSize: Size(
                      MediaQuery.sizeOf(context).width * .3,
                      MediaQuery.sizeOf(context).height * .15,
                    ),
                  ),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      log('Image Path: ${image.path}');
                      setState(() {
                        _image = image.path;
                      });
                      if (mounted) {
                        await _uploadProfilePicture(File(_image!), context);
                      }
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  child: Image.asset('assets/images/add_image.png'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    fixedSize: Size(
                      MediaQuery.sizeOf(context).width * .3,
                      MediaQuery.sizeOf(context).height * .15,
                    ),
                  ),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      log('Image Path: ${image.path}');
                      setState(() {
                        _image = image.path;
                      });
                      if (mounted) {
                        await _uploadProfilePicture(File(_image!), context);
                      }
                      setState(() {});
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  child: Image.asset('assets/images/camera.png'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadProfilePicture(
      File imageFile, BuildContext context) async {
    final user = widget.user;
    if (user != null) {
      try {
        final ref =
            FirebaseStorage.instance.ref().child('profile_pics/${user.id}.jpg');
        await ref.putFile(imageFile);
        final url = await ref.getDownloadURL();
        setState(() {
          _image = url;
        });
        await _auth.updateUserImageURL(
            user.id, url); // Update your user profile with the new URL
        if (context.mounted) {
          Dialogs.showSnackbar(
              context, 'Profile Picture Updated Successfully!');
        }
      } catch (e) {
        log('Error uploading profile picture: $e');
        if (context.mounted) {
          Dialogs.showSnackbar(context, 'Failed to update profile picture');
        }
      }
    }
  }
}
