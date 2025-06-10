import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';


/// --- 1. Utility Functions ---
/// Returns full image path or URL
String getPropertyTypeImage(String iconName) {
  return 'assets/images/$iconName.png';
}


/// Returns correct Image widget (network or asset)
Widget buildImage(BuildContext context, String imageName, {double height = 35}) {
  if (imageName.startsWith('http')) {
    return Image.network(
      imageName,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/images/unknown.png',
          height: height,
          fit: BoxFit.contain,
        );
      },
    );
  } else {
    return Image.asset(
      imageName,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/images/unknown.png',
          height: height,
          fit: BoxFit.contain,
        );
      },
    );
  }
}



/// --- 2. Your Widget ---
/// Example StatefulWidget or StatelessWidget
class PropertyImageListScreen extends StatelessWidget {
  const PropertyImageListScreen({super.key});

  final List<Map<String, String>> propertyTypeModel = const [
    {'name': 'Apartment', 'icon': 'apartment'},
    {'name': 'Studio', 'icon': 'https://akarat.com/assets/media/icons/property-types/studio.png'},
    {'name': 'Unknown', 'icon': 'invalid-icon'}, // For testing fallback
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Property Types')),
      body: ListView.builder(
        itemCount: propertyTypeModel.length,
        itemBuilder: (context, index) {
          final item = propertyTypeModel[index];
          final iconName = item['icon']?.toLowerCase() ?? 'unknown';
          final imageName = getPropertyTypeImage(iconName);

          return ListTile(
            leading: buildImage(context, imageName),
              title: Text(item['name'] ?? 'Unknown'),
          );
        },
      ),
    );
  }
}
