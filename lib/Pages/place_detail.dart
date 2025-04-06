// ignore_for_file: unused_field

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:ranyacity/Config/const.dart';
import 'package:ranyacity/Models/travels_model.dart';
import 'package:ranyacity/Pages/Admin/Form/update_place.dart';
import 'package:ranyacity/Services/app_services.dart';
import 'package:url_launcher/url_launcher.dart';

class PlaceDetailScreen extends StatefulWidget {
  final TravelDestination destination;
  const PlaceDetailScreen({super.key, required this.destination});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AppServices appServices = Get.find<AppServices>();
  void openGoogleMaps(double lat, double lng) async {
    final Uri url =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open Google Maps.';
    }
  }

  String _locationName = "Unknown location";

  // Method to get the location name from latitude and longitude
  Future<void> _getLocationName(double latitude, double longitude) async {
    try {
      // Perform reverse geocoding to get the place name
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      // Check if we have a valid placemark
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        setState(() {
          _locationName =
              "${place.locality}, ${place.country}"; // Combine city and country
        });
      }
    } catch (e) {
      setState(() {
        _locationName = "Failed to get location name";
      });
      print("Error getting location name: $e");
    }
  }

  @override
  void initState() {
    super.initState();

    // Example latitude and longitude (New York City)
    double latitude = 40.7128;
    double longitude = -74.0060;

    // Get the location name for the example coordinates
    _getLocationName(latitude, longitude);
  }

  PageController pageController = PageController();
  int pageView = 0;
  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: 64,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Container(
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          "وردەکاری زیاتر",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: "kurdish",
          ),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.all(2),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Distribute space evenly
              children: [
                IconButton(
                  onPressed: () {
                    final placeId = widget.destination.id; // Get the place ID
                    if (appServices.isFavorite(placeId)) {
                      appServices
                          .toggleFavorite(placeId); // Remove from favorites
                    } else {
                      appServices.toggleFavorite(placeId); // Add to favorites
                    }
                  },
                  icon: Obx(() {
                    return Icon(
                      appServices.isFavorite(widget.destination.id)
                          ? IconlyBold.heart
                          : IconlyLight.heart,
                      color: appServices.isFavorite(widget.destination.id)
                          ? Colors.red
                          : Colors.grey, // Red if favorited, grey if not
                    );
                  }),
                ),
                if (currentUser != null) ...[
                  IconButton(
                    onPressed: () {
                      Get.to(() => UpdatePlaceScreen(
                            placeId: widget.destination.id,
                            initialName: widget.destination.namePlace,
                            initialRate: widget.destination.rate,
                            initialDescription: widget.destination.description,
                            initialImageUrls: widget.destination.imageUrls!,
                            initialCategory: widget.destination.category,
                            initialLatitude: widget.destination.latitude,
                            initialLongitude: widget.destination.longitude,
                          ));
                    },
                    icon: Icon(IconlyLight.edit),
                  ),
                  IconButton(
                    onPressed: () {
                      appServices.deletePlace(widget.destination.id);
                      Get.back();
                    },
                    icon: Icon(IconlyLight.delete),
                  ),
                ]
              ],
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        offset: Offset(0, 5),
                        blurRadius: 7,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      children: [
                        PageView(
                          controller: pageController,
                          onPageChanged: (value) {
                            setState(() {
                              pageView = value;
                            });
                          },
                          children: List.generate(
                            widget.destination.imageUrls!.length,
                            (index) => Image.network(
                              fit: BoxFit.cover,
                              widget.destination.imageUrls![index],
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Spacer(),
                            GestureDetector(
                              child: Container(
                                height: 100,
                                width: 100,
                                margin: const EdgeInsets.only(
                                    right: 10, bottom: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 2,
                                    color: Colors.white,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  image: DecorationImage(
                                    image: widget.destination.imageUrls!
                                                    .length -
                                                1 !=
                                            pageView
                                        ? NetworkImage(
                                            widget.destination
                                                .imageUrls![pageView + 1],
                                          )
                                        : NetworkImage(
                                            widget.destination.imageUrls![0],
                                          ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              color: Colors.black.withOpacity(0.8),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(
                                        widget.destination.imageUrls!.length,
                                        (index) => GestureDetector(
                                          onTap: () {
                                            if (pageController.hasClients) {
                                              pageController.animateToPage(
                                                index,
                                                duration: const Duration(
                                                  milliseconds: 500,
                                                ),
                                                curve: Curves.easeInOut,
                                              );
                                            }
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 500),
                                            height: 5,
                                            width: 20,
                                            margin:
                                                const EdgeInsets.only(right: 5),
                                            decoration: BoxDecoration(
                                              color: pageView == index
                                                  ? Colors.white
                                                  : Colors.white
                                                      .withOpacity(0.4),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.6,
                                              child: Text(
                                                widget.destination.namePlace,
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                const Icon(
                                                  Icons.location_on,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  widget.destination.namePlace,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.star_rounded,
                                                  color: Colors.amber[800],
                                                  size: 25,
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  widget.destination.rate
                                                      .toString(),
                                                  style: const TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "دەربارە : \t",
                          style: TextStyle(
                            fontFamily: "kurdish",
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(
                          width: 320,
                          child: Text(
                            widget.destination.description,
                            style: TextStyle(
                              fontFamily: "kurdish",
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 200,
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        // color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          openGoogleMaps(widget.destination.latitude,
                              widget.destination.longitude);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                image: NetworkImage(
                                  'https://sspinnovations.com/wp-content/uploads/2017/12/156274_BlogPostFeatureImage21_120617.jpg',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "بڕۆ بۆ شوێنی مەبەست",
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
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
