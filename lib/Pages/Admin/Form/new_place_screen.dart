// ignore_for_file: unused_local_variable, unnecessary_null_comparison

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart' as path;
import 'package:ranyacity/Config/theme.dart';
import 'package:ranyacity/Widgets/dropdown.dart';
import 'package:ranyacity/Widgets/my_custom_textfield.dart';
import 'package:ranyacity/Widgets/my_customer_button.dart';

class NewPlaceScreen extends StatefulWidget {
  @override
  _NewPlaceScreenState createState() => _NewPlaceScreenState();
}

class _NewPlaceScreenState extends State<NewPlaceScreen> {
  final picker = ImagePicker();
  final namePlaceController = TextEditingController();
  final rateController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationUrlController = TextEditingController();
  bool isUploading = false;

  double? latitude;
  double? longitude;
  List<File> imageFiles = [];

  // Category selection
  Rx<String?> selectedCategory = Rx<String?>(null);

  List<String> categories = [
    'شەقام',
    'خواردنگە',
    'پاڕک',
    'کافێ',
    'مێژوویی',
    'مزگەوت',
    'قوتابخانە',
    'پەیمانگە',
    'گەشتیاری',
    'زانکۆ',
  ];

  @override
  void dispose() {
    namePlaceController.dispose();
    rateController.dispose();
    descriptionController.dispose();
    locationUrlController.dispose();
    super.dispose();
  }

  Future<void> pickImages() async {
    final pickedFiles = await picker.pickMultiImage(imageQuality: 85);

    if (pickedFiles != null) {
      setState(() {
        imageFiles = pickedFiles.map((picked) => File(picked.path)).toList();
      });
    }
  }

  Future<void> getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar("Error", "Location services are disabled.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Get.snackbar("Error", "Location permission denied.");
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });

    print("Location fetched: Latitude = $latitude, Longitude = $longitude");
  }

  Future<void> uploadPlace() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar("Error", "You must be signed in to upload");
      return;
    }

    if (imageFiles.isEmpty ||
        descriptionController.text.isEmpty ||
        namePlaceController.text.isEmpty ||
        latitude == null ||
        longitude == null ||
        selectedCategory == null) {
      Get.snackbar("Error", "All fields including category are required.");
      return;
    }

    try {
      Get.dialog(
        Center(
          child: Lottie.asset(
            'assets/icons/rowLoading.json',
            backgroundLoading: false,
          ),
        ),
        barrierDismissible: false,
      );

      List<String> imageUrls = [];

      for (File imageFile in imageFiles) {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
        final storageRef =
            FirebaseStorage.instance.ref().child('places/$fileName');

        final uploadTask = await storageRef.putFile(imageFile);
        final snapshot = await uploadTask.ref.getDownloadURL();
        imageUrls.add(snapshot);
      }

      final uid = user.uid;
      final rate = double.tryParse(rateController.text) ?? 0.0;
      GeoPoint location = GeoPoint(latitude!, longitude!);

      final data = await FirebaseFirestore.instance.collection('places').add({
        'user_id': uid,
        'namePlace': namePlaceController.text,
        'rate': rate,
        'description': descriptionController.text,
        'image_urls': imageUrls,
        'latitude': latitude,
        'longitude': longitude,
        'category': selectedCategory.value, // Added category field
        'created_at': Timestamp.now(),
      });

      print("✅ Uploaded to Firestore!");
      Get.back();
      Get.snackbar("Success", "Place uploaded!");
      Get.offAllNamed('/home');
    } catch (e) {
      Get.back();
      print("❌ Upload Error: $e");
      Get.snackbar("Error", "Failed to upload place: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "زیادکردنی شوێن",
          style: TextStyle(fontFamily: "kurdish", fontSize: 24),
        ),
        backgroundColor: Colors.white,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(15),
                child: GestureDetector(
                  onTap: pickImages,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      height: 250,
                      width: double.infinity,
                      color: Colors.white,
                      child: imageFiles.isNotEmpty
                          ? GridView.builder(
                              itemCount: imageFiles.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 5,
                                mainAxisSpacing: 5,
                              ),
                              itemBuilder: (context, index) {
                                return Image.file(
                                  imageFiles[index],
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          : Center(
                              child: Text(
                                "وێنە دیاریبکە",
                                style: TextStyle(
                                  fontFamily: "kurdish",
                                  fontSize: 22,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              MyTextFieldIconly(
                icon: Icons.place,
                hintText: "ناوی شوێن",
                controller: namePlaceController,
                vertical_top_icon: 0,
                margin_top: 10,
              ),
              SizedBox(height: 10),
              SizedBox(height: 10),
              Column(
                children: [
                  // Property Type
                  SizedBox(width: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 5),
                      Text(
                        "تکایە بە ژمارە ئامەژە بدە- (5.0)",
                        style: TextStyle(
                          fontFamily: "kurdish",
                          fontSize: 14,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MyTextFieldIconly(
                        icon: IconlyBold.star,
                        hintText: "پێدانی ڕەیتینگ",
                        controller: rateController,
                        vertical_top_icon: 0,
                        margin_top: 0,
                        width: MediaQuery.of(context).size.width * 0.45,
                      ),
                      Obx(() => MyCustomDropDown(
                              dy: -10,
                              value: selectedCategory.value,
                              onChanged: (value) => setState(
                                  () => selectedCategory.value = value),
                              items: [
                                // Placeholder item
                                DropdownMenuItem<String>(
                                  value: null,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "شوێنەکان",
                                        style: TextStyle(
                                          fontFamily: "kurdish",
                                          fontSize: 16,
                                        ),
                                        textDirection: TextDirection.rtl,
                                      ),
                                    ],
                                  ),
                                ),

                                ...categories
                                    .map((category) => DropdownMenuItem(
                                        value: category,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              category,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontFamily: "kurdish",
                                              ),
                                            ),
                                          ],
                                        )))
                                    .toList(),
                              ])),
                    ],
                  )
                ],
              ),
              MyTextFieldIconly(
                margin_top: 15,
                icon: IconlyBold.paper,
                hintText: "دەربارەی شوێن",
                controller: descriptionController,
                maxlines: 3,
                height: 100,
                vertical_top_icon: 40,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyCustomerButton(
                    btnName: isUploading ? "....بارکردن" : "پاشەکەوتکردن",
                    onTap: uploadPlace,
                    width: 220,
                    height: 45,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontFamily: "kurdish",
                    ),
                  ),
                  MyCustomerButton(
                    btnName: "شوێنەکە دیاریبکە",
                    onTap: getLocation,
                    width: 150,
                    height: 45,
                    backgroundButton: RiveAppTheme.accentColor,
                    icon: IconlyBold.location,
                    iconColor: Colors.white,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontFamily: "kurdish",
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
