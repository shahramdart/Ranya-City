import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ranyacity/Pages/home_screen.dart';

class AuthController extends GetxController {
  var email = ''.obs;
  var password = ''.obs;
  var fullName = ''.obs;
  var confirmPassword = ''.obs;
  var isPasswordHidden = true.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void signup() async {
    if (email.value.isEmpty ||
        password.value.isEmpty ||
        confirmPassword.value.isEmpty) {
      Get.snackbar("Error", "All fields are required");
      return;
    }

    if (password.value != confirmPassword.value) {
      Get.snackbar("Error", "Passwords do not match");
      return;
    }

    try {
      Get.dialog(Center(child: CircularProgressIndicator()),
          barrierDismissible: false);

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.value.trim(),
        password: password.value,
      );

      // Automatically login after signup
      login();

      Get.back(); // Close loading
      print("✅ Account created and logged in: ${userCredential.user?.email}");
      Get.snackbar("Success", "Welcome ${userCredential.user?.email}");
    } on FirebaseAuthException catch (e) {
      Get.back(); // Close loading
      print("🔥 FirebaseAuthException: ${e.code} - ${e.message}");
      Get.snackbar("Signup Failed", e.message ?? "Something went wrong");
    } catch (e) {
      Get.back(); // Close loading
      print("❌ Unexpected error: $e");
      Get.snackbar("Error", "An unexpected error occurred");
    }
  }

  void login() async {
    try {
      if (email.value.isEmpty || password.value.isEmpty) {
        Get.snackbar("Error", "Email and password are required");
        return;
      }

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.value.trim(),
        password: password.value.trim(),
      );

      // ✅ SUCCESS LOG
      print("✅ User logged in: ${userCredential.user?.email}");

      Get.snackbar("Success", "User logged in successfully");
      Get.offAll(() => HomeScreen());
    } on FirebaseAuthException catch (e) {
      print("❌ Login Error: ${e.message}");
      Get.snackbar("Login Failed", e.message ?? "Something went wrong");
    }
  }

  void logout() async {
    await _auth.signOut();
    Get.offAllNamed('/');
  }
}
