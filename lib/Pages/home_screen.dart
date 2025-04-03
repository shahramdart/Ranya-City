import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ranyacity/Config/const.dart';
import 'package:ranyacity/Models/onboarding_model.dart';
import 'package:ranyacity/Pages/place_detail.dart';
import 'package:ranyacity/Widgets/popular_place.dart';
import 'package:ranyacity/Widgets/recomendate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int selectedPage = 0;
  List<IconData> icons = [
    Iconsax.home1,
    Iconsax.search_normal,
    Icons.confirmation_number_outlined,
    Icons.bookmark_outline,
    Icons.person_outline,
  ];
  // for popular ites(filter the popular items only from model)
  // this means only display those data whose category is popular
  List<TravelDestination> popular =
      myDestination.where((element) => element.category == "popular").toList();
  // this means only display those data whose category is recomend
  List<TravelDestination> recomendate =
      myDestination.where((element) => element.category == "recomend").toList();

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text("Welcome!"),
              accountEmail: currentUser != null
                  ? Text(currentUser.email ?? 'No email')
                  : SizedBox.shrink(),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.orange),
              ),
              decoration: BoxDecoration(color: Colors.orange),
            ),
            ListTile(
              leading: Icon(IconlyLight.home),
              title: Text("Home"),
              onTap: () {
                Get.back(); // close drawer
              },
            ),
            if (currentUser != null) ...[
              ListTile(
                leading: Icon(IconlyLight.logout),
                title: Text("Logout"),
                onTap: () async {
                  await _auth.signOut();
                  Get.offAllNamed('/login'); // go to login screen
                },
              ),
            ],
            ListTile(
              leading: Icon(IconlyLight.upload),
              title: Text("New Place"),
              onTap: () {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  Get.toNamed('/newPlace');
                } else {
                  Get.snackbar("Login Required", "Please log in to continue.");
                  Get.toNamed('/login');
                }
              },
            ),
          ],
        ),
      ),
      appBar: headerParts(),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "شوێنە بەناوبانگەکان",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontFamily: "kurdish",
                    ),
                  ),
                  Text(
                    "بینینی زیاتر",
                    style: TextStyle(
                      fontSize: 14,
                      color: blueTextColor,
                      fontFamily: "kurdish",
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 15),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(bottom: 40),
              child: Row(
                children: List.generate(
                  popular.length,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlaceDetailScreen(
                              destination: popular[index],
                            ),
                          ),
                        );
                      },
                      child: PopularPlace(
                        destination: popular[index],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "پێشنیار بۆ ئێوە",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontFamily: "kurdish",
                    ),
                  ),
                  Text(
                    "بینینی زیاتر",
                    style: TextStyle(
                      fontSize: 14,
                      color: blueTextColor,
                      fontFamily: "kurdish",
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: List.generate(
                    recomendate.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PlaceDetailScreen(
                                destination: recomendate[index],
                              ),
                            ),
                          );
                        },
                        child: Recomendate(
                          destination: recomendate[index],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar headerParts() {
    return AppBar(
      title: Text(
        "شاری ڕانیە",
        style: TextStyle(
          fontSize: 22,
          fontFamily: "kurdish",
        ),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      actions: [
        Image.asset('assets/images/Code Craft.png', height: 200),
      ],
    );
  }
}
