import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_up/api/apis.dart';
import 'package:chat_up/helper/dialogs.dart';
import 'package:chat_up/main.dart';
import 'package:chat_up/models/chat_user.dart';
import 'package:chat_up/screens/auth/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  List<ChatUser> list = [];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        // App bar
        appBar: AppBar(
          title: const Text('User Profile'),
          backgroundColor: const Color.fromRGBO(141, 188, 236, 1),
        ),
        // Button to log out
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.red,
            onPressed: () async {
              Dialogs.showProgressBar(context);
              // Sign out from app
              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  Navigator.pop(context);
                  // For moving to home screen
                  Navigator.pop(context);
                  // Replacing home screen with login screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                });
              });
            },
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ),
        // Body
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(width: mq.width, height: mq.height * .03),
                  // Profile pic
                  Stack(
                    children: [
                      // Profile picture
                      _image !=null ?

                      ClipOval(
                        child: Image.file(
                          File(_image!),
                          width: mq.height * .15,
                          height: mq.height * .15,
                          fit: BoxFit.cover,
                          
                          
                        )
                      )
                      :


                      ClipOval(
                        child: CachedNetworkImage(
                          width: mq.height * .15,
                          height: mq.height * .15,
                          fit: BoxFit.cover,
                          imageUrl: widget.user.image,
                          errorWidget: (context, url, error) => const CircleAvatar(
                            radius: 50,
                            child: Icon(CupertinoIcons.person),
                          ),
                        )
                      ),

                      // Edit image button
                      Positioned(
                        bottom: -5,
                        right: -20,
                        child: MaterialButton(
                          elevation: 1,
                          onPressed: () {
                            _showBottomSheet();
                          },
                          shape: const CircleBorder(),
                          color: Colors.white,
                          child: const Icon(Icons.edit, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: mq.height * .03),
                  Text(
                    widget.user.email,
                    style: const TextStyle(
                        color: Colors.black54, fontSize: 16),
                  ),
                  SizedBox(height: mq.height * .05),
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (val) => APIs.me.name = val ?? '',
                    validator: (val) => val != null && val.isNotEmpty
                        ? null
                        : 'Required Field',
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Name',
                      label: const Text('Name'),
                    ),
                  ),
                  SizedBox(height: mq.height * .02),
                  TextFormField(
                    onSaved: (val) => APIs.me.about = val ?? '',
                    validator: (val) => val != null && val.isNotEmpty
                        ? null
                        : 'Required Field',
                    initialValue: widget.user.about,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                          Icons.info_outline,
                          color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'About',
                      label: const Text('About'),
                    ),
                  ),
                  SizedBox(height: mq.height * .05),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(141, 188, 236, 1),
                      shape: const StadiumBorder(),
                      minimumSize: Size(mq.width * .5, mq.height * .06),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        APIs.updateUserInfo().then((value) {
                          Dialogs.showSnackbar(context, 'Profile Updated Successfully!!!');
                        });
                      }
                    },
                    icon: const Icon(Icons.edit, size: 28, color: Colors.white),
                    label: const Text('UPDATE', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Bottom sheet
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
        return Container(
          height: mq.height * 0.25, // Half the screen height
          child: Column(
            children: [
              SizedBox(height: mq.height * .02),
              const Text(
                'Pick Profile Picture',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: mq.height * .05),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Pick profile picture from gallery
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      fixedSize: Size(mq.width * .3, mq.height * .10),
                    ),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                    // Pick an image.
                    final XFile? image =
                    await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                    if(image !=null){
                      log('Image Path: ${image.path} --MimeType: ${image.mimeType}');
                      setState(() {
                        _image = image.path;
                      });

                      APIs.updateProfilePicture(File(_image!));

                      //for hiding bottom sheet
                      Navigator.pop(context);
                    }
                    },
                    child: Image.asset('images/add_image.png')),

                  // Pick profile picture from camera
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      fixedSize: Size(mq.width * .3, mq.height * .10),
                    ),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                    // Pick an image.
                    final XFile? image =
                    await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                    if(image !=null){
                      log('Image Path: ${image.path}');
                      setState(() {
                        _image = image.path;
                      });

                      APIs.updateProfilePicture(File(_image!));

                      //for hiding bottom sheet
                      Navigator.pop(context);
                    }
                    },
                    child: Image.asset('images/camera.png'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

