import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:ranyacity/Models/travels_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppServices extends GetxController {
  RxList<TravelDestination> popular = <TravelDestination>[].obs;
  RxList<TravelDestination> recommendate = <TravelDestination>[].obs;
  RxBool _isLoading = false.obs; // Loading state
  RxString noDataMessage = ''.obs; // Proper usage of RxString

  // To hold the selected category
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

  // Getter for loading state
  bool get isLoading => _isLoading.value;

  // Function to fetch places without category filtering
  Future<void> fetchPlaces() async {
    try {
      // Fetch data from Firestore
      QuerySnapshot placesSnapshot =
          await FirebaseFirestore.instance.collection('places').get();

      // Populate the lists with data from Firestore
      popular.value = placesSnapshot.docs
          .map((doc) => TravelDestination.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      recommendate.value = placesSnapshot.docs
          .map((doc) => TravelDestination.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      print("Fetched places: ${recommendate.length}");
    } catch (e) {
      print("Error fetching places: $e");
    }
  }

  Future<void> fetchPlacesByCategory() async {
    _isLoading.value = true; // Set loading state to true before fetching data
    try {
      Query query = FirebaseFirestore.instance.collection('places');

      if (selectedCategory.value != null) {
        query = query.where('category', isEqualTo: selectedCategory.value);
      }

      QuerySnapshot placesSnapshot = await query.get();

      popular.value = placesSnapshot.docs
          .map((doc) => TravelDestination.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      recommendate.value = placesSnapshot.docs
          .map((doc) => TravelDestination.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // Update the noDataMessage outside the UI-building phase
      Future.delayed(Duration.zero, () {
        if (popular.isEmpty && recommendate.isEmpty) {
          noDataMessage.value = "هیچ شوێنێک بۆ ئەم فلتەرکردنە نەدۆزرایەوە";
        } else {
          noDataMessage.value = '';
        }
      });

      print("Fetched filtered places: ${recommendate.length}");
    } catch (e) {
      noDataMessage.value = "Error fetching data";
      print("Error fetching filtered places: $e");
    } finally {
      _isLoading.value = false;
    }
  }

  // Set selected category and fetch filtered data
  void setCategory(String? category) {
    selectedCategory.value = category;
    fetchPlacesByCategory(); // Fetch filtered places when category changes
  }

  Future<List<TravelDestination>> fetchTravelDestinations() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('places').get();

    return querySnapshot.docs.map((doc) {
      return TravelDestination.fromMap(doc.data(), doc.id);
    }).toList();
  }

  RxList<String> favoritePlaces = <String>[].obs;

  bool isFavorite(String placeId) {
    return favoritePlaces.contains(placeId);
  }

  // Load favorites from SharedPreferences
  Future<void> loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedFavorites = prefs.getStringList('favorites') ?? [];
    favoritePlaces.addAll(storedFavorites);
  }

  // Save favorites to SharedPreferences
  Future<void> saveFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favorites', favoritePlaces.toList());
  }

  // Toggle the favorite status of a place
  void toggleFavorite(String placeId) {
    if (favoritePlaces.contains(placeId)) {
      favoritePlaces.remove(placeId); // Remove from favorites
    } else {
      favoritePlaces.add(placeId); // Add to favorites
    }
    saveFavorites(); // Save to SharedPreferences after modification
  }
}
