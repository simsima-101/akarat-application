import 'package:flutter/material.dart';

class PropertyGrid extends StatelessWidget {
  final List<Map<String, String>> items = [
    {"label": "Property For Rent", "icon": "assets/images/ak-rent-red.png"},
    {"label": "Property For Sale", "icon": "assets/images/ak-sale.png"},
    {"label": "Off-Plan Properties", "icon": "assets/images/ak-off-plan.png"},
    {"label": "Commercial", "icon": "assets/images/commercial_new.png"},
    {"label": "Apartments", "icon": "🏙assets/images/city.png"},
    {"label": "Villas", "icon": "assets/images/villa-new.png"},
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Adjust number of columns based on screen width
    int crossAxisCount = screenWidth > 600 ? 2 : 3;

    return Scaffold(
      appBar: AppBar(title: Text('Responsive Property Grid')),
      body: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              offset: Offset(4, 4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              offset: Offset(-4, -4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
          borderRadius: BorderRadius.circular(12),
        ),
      )
    );
  }
}