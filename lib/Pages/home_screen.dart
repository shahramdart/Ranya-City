import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iconly/iconly.dart';
import 'package:ranyacity/Config/app_size.dart';
import 'package:ranyacity/Config/const.dart';
import 'package:ranyacity/Config/theme.dart';
import 'package:ranyacity/Services/app_services.dart'; // Make sure AppServices is imported
import 'package:ranyacity/Pages/place_detail.dart';
import 'package:ranyacity/Widgets/dropdown.dart';
import 'package:ranyacity/Widgets/my_customer_button.dart';
import 'package:ranyacity/Widgets/popular_place.dart';
import 'package:ranyacity/Widgets/recomendate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AppServices appServices =
      Get.find<AppServices>(); // Get AppServices instance

  // Category selection
  Rx<String?> selectedCategory = Rx<String?>(null); // Make sure this is an Rx

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

  Rx<String?> noDataMessage =
      Rx<String?>(null); // Reactive variable for no data message

  @override
  void initState() {
    super.initState();
    appServices.fetchPlaces(); // Fetch places when the screen loads
  }

  // Apply the selected filter
  void _applyFilters() {
    appServices.setCategory(selectedCategory
        .value); // Apply the filter based on the selected category
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    AppSizes().init(context);

    return Scaffold(
        backgroundColor: kBackgroundColor,
        drawer: Drawer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment
                .start, // Align items to the left for better readability
            children: [
              UserAccountsDrawerHeader(
                accountName: Text("Welcome!"),
                accountEmail: currentUser != null
                    ? Text(currentUser.email ?? '')
                    : SizedBox.shrink(),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Center(
                    child: Image.asset('assets/images/Code Craft.png'),
                  ),
                ),
                decoration: BoxDecoration(color: Colors.orange),
              ),
              ListTile(
                leading: Icon(IconlyLight.home),
                title: Text("Home"),
                onTap: () {
                  Get.back(); // Close drawer
                },
              ),
              // Show 'New Place' and 'Logout' if user is logged in
              if (currentUser != null) ...[
                ListTile(
                  leading: Icon(IconlyLight.logout),
                  title: Text("Logout"),
                  onTap: () async {
                    await _auth.signOut();
                    Get.offAllNamed('/'); // Go to login screen
                  },
                ),
                ListTile(
                  leading: Icon(IconlyLight.upload),
                  title: Text("New Place"),
                  onTap: () {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      Get.toNamed('/newPlace');
                    } else {
                      Get.snackbar(
                        "Login Required",
                        "Please log in to continue.",
                      );
                      Get.toNamed('/login');
                    }
                  },
                ),
              ],
              // Show 'Login' if no user is logged in
              if (currentUser == null) ...[
                ListTile(
                  leading: Icon(IconlyLight.login),
                  title: Text("Login"),
                  onTap: () {
                    Get.toNamed('/login');
                  },
                ),
              ],
            ],
          ),
        ),
        appBar: headerParts(),
        body: Obx(() {
          if (appServices.noDataMessage.value.isNotEmpty == true) {
            return Center(
              child: Text(
                appServices.noDataMessage.value,
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: "kurdish",
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            );
          } else if (appServices.isLoading) {
            // Show loading spinner while loading
            return Center(child: CircularProgressIndicator());
          } else {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Stack(
                children: [
                  // Main content (Column)
                  Column(
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
                      // Use Obx to listen to changes in the lists
                      Obx(() {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(bottom: 40),
                          child: Row(
                            children: List.generate(
                              appServices.popular.length,
                              (index) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PlaceDetailScreen(
                                          destination:
                                              appServices.popular[index],
                                        ),
                                      ),
                                    );
                                  },
                                  child: PopularPlace(
                                    destination: appServices.popular[index],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
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
                      Expanded(child: Obx(() {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            children: List.generate(
                              appServices.recommendate.length,
                              (index) => Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PlaceDetailScreen(
                                          destination:
                                              appServices.recommendate[index],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Recomendate(
                                    destination:
                                        appServices.recommendate[index],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      })),
                    ],
                  ),
                ],
              ),
            );
          }
        }));
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
        IconButton(
          onPressed: _showFilterModal,
          icon: Icon(
            IconlyBold.filter_2,
          ),
        ),
      ],
    );
  }

  // Filter modal to choose category and apply filter
  void _showFilterModal() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.4,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: StatefulBuilder(
              builder: (context, setState) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "فلتەرکردن",
                              style: TextStyle(
                                fontSize: 22,
                                fontFamily: "kurdish",
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: AppSizes.blockSizeHorizontal * 22,
                              child: Divider(
                                color: RiveAppTheme.backgroundDark,
                                thickness: 1.5,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSizes.blockSizeHorizontal * 5),

                        Obx(
                          () => MyCustomDropDown(
                              menuItemwidth: screenWidth * 0.92,
                              dy: -20,
                              dx: 2,
                              value: selectedCategory.value,
                              width: double.infinity,
                              onChanged: (value) {
                                selectedCategory.value = value;
                              },
                              items: [
                                // Placeholder item
                                DropdownMenuItem<String>(
                                  value: null,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "هەموو شوێنەکان",
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
                                            Text(category,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontFamily: "kurdish")),
                                          ],
                                        )))
                                    .toList(),
                              ]),
                        ),
                        SizedBox(height: screenHeight * 0.1),

                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MyCustomerButton(
                              btnName: 'فلتەرکردن',
                              onTap: () {
                                Navigator.pop(context);
                                _applyFilters();
                              },
                              height: AppSizes.blockSizeHorizontal * 12,
                              width: AppSizes.blockSizeHorizontal * 60,
                            ),
                            MyCustomerButton(
                              btnName: 'گەڕانەوە',
                              onTap: () {
                                appServices.selectedCategory.value =
                                    null; // Reset category
                                selectedCategory.value =
                                    null; // Reset the local category
                                appServices
                                    .fetchPlacesByCategory(); // Fetch filtered places based on category
                                Get.back();
                              },
                              height: AppSizes.blockSizeHorizontal * 12,
                              width: AppSizes.blockSizeHorizontal * 30,
                              backgroundButton: RiveAppTheme.backgroundWhite,
                              style: TextStyle(
                                fontSize: 24,
                                color: RiveAppTheme.backgroundDark,
                                fontFamily: "kurdish",
                              ),
                              border: Border.all(
                                color: RiveAppTheme.backgroundDark,
                                width: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
