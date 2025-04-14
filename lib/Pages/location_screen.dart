// pubspec.yaml dependencies:
// google_maps_flutter: ^2.5.0

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;

  static const LatLng _defaultLatLng = LatLng(36.23998, 44.22457); // Default: Ranya

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
  }

  void _onConfirmLocation() {
    if (_selectedLocation != null) {
      Navigator.pop(context, _selectedLocation);
    } else {
      Get.snackbar("تکایە", "شوێنەکە دیاریبکە");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'دیاریکردنی شوێن',
          style: TextStyle(fontFamily: "kurdish", fontSize: 22),
        ),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _defaultLatLng,
              zoom: 14,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onTap: _onMapTap,
            markers: _selectedLocation != null
                ? {
                    Marker(
                      markerId: MarkerId("selected"),
                      position: _selectedLocation!,
                    ),
                  }
                : {},
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _onConfirmLocation,
              child: Text(
                "پاشەکەوتکردنی شوێن",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: "kurdish",
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}