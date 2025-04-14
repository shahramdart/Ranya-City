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

class UpdatePlaceScreen extends StatefulWidget {
  final String placeId;
  final String initialName;
  final double initialRate;
  final String initialDescription;
  final List<String> initialImageUrls;
  final String initialCategory;
  final String initialTowns;
  final double initialLatitude;
  final double initialLongitude;

  const UpdatePlaceScreen({
    super.key,
    required this.placeId,
    required this.initialName,
    required this.initialRate,
    required this.initialDescription,
    required this.initialImageUrls,
    required this.initialTowns,
    required this.initialCategory,
    required this.initialLatitude,
    required this.initialLongitude,
  });

  @override
  _UpdatePlaceScreenState createState() => _UpdatePlaceScreenState();
}

class _UpdatePlaceScreenState extends State<UpdatePlaceScreen> {
  final picker = ImagePicker();
  final namePlaceController = TextEditingController();
  final rateController = TextEditingController();
  final descriptionController = TextEditingController();
  bool isUploading = false;

  double? latitude;
  double? longitude;
  List<File> imageFiles = [];

  // Reactive list for image URLs
  RxList<String> imageUrls = <String>[].obs; // Use RxList for imageUrls

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
    'نوسینگە',
    'بازاڕ',
    'سوپەرمارکێت',
    'کتێبخانە',
    'مۆزەخانە',
  ];

  // town selection
  Rx<String?> selectedTown = Rx<String?>(null);

  List<String> towns = [
    'ڕانیە',
    'حاجیاوە',
    'چوارقوڕنە',
    'سەنگەسەر',
    'ژاراوە',
    'قەڵادزێ',
  ];

  @override
  void initState() {
    super.initState();
    namePlaceController.text = widget.initialName;
    rateController.text = widget.initialRate.toString();
    descriptionController.text = widget.initialDescription;
    selectedCategory.value = widget.initialCategory;
    selectedTown.value = widget.initialTowns;
    latitude = widget.initialLatitude;
    longitude = widget.initialLongitude;
    imageUrls.value =
        List.from(widget.initialImageUrls); // Set initial image URLs
  }

  @override
  void dispose() {
    namePlaceController.dispose();
    rateController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // Pick new images
  Future<void> pickImages() async {
    final pickedFiles = await picker.pickMultiImage(imageQuality: 85);
    if (pickedFiles != null) {
      setState(() {
        imageFiles = pickedFiles.map((picked) => File(picked.path)).toList();
      });
    }
  }

  // Delete an image
  Future<void> deleteImage(int index) async {
    try {
      String imageUrl = imageUrls[index];

      // Delete from Firebase Storage
      final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      await storageRef.delete();

      // Remove the image from the list
      imageUrls.removeAt(
          index); // This will automatically update the UI due to RxList
      Get.snackbar("Success", "Image deleted successfully.");
    } catch (e) {
      print("Error deleting image: $e");
      Get.snackbar("Error", "Failed to delete image.");
    }
  }

  // Update the place
  Future<void> updatePlace() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar("Error", "You must be signed in to update");
      return;
    }

    if (imageFiles.isEmpty) {
      Get.snackbar("هەڵە", "وێنەی شوێنەکە پێویستە دەستنیشان بکەی.");
      return;
    }
    if (namePlaceController.text.isEmpty) {
      Get.snackbar("هەڵە", "ناوی شوێنەکە پێویستە.");
      return;
    }

    if (latitude == null || longitude == null) {
      Get.snackbar("هەڵە", "ناونیشانی شوێنەکە (نەخشە) پێویستە.");
      return;
    }
    if (selectedCategory == null) {
      Get.snackbar("هەڵە", "جۆری شوێنەکە پێویستە.");
      return;
    }
    if (selectedTown == null) {
      Get.snackbar("هەڵە", "شارەکە پێویستە.");
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

      List<String> updatedImageUrls = List.from(imageUrls);

      if (imageFiles.isNotEmpty) {
        // Upload new images
        for (File imageFile in imageFiles) {
          final fileName =
              '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
          final storageRef =
              FirebaseStorage.instance.ref().child('places/$fileName');

          final uploadTask = await storageRef.putFile(imageFile);
          final snapshot = await uploadTask.ref.getDownloadURL();
          updatedImageUrls.add(snapshot); // Add new image URL to the list
        }
      }

      final uid = user.uid;
      final rate = double.tryParse(rateController.text) ?? widget.initialRate;
      GeoPoint location = GeoPoint(latitude!, longitude!);

      final data = await FirebaseFirestore.instance
          .collection('places')
          .doc(widget.placeId)
          .update({
        'user_id': uid,
        'namePlace': namePlaceController.text,
        'rate': rate,
        'description': descriptionController.text,
        'image_urls': updatedImageUrls,
        'latitude': latitude,
        'longitude': longitude,
        'category': selectedCategory.value,
        'towns': selectedTown.value,
        'updated_at': Timestamp.now(),
      });

      print("✅ Updated to Firestore!");
      Future.delayed(Duration.zero, () {
        Get.back();
        Get.snackbar("Success", "Place updated!");
        Get.offAllNamed('/home');
      });
    } catch (e) {
      Get.back();
      print("❌ Update Error: $e");
      Get.snackbar("Error", "Failed to update place: $e");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "نوێکردنەوەی شوێن",
          style: TextStyle(fontFamily: "kurdish", fontSize: 24),
        ),
        backgroundColor: Colors.white,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              // Image Selection
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
                              child: Icon(
                                Icons.add,
                                size: 30,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Current Images
              // ✅ Fixed (reactive)
              Obx(() => Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(
                      imageUrls.length,
                      (index) => Stack(
                        children: [
                          Image.network(
                            imageUrls[index],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteImage(index),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
              SizedBox(height: 20),
              MyTextFieldIconly(
                icon: Icons.place,
                hintText: "ناوی شوێن",
                controller: namePlaceController,
                vertical_top_icon: 0,
                margin_top: 10,
              ),
              SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => MyCustomDropDown(
                        dy: -10,
                        value: selectedCategory.value,
                        onChanged: (value) => selectedCategory.value =
                            value, // Directly update reactive variable
                        items: categories
                            .map((category) => DropdownMenuItem<String>(
                                  value: category,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(category,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontFamily: "kurdish")),
                                    ],
                                  ),
                                ))
                            .toList(),
                      )),
                  Obx(() => MyCustomDropDown(
                        dy: -10,
                        value: selectedTown.value,
                        onChanged: (value) => selectedTown.value =
                            value, // Directly update reactive variable
                        items: towns
                            .map((category) => DropdownMenuItem<String>(
                                  value: category,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(category,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontFamily: "kurdish")),
                                    ],
                                  ),
                                ))
                            .toList(),
                      )),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  MyTextFieldIconly(
                    icon: IconlyBold.star,
                    hintText: "پێدانی ڕەیتینگ",
                    controller: rateController,
                    vertical_top_icon: 0,
                    margin_top: 15,
                    width: MediaQuery.of(context).size.width * 0.45,
                  ),
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
                    btnName: isUploading ? "....بارکردن" : "نوێکردنەوەی شوێن",
                    onTap: updatePlace,
                    width: 220,
                    height: 45,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontFamily: "kurdish"),
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
                        fontFamily: "kurdish"),
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
