// import 'package:chat_up/main.dart';

 import 'dart:developer' as dev;
import 'dart:io';



import 'package:chat_up/api/apis.dart';
import 'package:chat_up/helper/dialogs.dart';
import 'package:chat_up/screens/auth/home_screen.dart';
// import 'package:chat_up/screens/auth/profile_screen.dart';


import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogoVisible = false;
  bool _isButtonVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isLogoVisible = true;
        Future.delayed(const Duration(milliseconds: 550), () {
          setState(() {
            _isButtonVisible = true;
          });
        });
      });
    });
  }

  _handleGoogleBtnClick(){
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);

      if (user != null){
        dev.log('User: ${user.user}');
        dev.log('UserAdditionalInfo: ${user.additionalUserInfo}');

      if ((await APIs.userExists())){
         Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }else {
        await APIs.createUser().then((value){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      
        });
      }
      }

     
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
  try{
    await InternetAddress.lookup('google.com');
    // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // Once signed in, return the UserCredential
  return await APIs.auth.signInWithCredential(credential);
  }
  catch(e){
     dev.log('\n_signInWithGoogle: $e');
    Dialogs.showSnackbar(context, 'Something went wrong(Check Your Intenet!!)');
    return null;
  }
}

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Welcome to ChatUp'),
        backgroundColor:const Color.fromRGBO(141, 188, 236, 1),
      ),
      body: Stack(
        children: [
          // App logo
          Positioned(
            top: mq.height * 0.20,
            right: mq.width * 0.25,
            width: mq.width * 0.5,
            child: AnimatedOpacity(
              opacity: _isLogoVisible ? 1.0 : 0.0,
              duration: const Duration(seconds: 1),
              child: Image.asset('images/icon.png'),
            ),
          ),

          // Google login button
          Positioned(
            bottom: mq.height * 0.20,
            left: mq.width * 0.05,
            width: mq.width * 0.9,
            height: mq.height * 0.06,
            child: AnimatedOpacity(
              opacity: _isButtonVisible ? 1.0 : 0.0,
              duration: const Duration(seconds: 1),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(141, 188, 236, 1),
                  shape: const StadiumBorder(),
                  elevation: 1,
                ),
                onPressed: () {
                  _handleGoogleBtnClick();
                },
                icon: Image.asset('images/google.png', height: mq.height * 0.03),
                label: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    children: [
                      TextSpan(text: 'Log In With '),
                      TextSpan(
                        text: 'Google',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


