import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:get/route_manager.dart';
import 'package:iconly/iconly.dart';
import 'package:ranyacity/Config/const.dart';
import 'package:ranyacity/Models/onboarding_model.dart';
import 'package:ranyacity/Pages/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentIndex = 0;
  Widget dotIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: EdgeInsets.only(right: 6),
      width: 30,
      height: 5,
      decoration: BoxDecoration(
        color: index == currentIndex ? Colors.white : Colors.white54,
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            PageView.builder(
              itemCount: onboarding.length,
              onPageChanged: (value) {
                setState(() {
                  currentIndex = value;
                });
              },
              itemBuilder: (context, index) {
                return Image.network(
                  onboarding[index].image,
                  fit: BoxFit.cover,
                );
              },
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 50),
                      GestureDetector(
                        onTap: () {
                          Get.off(() => HomeScreen());
                        },
                        child: Visibility(
                          visible: onboarding.length - 1 != currentIndex,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(
                                      0.1), // semi-transparent background
                                  border: Border.all(color: Colors.white54),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  "تێپەڕدان",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "kurdish",
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            onboarding[currentIndex].name,
                            style: TextStyle(
                              fontSize: 70,
                              fontFamily: "kurdish",
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              height: 1,
                            ),
                          ),
                          SizedBox(height: 20),
                          const Text(
                            'بەخێربێن بۆ ڕانیە — تێکەڵەیەکی زیندوو لە نەریت و داهێنان، کە هەموو ئەزموونێک بۆ بەستنەوەی مرۆڤەکان، کولتوور و ئەگەرەکان دروستکراوە.',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: "kurdish",
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 245,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        onboarding.length,
                        dotIndicator,
                      ),
                    ),
                    SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(35),
                      child: Container(
                        padding: EdgeInsets.all(35),
                        height: 220,
                        color: Colors.white,
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setBool('onboarding_seen', true);
                                Get.off(() =>
                                    HomeScreen()); // or login if not logged in
                              },
                              child: Container(
                                height: 75,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      offset: Offset(0, 5),
                                      spreadRadius: 15,
                                      blurRadius: 15,
                                    ),
                                  ],
                                  color: kButtonColor,
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "با دەستپێبکەین",
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "kurdish",
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      Icon(
                                        IconlyLight.arrow_left,
                                        color: Colors.white,
                                        size: 25,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 30),
                            Text(
                              "با بگەڕێین بەناو ڕانیەدا",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontFamily: "kurdish",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
