import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  List<String> locationSuggestions = [];

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  void _loadProperties() {
    allProperties = [
      Property(id: '1', title: 'Modern Apartment', location: 'Dubai', price: '130,000 AED', imageUrl: 'assets/images/photo1.png'),
      Property(id: '2', title: 'Beach Villa', location: 'Jumeirah', price: '250,000 AED', imageUrl: 'assets/images/photo1.png'),
      Property(id: '3', title: 'Downtown Flat', location: 'Downtown', price: '180,000 AED', imageUrl: 'assets/images/photo1.png'),
    ];
    filteredProperties = List.from(allProperties);
  }

  Future<void> fetchLocationSuggestions(String query) async {
    String url = query.isEmpty
        ? 'https://akarat.com/api/locations'
        : 'https://akarat.com/api/locations?q=$query';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          locationSuggestions = data
              .map((item) => item['location'].toString())
              .toList();
        });
      } else {
        print('❌ Failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }

    void _onSearchChanged(String query) {
    fetchLocationSuggestions(query);
    setState(() {
      filteredProperties = allProperties
          .where((p) => p.location.toLowerCase().contains(query.toLowerCase()))
          .toList();
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
                        onChanged: _onSearchChanged,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🔽 Suggestions Dropdown:
            if (locationSuggestions.isNotEmpty)
              Container(
                height: 200,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.4), blurRadius: 8)],
                ),
                child: ListView.builder(
                  itemCount: locationSuggestions.length,
                  itemBuilder: (context, index) {
                    final loc = locationSuggestions[index];
                    return ListTile(
                      title: Text(loc),
                      onTap: () {
                        _searchController.text = loc;
                        _onSearchChanged(loc);
                        setState(() => locationSuggestions = []);
                      },
                    );
                  },
                ),
              ),

            Expanded(
              child: filteredProperties.isEmpty
                  ? Center(child: Text('No locations found.', style: TextStyle(fontSize: 16, color: Colors.grey)))
                  : ListView.builder(
                itemCount: filteredProperties.length,
                itemBuilder: (context, index) {
                  final item = filteredProperties[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.asset(item.imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(item.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(item.price, style: TextStyle(fontSize: 14, color: Colors.grey)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, size: 14, color: Colors.red),
                              SizedBox(width: 4),
                              Expanded(child: Text(item.location, style: TextStyle(fontSize: 12))),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
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
