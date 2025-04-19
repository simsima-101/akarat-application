import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyGoogleMapWidget extends StatelessWidget {
  final double latitude;
  final double longitude;

  const MyGoogleMapWidget({super.key, required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            "Google Map", style: TextStyle(color: Colors.black,
            fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Color(0xFFFFFFFF),
        iconTheme: const IconThemeData(color: Colors.red),
        elevation: 1,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 13.0,
        ),
        markers: {
          Marker(
            markerId: MarkerId('main'),
            position: LatLng(latitude, longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        },
        onMapCreated: (GoogleMapController controller) {},
        zoomControlsEnabled: false,
        myLocationButtonEnabled: false,
      ),
    );
  }
}