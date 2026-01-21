import 'package:flutter/material.dart';
import '../core/constants/constants.dart' as ApiService;


// --- 1. Utility Functions ---

/// Returns full image path/URL depending on whether it's local asset or remote
String getPropertyTypeImage(String iconPath) {
  final trimmed = iconPath.trim();

  // Case 1: Already full URL (http/https)
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }

  // Case 2: Relative path from backend (e.g. /assets/media/icons/... )
  if (trimmed.startsWith('/')) {
    // Use current API base (works for both prod & qa)
    final base = ApiService.baseUrl.replaceAll(RegExp(r'/api/?$'), '');
    return '$base$trimmed';
  }

  // Case 3: Local asset name (e.g. 'apartment')
  return 'assets/images/$trimmed.png';
}

/// Builds correct Image widget (network or asset) with fallback
Widget buildPropertyTypeImage(
    BuildContext context,
    String imagePath, {
      double height = 35,
      double width = 35,
    }) {
  final fullPath = getPropertyTypeImage(imagePath);

  if (fullPath.startsWith('http')) {
    return Image.network(
      fullPath,
      height: height,
      width: width,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/images/unknown.png',
          height: height,
          width: width,
          fit: BoxFit.contain,
        );
      },
    );
  }

  // Assume it's local asset
  return Image.asset(
    fullPath,
    height: height,
    width: width,
    fit: BoxFit.contain,
    errorBuilder: (context, error, stackTrace) {
      return Image.asset(
        'assets/images/unknown.png',
        height: height,
        width: width,
        fit: BoxFit.contain,
      );
    },
  );
}

// --- 2. Your Screen ---

class PropertyImageListScreen extends StatelessWidget {
  const PropertyImageListScreen({super.key});

  // Example data - you can move this to model/provider later
  static const List<Map<String, String>> propertyTypeModel = [
    {'name': 'Apartment', 'icon': 'apartment'}, // local asset
    {
      'name': 'Studio',
      'icon': '/assets/media/icons/property-types/studio.png'
    }, // relative from backend
    {'name': 'Villa', 'icon': 'villa'}, // local asset
    {
      'name': 'Building',
      'icon': '/assets/images/building.png'
    }, // relative (testing fallback)
    {'name': 'Invalid', 'icon': 'invalid-icon'}, // will show fallback
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Types'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: propertyTypeModel.length,
        itemBuilder: (context, index) {
          final item = propertyTypeModel[index];
          final iconPath = item['icon'] ?? 'unknown';

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: buildPropertyTypeImage(
                context,
                iconPath,
                height: 40,
                width: 40,
              ),
              title: Text(
                item['name'] ?? 'Unknown Type',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                iconPath.startsWith('http') || iconPath.startsWith('/')
                    ? 'Remote icon'
                    : 'Local asset',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}