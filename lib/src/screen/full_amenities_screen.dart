import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../features/property/data/models/amenities_model.dart';

class FullAmenitiesScreen extends StatefulWidget {
  final List<Amenities> allAmenities;
  final List<int> selectedAmenitiesIds;
  final Function(List<int>) onDone;

  const FullAmenitiesScreen({
    super.key,
    required this.allAmenities,
    required this.selectedAmenitiesIds,
    required this.onDone,
  });

  @override
  State<FullAmenitiesScreen> createState() => _FullAmenitiesScreenState();
}

class _FullAmenitiesScreenState extends State<FullAmenitiesScreen> {
  late List<int> _selectedIds;
  Timer? _debounce;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedIds = List.from(widget.selectedAmenitiesIds);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  List<Amenities> get _filteredAmenities {
    if (_searchQuery.isEmpty) {
      return widget.allAmenities;
    }

    final query = _searchQuery.toLowerCase().trim();
    final currentLang = Localizations.localeOf(context).languageCode.toLowerCase();

    return widget.allAmenities.where((amenity) {
      final title = amenity.getTitle(currentLang) ?? '';
      return title.toLowerCase().contains(query);
    }).toList();
  }

  bool get _isRtl => Localizations.localeOf(context).languageCode == 'ar';

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';
    final filtered = _filteredAmenities;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          isArabic ? 'وسائل الراحة' : 'Amenities',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: isArabic ? 'ابحث عن وسيلة راحة...' : 'Search amenities...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                onChanged: (value) {
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 350), () {
                    if (mounted) {
                      setState(() => _searchQuery = value.trim());
                    }
                  });
                },
              ),
            ),

            // Grid or empty state
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                child: Text(
                  _searchQuery.isEmpty
                      ? (isArabic ? 'لا توجد وسائل راحة متاحة' : 'No amenities available')
                      : (isArabic ? 'لا توجد نتائج مطابقة' : 'No matching results'),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
                  : GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 4.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final amenity = filtered[index];
                  final isSelected = _selectedIds.contains(amenity.id);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedIds.remove(amenity.id);
                        } else {
                          _selectedIds.add(amenity.id!);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.red.shade700 : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          // Icon
                          CachedNetworkImage(
                            imageUrl: amenity.icon ?? '',
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.broken_image_outlined,
                              size: 24,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Title
                          Expanded(
                            child: Text(
                              amenity.getTitle(locale.languageCode) ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: isArabic ? 'Tajawal' : null,
                                height: 1.3,
                              ),
                              textAlign: isArabic ? TextAlign.right : TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Done button
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onDone(_selectedIds);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isArabic ? 'تم' : 'Done',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}