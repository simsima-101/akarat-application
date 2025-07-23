import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';
import '../secure_storage.dart';
import '../services/favorite_service.dart';

class FavoriteIconButton extends StatelessWidget {
  final String? propertyId;
  final VoidCallback? onLoginRequired;

  const FavoriteIconButton({
    Key? key,
    required this.propertyId,
    this.onLoginRequired,
  }) : super(key: key);

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
        context.read<FavoriteProvider>().toggleFavorite(parsedId);
        await FavoriteService.toggleFavoriteApi(token, parsedId);
      },
    );
  }
}
