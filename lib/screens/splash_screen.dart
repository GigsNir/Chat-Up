// import 'package:chat_up/main.dart';
 import 'dart:developer' as dev;
import 'package:chat_up/api/apis.dart';
import 'package:chat_up/screens/auth/home_screen.dart';
import 'package:chat_up/screens/auth/login_screen.dart';
// import 'package:chat_up/screens/auth/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {

      //exit full screen 
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(systemNavigationBarColor: Colors.white, statusBarColor: Colors.white));

      if (APIs.auth.currentUser != null){
        dev.log('\nUser: ${APIs.auth.currentUser}');
        Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_)=> const HomeScreen()));
    } else{
      Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_)=> const LoginScreen())
        );
    }
      });
      
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
            
              child: Image.asset('images/icon.png'),
          
          ),

          // Google login button
          Positioned(
            bottom: mq.height * 0.15,
            
            width: mq.width,
            
            child: const Text('Made by Gigyasha Niroula',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              letterSpacing: .5,
            ),
            )
            
          ),
        ],
      ),
    );
  }
}