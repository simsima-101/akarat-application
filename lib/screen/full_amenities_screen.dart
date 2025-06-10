import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';



import '../model/amenities.dart';

class FullAmenitiesScreen extends StatefulWidget {
  final List<Amenities> allAmenities;
  final Set<int> selectedIndexes;
  final Function(Set<int>) onDone;

  const FullAmenitiesScreen({
    super.key,
    required this.allAmenities,
    required this.selectedIndexes,
    required this.onDone,
  });

  @override
  State<FullAmenitiesScreen> createState() => _FullAmenitiesScreenState();
}

class _FullAmenitiesScreenState extends State<FullAmenitiesScreen> {
  late Set<int> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.selectedIndexes);

    // Pre-cache images after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var amenity in widget.allAmenities) {
        final iconUrl = amenity.icon;
        if (iconUrl != null && iconUrl.isNotEmpty) {
          precacheImage(NetworkImage(iconUrl), context);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 🌟 white background
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Amenities", style: TextStyle(color: Colors.black)),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
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
                setState(() {
                  // TODO: add search filter logic if needed
                });
              },
            ),
          ),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: widget.allAmenities.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (_, index) {
                final amenity = widget.allAmenities[index];
                final isSelected = _selected.contains(index);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      isSelected ? _selected.remove(index) : _selected.add(index);
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: isSelected ? Colors.black87 : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
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
                            child: CircularProgressIndicator(strokeWidth: 1.5),
                          ),
                          errorWidget: (context, url, error) =>
                          const Icon(Icons.broken_image, size: 18),
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40), // ⬅ increased bottom padding
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
                child: const Text("Done", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          )

        ],
      ),
    );
  }
}
