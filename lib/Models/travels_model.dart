class TravelDestination {
  final String id; // Add the id field
  final String namePlace;
  final double rate;
  final String description;
  final List<String>? imageUrls;
  final double latitude;
  final double longitude;
  final String category; // Added category field

  TravelDestination({
    required this.id,
    required this.namePlace,
    required this.description,
    required this.rate,
    required this.imageUrls,
    required this.latitude,
    required this.longitude,
    required this.category, // Include category in constructor
  });

  // From map function for Firestore data
  factory TravelDestination.fromMap(
      Map<String, dynamic> map, String documentId) {
    return TravelDestination(
      id: documentId,
      namePlace: map['namePlace'] ?? '',
      description: map['description'] ?? '',
      imageUrls: List<String>.from(map['image_urls'] ?? []),
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      rate: map['rate'] != null
          ? double.tryParse(map['rate'].toString()) ?? 0.0
          : 0.0,
      category: map['category'] ?? '', // Extract category from Firestore map
    );
  }

  // You may also want to convert this object back to a map for Firestore writes
  Map<String, dynamic> toMap() {
    return {
      'namePlace': namePlace,
      'description': description,
      'image_urls': imageUrls,
      'latitude': latitude,
      'longitude': longitude,
      'rate': rate,
      'category': category, // Include category in Firestore write
    };
  }
}
