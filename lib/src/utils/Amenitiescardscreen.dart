import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../features/property/data/models/amenities_model.dart';

class AmenitiesCard extends StatelessWidget {
  final Amenities amenity;

  const AmenitiesCard({
    super.key,
    required this.amenity,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Card(
        elevation: 1.5,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: Colors.grey.shade50,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            // Optional: open details / toggle selection / etc.
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Icon
                if (amenity.icon != null && amenity.icon!.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: amenity.icon!,
                    width: 28,
                    height: 28,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.broken_image_outlined,
                      size: 28,
                      color: Colors.grey,
                    ),
                  ),

                if (amenity.icon != null && amenity.icon!.isNotEmpty)
                  const SizedBox(width: 12),

                // Title
                Expanded(
                  child: Text(
                    amenity.getTitle(locale.languageCode) ?? 'N/A',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      fontFamily: isArabic ? 'Tajawal' : null,
                      height: 1.3,
                    ),
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}