import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/utils/secure_storage.dart';
import '../providers/favorite_provider.dart';

import '../features/property/data/datasources/favorite_remote_datasource.dart';

class FavoriteIconButton extends StatelessWidget {
  final String? propertyId;
  final VoidCallback? onLoginRequired;

  const FavoriteIconButton({
    super.key,
    required this.propertyId,
    this.onLoginRequired,
  });

  @override
  Widget build(BuildContext context) {
    // Safely parse property ID
    final int parsedId = int.tryParse(propertyId ?? '') ?? 0;
    final isSaved = context.watch<FavoriteProvider>().isFavorite(parsedId);

    return IconButton(
      icon: Icon(
        isSaved ? Icons.favorite : Icons.favorite_border,
        color: isSaved ? Colors.red : Colors.grey,
        size: 24, // You can adjust this globally
      ),
      onPressed: () async {
        final token = await SecureStorage.getToken();

        if (token == null || token.isEmpty) {
          // 🔒 Handle unauthenticated case
          if (onLoginRequired != null) {
            onLoginRequired!();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Login required to favorite.")),
            );
          }
          return;
        }

        // ✅ Toggle local + sync API
        context.read<FavoriteProvider>().toggleFavorite(parsedId, context);

        await FavoriteService.toggleFavoriteApi(token, parsedId);
      },
    );
  }
}
