import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        backgroundColor: Colors.orange,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text("Welcome!"),
              accountEmail: Text(currentUser?.email ?? 'No email'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.orange),
              ),
              decoration: BoxDecoration(color: Colors.orange),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
              onTap: () {
                Get.back(); // close drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () async {
                await _auth.signOut();
                Get.offAllNamed('/login'); // go to login screen
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          'Welcome to Dashboard!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
