import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ranyacity/Config/app_routes.dart';
import 'package:ranyacity/Pages/Splash/splash_screenda.dart';
import 'package:ranyacity/Services/app_services.dart';
import 'package:ranyacity/Pages/Admin/Auth/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize AppServices and AuthController
  Get.put(AuthController());
  Get.put(AppServices());

  // Load favorites asynchronously
  await Get.find<AppServices>().loadFavorites();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ranya City',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(),
      getPages: AppRoutes.routes,
    );
  }
}
