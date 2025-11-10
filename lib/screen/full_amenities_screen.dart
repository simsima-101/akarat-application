import 'dart:async'; // 👈 add this

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/amenities.dart';
import '../providers/search_amenities_provider.dart';

class FullAmenitiesScreen extends StatefulWidget {
  final List<Amenities> allAmenities;
  final List<int> selectedAmenitiesId;
  final Function(List<int>) onDone;

  const FullAmenitiesScreen({
    super.key,
    required this.allAmenities,
    required this.selectedAmenitiesId,
    required this.onDone,
  });

  @override
  State<FullAmenitiesScreen> createState() => _FullAmenitiesScreenState();
}

class _FullAmenitiesScreenState extends State<FullAmenitiesScreen> {
  late List<int> _selected;
  Timer? _searchDebounce; // 👈 replaces EasyDebounce

  @override
  void initState() {
    super.initState();
    context.read<SearchAmenitiesProvider>().clearSearchData();
    _selected = List.from(widget.selectedAmenitiesId);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel(); // 👈 instead of EasyDebounce.cancel(...)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchAmenitiesProvider>(
      builder: (context, searchProvider, child) {
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
              // 🔍 Search bar
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: searchProvider.searchController,
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
                    // 👇 simple debounce: wait 500ms after last keystroke
                    if (_searchDebounce?.isActive ?? false) {
                      _searchDebounce!.cancel();
                    }
                    _searchDebounce =
                        Timer(const Duration(milliseconds: 500), () async {
                          await searchProvider.searchAmenities(query);
                        });
                  },
                ),
              ),

              // 📦 List
              Expanded(
                child: searchProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : searchProvider.searchController.text.isNotEmpty &&
                    searchProvider.searchResults.isEmpty
                    ? const Center(
                  child: Text(
                    'No Amenities Found!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
                    : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount:
                  searchProvider.searchController.text.isNotEmpty
                      ? searchProvider.searchResults.length
                      : widget.allAmenities.length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (_, index) {
                    final amenity = searchProvider
                        .searchController.text.isNotEmpty
                        ? searchProvider.searchResults[index]
                        : widget.allAmenities[index];

                    final isSelected =
                    _selected.contains(amenity.id);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          isSelected
                              ? _selected.remove(amenity.id)
                              : _selected.add(amenity.id!);
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12),
                        child: Row(
                          children: [
                            CachedNetworkImage(
                              imageUrl: amenity.icon ?? '',
                              width: 18,
                              height: 18,
                              placeholder: (context, url) =>
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                ),
                              ),
                              errorWidget:
                                  (context, url, error) =>
                              const Icon(
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
              )
            ],
          ),
        );
      },
    );
  }
}
