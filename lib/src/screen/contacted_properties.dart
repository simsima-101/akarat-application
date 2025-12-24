// lib/screen/contacted_properties.dart
import 'dart:convert';



import '../features/property/data/models/property_model.dart' as propertyModel;


import 'package:Akarat/src/core/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../core/services/api_service.dart';
import '../core/utils/secure_storage.dart';


import 'featured_detail.dart';

class ContactedProperties extends StatefulWidget {
  const ContactedProperties({super.key});

  @override
  State<ContactedProperties> createState() => _ContactedPropertiesState();
}

class _ContactedPropertiesState extends State<ContactedProperties> {
  List<propertyModel.Data> contactedProperties = [];

  bool isLoading = true;
  String? error;
  bool isDeleting = false;

  @override
  void initState() {
    super.initState();
    fetchContactedProperties();
  }

  Future<void> fetchContactedProperties() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      await SessionManager().restore();
      String? token = SessionManager().token ?? await SecureStorage.getToken();

      if (token == null || token.isEmpty) {
        setState(() {
          error = "Please login again.";
          isLoading = false;
        });
        return;
      }

      final uri = ApiService.buildUri('contacted-properties');
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        List<dynamic> list = [];
        if (jsonData['data'] is List) {
          list = jsonData['data'];
        } else if (jsonData['data']?['data'] is List) {
          list = jsonData['data']['data'];
        } else if (jsonData is List) {
          list = jsonData;
        }

        setState(() {
          contactedProperties = list
              .map((e) => propertyModel.Data.fromJson(e as Map<String, dynamic>))
              .toList();
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          error = "Session expired. Please login again.";
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Failed to load (${response.statusCode})";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Network error. Please check your connection.";
        isLoading = false;
      });
    }
  }

  Future<bool> _deleteContactedProperty(int propertyId) async {
    try {
      await SessionManager().restore();
      String? token = SessionManager().token ?? await SecureStorage.getToken();
      if (token == null) return false;

      final uri = ApiService.buildUri('contacted-property/$propertyId');
      final response = await http.delete(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _deleteAllContactedProperties() async {
    try {
      await SessionManager().restore();
      String? token = SessionManager().token ?? await SecureStorage.getToken();
      if (token == null) return false;

      final uri =
          ApiService.buildUri('contacted-properties'); // Correct for clear all
      final response = await http.delete(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  void _removeProperty(int index) async {
    final property = contactedProperties[index];
    final originalList = List<propertyModel.Data>.from(contactedProperties);


    // Optimistically remove
    setState(() {
      contactedProperties.removeAt(index);
    });

    // Show removing feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Removing..."),
        duration: Duration(seconds: 4),
      ),
    );

    final success = await _deleteContactedProperty(property.id!);

    if (!mounted) return;

    if (!success) {
      // Revert if failed
      setState(() {
        contactedProperties = originalList;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to remove property")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Property removed from contacted list")),
      );
    }
  }

  void _clearAllProperties() async {
    if (contactedProperties.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Clear All Contacted Properties?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete All"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isDeleting = true);

    final success = await _deleteAllContactedProperties();

    if (!mounted) return;

    setState(() => isDeleting = false);

    if (success) {
      setState(() => contactedProperties.clear());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All contacted properties cleared")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to clear all properties")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // ... [all your existing imports and code remain the same until AppBar]

      appBar: AppBar(
        title: const Text(
          "Contacted Properties",
          style: TextStyle(fontSize: 19),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        actions: [
          // Refresh Icon
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isDeleting ? null : fetchContactedProperties,
            tooltip: "Refresh",
          ),

          // Eye Icon (Hint) - Always next to Refresh
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: Colors.grey[600],
            ),
            tooltip: "How to remove properties",
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: Colors.white,
                  title: const Text("How to Remove"),
                  content: const Text(
                    "Swipe left on any property to remove it from your contacted list",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Got it"),
                    ),
                  ],
                ),
              );
            },
          ),

          // Clear All Icon - Only when there are contacted properties
          if (contactedProperties.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: isDeleting ? null : _clearAllProperties,
              tooltip: "Clear All",
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: fetchContactedProperties,
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  ),
                )
              : contactedProperties.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "No properties contacted yet.\nStart contacting agents!",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: fetchContactedProperties,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: contactedProperties.length,
                        itemBuilder: (context, index) {
                          final property = contactedProperties[index];

                          return Dismissible(
                            key: Key(property.id.toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete,
                                  color: Colors.white, size: 30),
                            ),
                            confirmDismiss: (_) async {
                              return await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      backgroundColor: Colors.white,
                                      title: const Text("Remove Property?"),
                                      content: Text(
                                        "Remove \"${property.title ?? 'this property'}\" from contacted list?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          style: TextButton.styleFrom(
                                              foregroundColor: Colors.red),
                                          child: const Text("Remove"),
                                        ),
                                      ],
                                    ),
                                  ) ??
                                  false;
                            },
                            onDismissed: (_) {
                              // This will trigger your existing, correct deletion logic
                              _removeProperty(index);
                            },
                            child: Card(
                              color: Colors.white,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: property.media?.isNotEmpty == true
                                      ? Image.network(
                                          property.media!.first.originalUrl!,
                                          width: 70,
                                          height: 70,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.image, size: 40),
                                        )
                                      : const Icon(Icons.image, size: 40),
                                ),
                                title: Text(
                                  property.title ?? "No Title",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${property.price} AED"),
                                    Text(property.location ?? ""),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Featured_Detail(
                                        data: property.id.toString(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
