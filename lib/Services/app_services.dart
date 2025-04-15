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
    'نوسینگە',
    'بازاڕ',
    'سوپەرمارکێت',
    'نەخۆشخانە',
    'یاریگا',
    'مۆڵ',
    'دووکان',
    'پێشانگای ئەلیکترۆنی',
    'مەشتەل',
    'پێشانگای ئۆتۆمبێل',
    'پێشانگای موبلیات',
    'کتێبخانە',
    'هۆڵی وەرزشی',
    'زێڕنگر',
    'دایانگە',
    'پیشەسازی',
    'کۆگا',
    'کارگە',
    'مۆزەخانە',
    'باخچەی ساوایان',
    'ئارایشگا',
    'تەرمیناڵ',
  ];

  // Towns list
  List<String> towns = [
    'ڕانیە',
    'حاجیاوە',
    'چوارقوڕنە',
    'سەنگەسەر',
    'ژاراوە',
    'قەڵادزێ',
  ];

// Selected town (used for uploading or filtering)
  Rx<String?> selectedTown = Rx<String?>(null);

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

  // fetching places by town
  Future<void> fetchPlacesByTown() async {
    _isLoading.value = true;
    try {
      Query query = FirebaseFirestore.instance.collection('places');

      if (selectedTown.value != null) {
        query = query.where('town', isEqualTo: selectedTown.value);
      }

      QuerySnapshot snapshot = await query.get();

      popular.value = snapshot.docs
          .map((doc) => TravelDestination.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      recommendate.value = popular.toList(); // or use another logic

      if (popular.isEmpty) {
        noDataMessage.value = "هیچ شوێنێک بۆ ئەم شارە نەدۆزرایەوە";
      } else {
        noDataMessage.value = '';
      }
    } catch (e) {
      print("Error filtering by town: $e");
      noDataMessage.value = "هەڵەیەک ڕوویدا لە کاتێک فلتەرکردنی شار";
    } finally {
      _isLoading.value = false;
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

  void setTown(String? town) {
    selectedTown.value = town;
    updateAvailableCategoriesForTown();
    fetchPlacesByTownAndCategory();
  }

  Future<void> fetchPlacesByTownAndCategory() async {
    _isLoading.value = true;

    try {
      Query query = FirebaseFirestore.instance.collection('places');

      if (selectedTown.value != null) {
        query = query.where('town', isEqualTo: selectedTown.value); // ✅ fixed
      }

      if (selectedCategory.value != null) {
        query = query.where('category', isEqualTo: selectedCategory.value);
      }

      QuerySnapshot snapshot = await query.get();

      final places = snapshot.docs.map((doc) {
        return TravelDestination.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      popular.value = places;
      recommendate.value = places;

      noDataMessage.value =
          places.isEmpty ? "هیچ شوێنێک بەو فلتەرە نەدۆزرایەوە" : '';
    } catch (e) {
      noDataMessage.value = "هەڵە لە کاتێک فلتەرکردنەوە.";
      print("Error fetching by town & category: $e");
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateAvailableCategoriesForTown() async {
    if (selectedTown.value == null) {
      categoriesForSelectedTown.assignAll(categories);
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('places')
          .where('town', isEqualTo: selectedTown.value) // ✅ fixed
          .get();

      final Set<String> foundCategories = snapshot.docs
          .map((doc) =>
              (doc.data() as Map<String, dynamic>)['category'] as String)
          .toSet();

      categoriesForSelectedTown.assignAll(foundCategories);
    } catch (e) {
      print("Error loading categories for town: $e");
    }
  }

// Add this reactive list at the top:
  RxList<String> categoriesForSelectedTown = <String>[].obs;

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

  // Get Favorite places
  List<TravelDestination> getFavoriteDestinations() {
    return popular.where((place) => favoritePlaces.contains(place.id)).toList();
  }

  void clearFavorites() {
    favoritePlaces.clear();
    saveFavorites(); // persist changes
  }

  // Delete a place from Firestore
  Future<void> deletePlace(String placeId) async {
    try {
      // Delete the place from Firestore
      await FirebaseFirestore.instance
          .collection('places')
          .doc(placeId)
          .delete();

      // Remove the place from the local lists
      popular.removeWhere((place) => place.id == placeId);
      recommendate.removeWhere((place) => place.id == placeId);

      print("Place with ID $placeId deleted successfully");
    } catch (e) {
      print("Error deleting place: $e");
    }
  }
}
