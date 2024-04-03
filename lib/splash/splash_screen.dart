import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13283F),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              'assets/logo-white.png',
              fit: BoxFit.contain,
              width: 250,
              height: 250,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    Timer(const Duration(seconds: 4), () => Get.toNamed('/home_screen'));
    super.initState();
  }
}
