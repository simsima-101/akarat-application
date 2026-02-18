// lib/screen/contacted_properties.dart
import 'dart:convert';

import 'package:Akarat/src/core/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../core/services/api_service.dart';
import '../core/utils/secure_storage.dart';
import '../features/property/data/models/project_model.dart' as contacted;
import 'featured_detail.dart';

class ContactedProperties extends StatefulWidget {
  const ContactedProperties({super.key});

  @override
  State<ContactedProperties> createState() => _ContactedPropertiesState();
}

class _ContactedPropertiesState extends State<ContactedProperties> {




  List<contacted.ProjectData> contactedProperties = [];


  bool isLoading = true;
  String? error;
  bool isDeleting = false;

  @override
  void initState() {
    super.initState();

  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Fetch only once when widget becomes ready
    if (contactedProperties.isEmpty && isLoading) {
      fetchContactedProperties();
    }
  }

  Future<void> fetchContactedProperties() async {



    final l10n = AppLocalizations.of(context)!;
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      await SessionManager().restore();
      String? token = SessionManager().token ?? await SecureStorage.getToken();

      if (token == null || token.isEmpty) {
        setState(() {
          error = l10n.pleaseLoginAgain;
          isLoading = false;
        });
        return;
      }

      // final uri = ApiService.buildUri('contacted-properties');
      // final response = await http.get(
      //   uri,
      //   headers: {
      //     'Accept': 'application/json',
      //     'Authorization': 'Bearer $token',
      //   },
      // );

      final response = await ApiService.get(
        'contacted-properties',
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 25));

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
              .map((e) =>
                  contacted.ProjectData.fromJson(e as Map<String, dynamic>))
              .toList();
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          error = l10n.sessionExpired;
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
        error = l10n.networkError;
        isLoading = false;
      });
    }
  }

  Future<bool> _deleteContactedProperty(int propertyId) async {
    try {
      await SessionManager().restore();
      String? token = SessionManager().token ?? await SecureStorage.getToken();
      if (token == null) return false;
      //
      // final uri = ApiService.buildUri('contacted-property/$propertyId');
      // final response = await http.delete(
      //   uri,
      //   headers: {
      //     'Accept': 'application/json',
      //     'Authorization': 'Bearer $token',
      //   },
      // );

      final response = await ApiService.delete(
        'contacted-property/$propertyId',
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 25));

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

      // final uri =
      //     ApiService.buildUri('contacted-properties'); // Correct for clear all
      // final response = await http.delete(
      //   uri,
      //   headers: {
      //     'Accept': 'application/json',
      //     'Authorization': 'Bearer $token',
      //   },
      // );

      final response = await ApiService.delete(
        'contacted-properties',
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 25));

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  void _removeProperty(int index) async {

    final l10n = AppLocalizations.of(context)!;
    final property = contactedProperties[index];
    final originalList = List<contacted.ProjectData>.from(contactedProperties);

    // Optimistically remove
    setState(() {
      contactedProperties.removeAt(index);
    });

    // Show removing feedback
    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(
        content: Text(l10n.removing),
        duration: const Duration(seconds: 4),
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
        SnackBar(content: Text(l10n.propertyRemoved)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Property removed from contacted list")),
      );
    }
  }

  void _clearAllProperties() async {
    final l10n = AppLocalizations.of(context)!;
    if (contactedProperties.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(l10n.clearAll),
        content: Text(l10n.cannotBeUndone),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.deleteAll),
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
        SnackBar(content: Text(l10n.allCleared)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.failedToClearAll)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      // ... [all your existing imports and code remain the same until AppBar]

      appBar: AppBar(
        title: Text(
          l10n.contactedPropertiesTitle,
          style: const TextStyle(fontSize: 19),
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
                  title: Text(l10n.howToRemoveTitle),
                  content: Text(
                    l10n.howToRemoveMessage,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(l10n.gotIt),
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
              tooltip: l10n.clearAll,
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
                          child: Text(l10n.retry),
                        ),
                      ],
                    ),
                  ),
                )
              : contactedProperties.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          l10n.noPropertiesYet,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
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
                                      title: Text(l10n.removeProperty),
                                      content: Text(
                                        "Remove \"${property.title ?? 'this property'}\" from contacted list?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: Text(l10n.cancel),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          style: TextButton.styleFrom(
                                              foregroundColor: Colors.red),
                                          child: Text(l10n.remove),
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
                                  property.title ?? l10n.noTitle,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Price - localized with proper formatting
                                    Text(
                                      property.price != null && property.price!.trim().isNotEmpty
                                          ? l10n.priceAed(property.price!.trim())
                                          : l10n.priceOnRequest,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),

                                    // Location - only show when it actually has content
                                    if (property.location?.trim().isNotEmpty ?? false)
                                      Text(
                                        property.location!.trim(),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    // Optional: show fallback only if you want it visible when location is missing
                                    // else
                                    //   Text(
                                    //     l10n.locationNotAvailable,
                                    //     style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                                    //   ),
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
