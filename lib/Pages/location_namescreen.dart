import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart'; // Import the geocoding package

class LocationNameScreen extends StatefulWidget {
  @override
  _LocationNameScreenState createState() => _LocationNameScreenState();
}

class _LocationNameScreenState extends State<LocationNameScreen> {
  String _locationName = "Unknown location";

  // Method to get the location name from latitude and longitude
  Future<void> _getLocationName(double latitude, double longitude) async {
    try {
      // Perform reverse geocoding to get the place name
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

      // Check if we have a valid placemark
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        setState(() {
          _locationName = "${place.locality}, ${place.country}"; // Combine city and country
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Location Name"),
      ),
      body: Center(
        child: Text(
          'Location: $_locationName', // Display the location name
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
