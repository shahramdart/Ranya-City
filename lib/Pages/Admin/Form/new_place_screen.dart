import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;

class NewPlaceScreen extends StatefulWidget {
  @override
  _NewPlaceScreenState createState() => _NewPlaceScreenState();
}

class _NewPlaceScreenState extends State<NewPlaceScreen> {
  File? imageFile;
  final picker = ImagePicker();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationUrlController = TextEditingController();

  Future<void> pickImage() async {
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  Future<void> uploadPlace() async {
    if (imageFile == null ||
        titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        locationUrlController.text.isEmpty) {
      Get.snackbar("Error", "All fields are required.");
      return;
    }

    try {
      Get.dialog(Center(child: CircularProgressIndicator()),
          barrierDismissible: false);

      // ✅ Generate a unique file name
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile!.path)}';

      final storageRef =
          FirebaseStorage.instance.ref().child('places/$fileName');

      // ✅ Upload the image and await completion
      final uploadTask = await storageRef.putFile(imageFile!);
      final snapshot = await uploadTask.ref.getDownloadURL();

      final imageUrl = snapshot;
      final uid = FirebaseAuth.instance.currentUser?.uid;

      // ✅ Save to Firestore
      final data = await FirebaseFirestore.instance.collection('places').add({
        'user_id': uid,
        'title': titleController.text,
        'description': descriptionController.text,
        'location_url': locationUrlController.text,
        'image_url': imageUrl,
        'created_at': Timestamp.now(),
      });

      print("✅ Uploaded to Firestore!");
      print("📄 ID: ${data.id}");
      print("📍 Path: ${data.path}");

      final docSnapshot = await data.get();
      print("📦 Data: ${docSnapshot.data()}");

      Get.back(); // Close loading
      Get.snackbar("Success", "Place uploaded!");
      Get.back(); // Navigate back
    } catch (e) {
      Get.back();
      print("❌ Upload Error: $e");
      Get.snackbar("Error", e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add New Place")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                color: Colors.grey[300],
                child: imageFile != null
                    ? Image.file(imageFile!, fit: BoxFit.cover)
                    : Center(child: Text("Tap to pick image")),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: "Title"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: "Description"),
              maxLines: 3,
            ),
            SizedBox(height: 10),
            TextField(
              controller: locationUrlController,
              decoration: InputDecoration(labelText: "Location URL"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: uploadPlace,
              child: Text("Upload"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: Size(double.infinity, 50),
              ),
            )
          ],
        ),
      ),
    );
  }
}
