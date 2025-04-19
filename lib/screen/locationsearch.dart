import 'package:Akarat/screen/filter.dart';
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/search.dart';
import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MaterialApp(
    home: SearchScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<String> filteredSuggestions = [];
  bool showSuggestions = false;

  final List<String> recentSearches = ['Dubai'];
  final List<String> popularLocations = [
    'Dubai', 'Abu Dhabi', 'Sharjah',
    'Business bay', 'Downtown', 'Jumeirah'
  ];

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() async {
      final input = _searchController.text.trim();
      if (input.isNotEmpty) {
        final results = await fetchSuggestionsFromBackend(input);
        setState(() {
          filteredSuggestions = results;
          showSuggestions = true;
        });
      } else {
        setState(() {
          showSuggestions = false;
        });
      }
    });
  }

  Future<List<String>> fetchSuggestionsFromBackend(String query) async {
    await Future.delayed(Duration(milliseconds: 300));
    List<String> allLocations = [
      'Dubai', 'Abu Dhabi', 'Sharjah',
      'Business bay', 'Downtown', 'Jumeirah'
    ];
    return allLocations.where((item) => item.toLowerCase().contains(query.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Box
            Container(
              width: 400,
              height: 70,
              padding: const EdgeInsets.only(top: 8,left: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red,
                    offset: Offset(0.0, 0.0),
                    blurRadius: 0.0,
                    spreadRadius: 0.3,
                  ),
                  BoxShadow(
                    color: Colors.white,
                    offset: Offset(0.0, 0.0),
                    blurRadius: 0.5,
                    spreadRadius: 0.0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                      onTap: (){
                        Navigator.of(context).pop();
                        // Navigator.push(context, MaterialPageRoute(builder: (context)=> Filter(data: "Rent")));
                      },
                      child: Icon(Icons.arrow_back, color: Colors.red)),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Select location',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Suggestion Tiles from Backend
            if (showSuggestions)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: filteredSuggestions.map((location) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _searchController.text = location;
                            Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => Filter(data: location)),
                        );
                        });


                      },
                      child: Chip(
                        label: Text(location),
                        backgroundColor: Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            SizedBox(height: 20),

            // Recently Searched
            Row(
              children: [
                Icon(Icons.history, color: Colors.red, size: 20),
                SizedBox(width: 6),
                Text(
                  'Recently Searched Location',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: recentSearches.map((loc) => _buildChip(loc, context)).toList(),
            ),

            SizedBox(height: 30),

            // Popular Locations
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.red, size: 20),
                SizedBox(width: 6),
                Text(
                  'Popular Locations',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: popularLocations.map((loc) => _buildChip(loc, context)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => Filter(data: label)),
        );
      },
      child: Chip(
        label: Text(label),
        backgroundColor: Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class PropertyListScreen extends StatelessWidget {
  final String location;

  PropertyListScreen({required this.location});

  final List<String> dummyProperties = [
    "2BHK Apartment with Pool",
    "Luxury Villa with Garden",
    "Affordable Studio Flat",
    "Sea View Penthouse"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Properties in $location"),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        itemCount: dummyProperties.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(dummyProperties[index]),
            subtitle: Text("in $location"),
            leading: Icon(Icons.home, color: Colors.red),
          );
        },
      ),
    );
  }
}