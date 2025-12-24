import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/property/presentation/bloc/filter_bloc.dart'; // Adjust path as needed
// If your Amenity model is elsewhere, import it here
import '../features/property/data/models/amenities_model.dart';

class FullAmenitiesScreen extends StatefulWidget {
  final List<Amenity> allAmenities;           // ← Now singular: Amenity
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
  late List<int> _selected;
  Timer? _searchDebounce;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedAmenitiesIds);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  // Simple client-side search filter
  List<Amenity> get _filteredAmenities {
    if (_searchQuery.isEmpty) {
      return widget.allAmenities;
    }
    final lowerQuery = _searchQuery.toLowerCase();
    return widget.allAmenities.where((amenity) {
      return amenity.title?.toLowerCase().contains(lowerQuery) ?? false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredAmenities;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Amenities",
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 🔍 Search bar (client-side filtering)
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search amenities...',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                filled: true,
                fillColor: Colors.grey.shade100,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (query) {
                // Debounce for smooth typing
                _searchDebounce?.cancel();
                _searchDebounce = Timer(const Duration(milliseconds: 300), () {
                  setState(() {
                    _searchQuery = query.trim();
                  });
                });
              },
            ),
          ),

          // 📦 Amenities Grid
          Expanded(
            child: filteredList.isEmpty
                ? Center(
              child: Text(
                _searchQuery.isEmpty
                    ? 'No amenities available'
                    : 'No amenities found',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: filteredList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (_, index) {
                final amenity = filteredList[index];
                final bool isSelected = _selected.contains(amenity.id);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selected.remove(amenity.id);
                      } else {
                        _selected.add(amenity.id!);
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? Colors.black87
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        CachedNetworkImage(
                          imageUrl: amenity.icon ?? '',
                          width: 18,
                          height: 18,
                          placeholder: (context, url) => const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.broken_image,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            amenity.title ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ✅ Done Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  widget.onDone(_selected);
                  Navigator.pop(context);
                },
                child: const Text(
                  "Done",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}