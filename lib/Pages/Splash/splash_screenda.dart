// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ranyacity/Pages/home_screen.dart';
import 'package:ranyacity/Pages/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _checkRoute();
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  void _checkRoute() async {
    await Future.delayed(Duration(milliseconds: 500));
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('onboarding_seen') ?? false;
    final loggedIn = FirebaseAuth.instance.currentUser != null;

    // print('DEBUG => onboarding_seen: \$seen, loggedIn: \$loggedIn');
    final user = FirebaseAuth.instance.currentUser;

    if (loggedIn) {
      print("✅ User is already logged in: ${user!.email}");
      Get.offAll(() => HomeScreen());
    } else {
      Get.offAll(() => OnboardingScreen());
    }
  }
}
