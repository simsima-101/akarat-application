import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class Property {
  final String id;
  final String title;
  final String location;
  final String price;
  final String imageUrl;

  Property({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.imageUrl,
  });
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Property> allProperties = [];
  List<Property> filteredProperties = [];

  @override
  void initState() {
    super.initState();
    _loadProperties();
    _searchController.addListener(_filterProperties);
  }


  void _loadProperties() {
    allProperties = [
      Property(id: '1', title: 'Modern Apartment', location: 'Dubai', price: '130,000 AED', imageUrl: 'assets/images/photo1.png'),
      Property(id: '2', title: 'Beach Villa', location: 'Jumeirah', price: '250,000 AED', imageUrl: 'assets/images/photo1.png'),
      Property(id: '3', title: 'Downtown Flat', location: 'Downtown', price: '180,000 AED', imageUrl: 'assets/images/photo1.png'),
    ];
    filteredProperties = List.from(allProperties);
  }

  void _filterProperties() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredProperties = List.from(allProperties);
      } else {
        filteredProperties = allProperties
            .where((property) => property.location.toLowerCase().contains(query))
            .toList();
      }
    });
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 🔍 Search Box
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.grey[100],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search by location (e.g. Dubai)',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🏠 Filtered Property List or Not Found Message
            Expanded(
              child: filteredProperties.isEmpty
                  ? Center(
                child: Text(
                  'No locations found. Please try another search.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              )
                  : ListView.builder(
                itemCount: filteredProperties.length,
                itemBuilder: (context, index) {
                  final item = filteredProperties[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to detail page if needed
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                            child: Image.asset(item.imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(item.price, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, size: 14, color: Colors.red),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    item.location,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
