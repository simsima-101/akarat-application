import 'package:Akarat/screen/sample.dart';
import 'package:flutter/material.dart';

import '../model/amenities.dart';

class AmenitiesPreview extends StatefulWidget {
  @override
  _AmenitiesPreviewState createState() => _AmenitiesPreviewState();
}

class _AmenitiesPreviewState extends State<AmenitiesPreview> {
  List<Amenities> selectedAmenities = [];
  Set<int> selectedIndexes = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Horizontal selected chips
          SizedBox(height: 50,),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: selectedAmenities.length,
              itemBuilder: (context, index) {
                final item = selectedAmenities[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4)
                    ],
                  ),
                  child: Row(
                    children: [
                      Image.network(item.icon!, height: 18, color: Colors.red),
                      const SizedBox(width: 5),
                      Text(item.title!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              },
            ),
          ),

          // Show all
        /*  Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () async {
               *//* final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AmenitiesFilterScreen(
                      initiallySelected: selectedAmenities,
                    ),
                  ),
                );*//*

                if (result != null && result is List<Amenities>) {
                  setState(() {
                    selectedAmenities = result;
                  });
                }
              },
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text("Show all", style: TextStyle(color: Colors.blue)),
            ),
          ),*/
          Text(selectedIndexes.toString()),
        ],
      ),
    );
  }
}