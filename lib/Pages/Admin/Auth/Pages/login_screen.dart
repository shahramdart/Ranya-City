import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ranyacity/Config/app_routes.dart';
import 'package:ranyacity/Config/const.dart';
import 'package:ranyacity/Pages/Admin/Auth/auth.dart';

class LoginScreen extends StatelessWidget {
  final auth = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Welcome Back!",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),

                // ✅ Email: just use onChanged to store value
                TextField(
                  onChanged: (value) => auth.email.value = value,
                  decoration: InputDecoration(
                    labelText: "Email / Username",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                // ✅ Password field with toggle visibility
                Obx(() => TextField(
                      onChanged: (value) => auth.password.value = value,
                      obscureText: auth.isPasswordHidden.value,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            auth.isPasswordHidden.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: auth.togglePasswordVisibility,
                        ),
                      ),
                    )),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                      onPressed: () {}, child: Text("Forgot Password?")),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: auth.login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kButtonColor,
                    minimumSize: Size(double.infinity, 45),
                  ),
                  child: Text(
                    "Log In",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "English",
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have account? "),
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.signup),
                      child: Text("Sign Up",
                          style: TextStyle(color: Colors.orange)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget socialButton(String text, Color color, IconData icon) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(icon, color: Colors.white),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: Size(double.infinity, 45),
        ),
      ),
    );
  }
}
