import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:ranyacity/Config/app_size.dart';
import 'package:ranyacity/Config/const.dart';
import 'package:ranyacity/Config/theme.dart';
import 'package:ranyacity/Models/travels_model.dart';
import 'package:ranyacity/Pages/place_detail.dart';
import 'package:ranyacity/Services/app_services.dart';
import 'package:ranyacity/Widgets/dropdown.dart';
import 'package:ranyacity/Widgets/my_customer_button.dart';
import 'package:ranyacity/Widgets/recomendate.dart';

class FavoriteScreen extends StatefulWidget {
  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final AppServices appServices = Get.find<AppServices>();

  final Rx<String?> selectedTown = Rx<String?>(null);
  final Rx<String?> selectedCategory = Rx<String?>(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(
          'دڵخوزەکان',
          style: TextStyle(
            fontFamily: "kurdish",
            fontSize: 24,
          ),
        ),
        backgroundColor: RiveAppTheme.backgroundWhite,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showFilterBottomSheet(context),
            icon: Icon(IconlyLight.filter),
          ),
          Obx(() {
            return appServices.favoritePlaces.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      Get.defaultDialog(
                        title: "دڵنیایت؟",
                        middleText: "دەتەوێت هەموو دڵخوازەکان بسڕیتەوە؟",
                        textCancel: "نەخێر",
                        textConfirm: "بەڵێ",
                        confirmTextColor: Colors.white,
                        onConfirm: () {
                          appServices.clearFavorites();
                          Get.back();
                        },
                      );
                    },
                    icon: Icon(IconlyBold.delete, color: Colors.red),
                  )
                : SizedBox();
          }),
        ],
      ),
      body: Obx(() {
        List<TravelDestination> favoritePlaces = appServices.popular
            .where((place) =>
                appServices.favoritePlaces.contains(place.id) &&
                (selectedTown.value == null ||
                    place.towns == selectedTown.value) &&
                (selectedCategory.value == null ||
                    place.category == selectedCategory.value))
            .toList();

        if (favoritePlaces.isEmpty) {
          return Center(
            child: Text(
              '! هیچ شوێنێکت بە دڵ نەبووە',
              style: TextStyle(fontSize: 18, fontFamily: "kurdish"),
            ),
          );
        }

        return Directionality(
          textDirection: TextDirection.rtl,
          child: ListView.builder(
            itemCount: favoritePlaces.length,
            itemBuilder: (context, index) {
              final place = favoritePlaces[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlaceDetailScreen(destination: place),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Recomendate(destination: place),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
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
          heightFactor: 0.5,
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
                        SizedBox(height: 10),
                        Obx(() => MyCustomDropDown(
                              menuItemwidth: screenWidth * 0.92,
                              dy: 10,
                              dx: 2,
                              value: selectedTown.value,
                              width: double.infinity,
                              onChanged: (value) {
                                selectedTown.value = value;
                                appServices.selectedTown.value = value;
                                appServices.updateAvailableCategoriesForTown();
                              },
                              items: [
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
                                      ),
                                    ],
                                  ),
                                ),
                                ...appServices.towns
                                    .map((town) => DropdownMenuItem<String>(
                                          value: town,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                town,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontFamily: "kurdish",
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                              ],
                            )),
                        SizedBox(height: 10),
                        Obx(() => MyCustomDropDown(
                              menuItemwidth: screenWidth * 0.92,
                              dy: -40,
                              dx: 2,
                              value: selectedCategory.value,
                              width: double.infinity,
                              onChanged: (value) {
                                selectedCategory.value = value;
                              },
                              items: [
                                DropdownMenuItem<String>(
                                  value: null,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "هەموو ناوچەکان",
                                        style: TextStyle(
                                          fontFamily: "kurdish",
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ...appServices.categoriesForSelectedTown
                                    .map((category) => DropdownMenuItem<String>(
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
                                          ),
                                        )),
                              ],
                            )),
                        SizedBox(height: screenHeight * 0.05),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MyCustomerButton(
                              btnName: 'فلتەرکردن',
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {});
                              },
                              height: AppSizes.blockSizeHorizontal * 12,
                              width: AppSizes.blockSizeHorizontal * 60,
                            ),
                            MyCustomerButton(
                              btnName: 'گەڕانەوە',
                              onTap: () {
                                selectedTown.value = null;
                                selectedCategory.value = null;
                                appServices.selectedTown.value = null;
                                appServices.selectedCategory.value = null;
                                Navigator.pop(context);
                                setState(() {});
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
