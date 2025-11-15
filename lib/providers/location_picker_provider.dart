import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../device_id.dart';
import '../model/location_model.dart';
import '../secure_storage.dart';
import '../services/api_service.dart';

class LocationPickerProvider extends ChangeNotifier {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  Future<void> clearAll() async {
    selectedLocationList.clear();
    searchController.clear();
    searchQuery = '';
    // Reset popular search to show emirates
    popularLocationList = await fetchEmirates();
    notifyListeners();
  }

  Future<void> removeSelectedLocations(LocationModel locModel) async {
    // Check if item exists before removing
    final exists = selectedLocationList.any((loc) =>
        loc.id == locModel.id &&
        (loc.location == null) == (locModel.location == null));

    if (!exists) {
      debugPrint(
          '⚠️ Could not remove location: ${locModel.location ?? locModel.country} (ID: ${locModel.id}) - not found in selected list');
      notifyListeners();
      return;
    }

    // Store emirateId before removing (needed to determine where to add back)
    final emirateId = locModel.emirateId;

    // Remove using ID and type comparison (not object equality)
    selectedLocationList.removeWhere((loc) =>
        loc.id == locModel.id &&
        (loc.location == null) == (locModel.location == null));

    debugPrint(
        '🗑️ Removed location: ${locModel.location ?? locModel.country} (ID: ${locModel.id})');
    await saveLastSearch(locModel.location ?? locModel.country!);

    // Add back to the appropriate list based on what we're currently showing
    // Check if we're currently showing sub-locations (i.e., an emirate is in selected list)
    final hasEmirateSelected =
        selectedLocationList.any((loc) => loc.location == null);
    final currentlyShowingSubLocations = hasEmirateSelected;

    if (locModel.location != null) {
      // Removed a sub-location
      if (currentlyShowingSubLocations) {
        // We're showing sub-locations, add it back to popular list
        updatePopularSearchLocally(locModel);
        debugPrint('↩️ Added sub-location back to popular list');
      } else {
        // We're showing emirates, add sub-location back to last search (if it has emirateId)
        if (emirateId != null) {
          final existsInLastSearch = lastSearchList.any((lastSearch) =>
              lastSearch.id == locModel.id &&
              (lastSearch.location == null) == (locModel.location == null));
          if (!existsInLastSearch) {
            updateLastSearchLocally(locModel);
            debugPrint('↩️ Added sub-location back to last search');
          }
        }
      }
    } else {
      // Removed an emirate
      if (!currentlyShowingSubLocations) {
        // We're showing emirates, add it back to popular list
        updatePopularSearchLocally(locModel);
        debugPrint('↩️ Added emirate back to popular list');
      } else {
        // We're showing sub-locations, add emirate back to last search (if it has emirateId)
        if (emirateId != null) {
          final existsInLastSearch = lastSearchList.any((lastSearch) =>
              lastSearch.id == locModel.id &&
              (lastSearch.location == null) == (locModel.location == null));
          if (!existsInLastSearch) {
            updateLastSearchLocally(locModel);
            debugPrint('↩️ Added emirate back to last search');
          }
        }
      }
    }

    // Update popular search based on the new first item in selectedLocationList
    debugPrint('🔄 Updating popular search based on first item after removal');
    if (selectedLocationList.isNotEmpty) {
      debugPrint(
          '📌 First item after removal: ${selectedLocationList.first.location ?? selectedLocationList.first.country} (ID: ${selectedLocationList.first.id})');
    } else {
      debugPrint('📌 No items in selected list after removal');
    }
    await updatePopularSearchBasedOnFirstItem();
  }

  ////////////////////////// ⬇⬇⬇  FETCH LAST SEARCH FUNCTIONALITY  ⬇⬇⬇ //////////////////////////

  bool isLoadingLastSearch = false;
  List<LocationModel> lastSearchList = [];

  Future<void> fetchLastSearch() async {
    try {
      isLoadingLastSearch = true;
      notifyListeners();

      final token = await SecureStorage.getToken();
      debugPrint('token: $token');

      final deviceId = await getDeviceId();
      debugPrint('device id: $deviceId');

      if (deviceId == null) {
        debugPrint('❌❌❌ Device ID is NULL : $deviceId');
        return;
      }

      final uri = Uri.parse('${ApiService.baseUrl}/last-search');
      final response = await http.get(
        uri,
        headers: token != null
            ? {
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
                'X-Device-ID': deviceId,
              }
            : {
                'Accept': 'application/json',
                'X-Device-ID': deviceId,
              },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map && decoded['data'] is List) {
          // Parse last search API response
          // API format: {id: search_record_id, location: name, emirate_id: X, sublocation_id: Y or null}
          // Convert to LocationModel format:
          // - Emirates: id = emirate_id, location = null, country = location name, emirateId = emirate_id
          // - Sub-locations: id = sublocation_id, location = location name, country = null, emirateId = emirate_id
          lastSearchList = (decoded['data'] as List).map((e) {
            final emirateId = e['emirate_id'] as int?;
            final sublocationId = e['sublocation_id'] as int?;
            final locationName = e['location'] as String?;

            if (sublocationId == null) {
              // It's an emirate
              return LocationModel(
                id: emirateId,
                location: null,
                country: locationName,
                emirateId: emirateId,
              );
            } else {
              // It's a sub-location
              return LocationModel(
                id: sublocationId,
                location: locationName,
                country: null,
                emirateId: emirateId,
              );
            }
          }).toList();

          // Filter out already selected items
          lastSearchList.removeWhere((lastSearchItem) {
            final isSelected = selectedLocationList.any((selected) =>
                selected.id == lastSearchItem.id &&
                (selected.location == null) ==
                    (lastSearchItem.location == null));
            return isSelected;
          });

          debugPrint('📋 Last Search list length: ${lastSearchList.length}');
        } else {
          lastSearchList = [];
          debugPrint('⚠️ Unexpected JSON format: $decoded');
        }
      } else {
        lastSearchList = [];
        debugPrint('❌ Failed to fetch last searches: ${response.statusCode}');
      }
    } catch (e) {
      lastSearchList = [];
      debugPrint('❌ Error while fetching last searches: $e');
    } finally {
      isLoadingLastSearch = false;
      notifyListeners();
    }

    debugPrint('📋 Last Search list length : ${lastSearchList.length}');
  }

  void updateLastSearchLocally(LocationModel locModel) {
    // Check if item already exists (by ID and type)
    final exists = lastSearchList.any((lastSearch) =>
        lastSearch.id == locModel.id &&
        (lastSearch.location == null) == (locModel.location == null));

    if (!exists) {
      lastSearchList.insert(0, locModel);
      // Keep only last 5 items (as per API limit)
      if (lastSearchList.length > 5) {
        lastSearchList = lastSearchList.take(5).toList();
      }
      debugPrint(
          '✅ Added to last search: ${locModel.location ?? locModel.country} (ID: ${locModel.id})');
    } else {
      debugPrint(
          '⚠️ Item already in last search: ${locModel.location ?? locModel.country} (ID: ${locModel.id})');
    }
    notifyListeners();
  }

  void clearLastSearchFetchedData() {
    lastSearchList.clear();
    isLoadingLastSearch = false;
    notifyListeners();
  }

  ////////////////////////// ⬇⬇⬇  FETCH EMIRATES FUNCTIONALITY ⬇⬇⬇  //////////////////////////

  // bool isLoadingEmirates = false;
  // List<LocationModel> emiratesList = [];

  Future<List<LocationModel>> fetchEmirates() async {
    try {
      List<LocationModel> emiratesList = [];
      // isLoadingEmirates = true;
      // notifyListeners();

      final uri = Uri.parse('${ApiService.baseUrl}/emirates');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          // Set emirateId for emirates (same as id)
          emiratesList = decoded.map((e) {
            final model = LocationModel.fromJson(e);
            // For emirates, emirateId should be the same as id
            return LocationModel(
              id: model.id,
              slug: model.slug,
              country: model.country,
              location: model.location,
              emirateId: model.emirateId ?? model.id,
            );
          }).toList();
          log('All Emirates: $emiratesList');
        } else {
          emiratesList = [];
          debugPrint('⚠️ Unexpected JSON format: $decoded');
        }
      } else {
        emiratesList = [];
        debugPrint('❌ Failed to fetch emirates: ${response.statusCode}');
      }

      debugPrint('⚠️ Emirates list length : ${emiratesList.length}');
      notifyListeners();
      return emiratesList;
    } catch (e) {
      debugPrint('❌ Error while fetching emirates: $e');
      return [];
    }
    // finally {
    //   isLoadingEmirates = false;
    //   notifyListeners();
    // }
  }

  // void clearEmiratesFetchedData() {
  //   // emiratesList.clear();
  //   isLoadingEmirates = false;
  //   notifyListeners();
  // }

  ////////////////////////// ⬇⬇⬇ FETCH EMIRATE SUB LOCATION FUNCTIONALITY ⬇⬇⬇ //////////////////////////

  // bool isLoadingEmiratesSubLocation = false;
  // List<LocationModel> emiratesSubLocationList = [];

  Future<List<LocationModel>> fetchEmiratesSubLocations(
      {required int emirateId}) async {
    try {
      List<LocationModel> emiratesSubLocationList = [];

      // isLoadingEmiratesSubLocation = true;
      // notifyListeners();

      final uri =
          Uri.parse('${ApiService.baseUrl}/emirates-sub-location/$emirateId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          // Set emirateId for all sub-locations
          emiratesSubLocationList = decoded.map((e) {
            final model = LocationModel.fromJson(e);
            // Ensure emirateId is set (in case API doesn't return it)
            return LocationModel(
              id: model.id,
              slug: model.slug,
              country: model.country,
              location: model.location,
              emirateId: model.emirateId ?? emirateId,
            );
          }).toList();
          log('All Emirates Sub Location: $emiratesSubLocationList');
        } else {
          emiratesSubLocationList = [];
          debugPrint('⚠️ Unexpected JSON format: $decoded');
        }
      } else {
        emiratesSubLocationList = [];
        debugPrint(
            '❌ Failed to fetch emirates Sub Location:  ${response.statusCode}');
      }
      notifyListeners();

      return emiratesSubLocationList;
    } catch (e) {
      debugPrint('❌ Error while fetching emirates Sub Location: $e');
      return [];
    }
    // finally {
    //   isLoadingEmiratesSubLocation = false;
    //   notifyListeners();
    // }

    // debugPrint(
    //     'Emirates Sub Location List Length : ${emiratesSubLocationList.length}');
  }

  // void clearEmiratesSubLocationFetchedData() {
  //   // emiratesSubLocationList.clear();
  //   isLoadingEmiratesSubLocation = false;
  //   notifyListeners();
  // }

  ////////////////////////// ⬇⬇⬇ LOCATION SELECTION FUNCTIONALITY ⬇⬇⬇ //////////////////////////

  List<LocationModel> selectedLocationList = [];

  // void addSelectedLocation({required LocationModel locationModel}) {
  //   if (!selectedLocationList.contains(locationModel)) {
  //     selectedLocationList.insert(0, locationModel);
  //
  //     // if (locationModel.location != null) {
  //     //   fetchPopularSearch(locationId: locationModel.id);
  //     // }
  //
  //     final name =
  //         (locationModel.location ?? locationModel.country)?.toLowerCase();
  //
  //     popularLocationList.removeWhere((loc) =>
  //         loc.country != null &&
  //         name != null &&
  //         loc.country!.toLowerCase() == name);
  //     //
  //     // popularLocationList.removeWhere((loc) =>
  //     //     loc.location != null &&
  //     //     name != null &&
  //     //     loc.location!.toLowerCase() == name);
  //
  //     // Remove ONLY from last search based on NAME
  //     lastSearchList.removeWhere((loc) =>
  //         loc.location != null &&
  //         name != null &&
  //         loc.location!.toLowerCase() == name);
  //     // _controller.clear();
  //     // _query = '';
  //   }
  //   notifyListeners();
  // }

  ////////////////////////// ⬇⬇⬇ SAVE LAST SEARCH FUNCTIONALITY ⬇⬇⬇ //////////////////////////

  Future<void> saveLastSearch(String location) async {
    final uri = Uri.parse('${ApiService.baseUrl}/save-last-search');

    final token = await SecureStorage.getToken();
    debugPrint('token: $token');

    final deviceId = await getDeviceId();
    debugPrint('device id: $deviceId');

    if (deviceId == null) {
      debugPrint('❌❌❌ Device ID is NULL : $deviceId');
      return;
    }

    try {
      final response = await http.post(
        uri,
        headers: token != null
            ? {
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
                'X-Device-ID': deviceId,
              }
            : {
                'Accept': 'application/json',
                'X-Device-ID': deviceId,
              },
        body: {'location': location},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded['success'] == true) {
          if (decoded['data'] is Map) {
            final data = decoded['data'];

            // Convert to model
            final newItem = LocationModel.fromJson(data);

            // Add to local variable
            updateLastSearchLocally(newItem);

            debugPrint('🎯 Added new search to list: ${newItem.location}');
            debugPrint('📌 Total items: ${lastSearchList.length}');
          } else {
            debugPrint('⚠️ Unexpected format for data: ${decoded['data']}');
          }
        } else {
          debugPrint('⚠️ Save failed: ${decoded['message']}');
        }
      } else {
        debugPrint('❌ Failed to save search: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error saving last search: $e');
    }
    notifyListeners();
  }

  ////////////////////////// ⬇⬇⬇ FETCH POPULAR SEARCH FUNCTIONALITY ⬇⬇⬇ //////////////////////////

  List<LocationModel> popularLocationList = [];
  bool isLoadingPopularSearch = false;

  Future<void> fetchPopularSearch({int? locationId}) async {
    try {
      isLoadingPopularSearch = true;
      notifyListeners();
      if (locationId == null) {
        // No location selected, show emirates
        popularLocationList = await fetchEmirates();
      } else {
        // Location selected, show sub-locations
        popularLocationList =
            await fetchEmiratesSubLocations(emirateId: locationId);
      }
    } catch (e) {
      debugPrint('❌ ERROR - failed to fetch popular search: $e');
      popularLocationList = [];
    }
    isLoadingPopularSearch = false;
    notifyListeners();
  }

  /// Updates popular search based on the first item in selectedLocationList
  /// Logic:
  /// - If selectedLocationList is empty → show emirates
  /// - If first item has emirateId → always fetch sub-locations using emirateId
  /// - If first item is emirate (location == null) → show its sub-locations
  /// - If first item is sub-location (location != null) → find parent emirate in list → show parent's sub-locations
  /// - If no parent emirate found → show all emirates
  Future<void> updatePopularSearchBasedOnFirstItem() async {
    try {
      if (selectedLocationList.isEmpty) {
        // No selection → show emirates
        popularLocationList = await fetchEmirates();
        // Filter out already selected items
        popularLocationList.removeWhere((loc) =>
            selectedLocationList.any((selected) => selected.id == loc.id));
        notifyListeners();
        return;
      }

      // Get the first item (most recently selected)
      final firstItem = selectedLocationList.first;

      // If item has emirateId, always fetch sub-locations using that emirateId
      if (firstItem.emirateId != null) {
        popularLocationList =
            await fetchEmiratesSubLocations(emirateId: firstItem.emirateId!);

        // Filter out already selected sub-locations
        final selectedSubLocationIds = selectedLocationList
            .where((s) => s.location != null && s.id != null)
            .map((s) => s.id!)
            .toSet();
        popularLocationList.removeWhere((loc) =>
            loc.location != null &&
            loc.id != null &&
            selectedSubLocationIds.contains(loc.id));

        debugPrint(
            '📋 Fetched sub-locations for emirate ${firstItem.emirateId} (from first item)');
        notifyListeners();
        return;
      }

      if (firstItem.location == null) {
        // First item is an emirate → show its sub-locations
        if (firstItem.id != null) {
          popularLocationList =
              await fetchEmiratesSubLocations(emirateId: firstItem.id!);
          debugPrint(
              '📋 Fetched ${popularLocationList.length} sub-locations for emirate ${firstItem.id}');
          if (popularLocationList.isNotEmpty) {
            debugPrint(
                '📋 First item before filter: ${popularLocationList.first.location} (ID: ${popularLocationList.first.id})');
          }
          // Filter out already selected SUB-LOCATIONS only (not emirates)
          // Only filter sub-locations that match SELECTED SUB-LOCATIONS (not emirates)
          final beforeFilter = popularLocationList.length;
          final selectedSubLocationIds = selectedLocationList
              .where((s) =>
                  s.location != null &&
                  s.id != null) // Only selected sub-locations
              .map((s) => s.id!)
              .toSet();
          popularLocationList.removeWhere((loc) {
            // Only filter if it's a sub-location AND matches a selected SUB-LOCATION (not emirate)
            final shouldFilter = loc.location != null &&
                loc.id != null &&
                selectedSubLocationIds.contains(loc.id);
            if (shouldFilter) {
              debugPrint('🚫 Filtering out: ${loc.location} (ID: ${loc.id})');
            }
            return shouldFilter;
          });
          debugPrint(
              '📋 After filtering: ${popularLocationList.length} sub-locations (removed ${beforeFilter - popularLocationList.length})');
          if (popularLocationList.isNotEmpty) {
            debugPrint(
                '📋 First sub-location after filter: ${popularLocationList.first.location} (ID: ${popularLocationList.first.id})');
          } else {
            debugPrint(
                '⚠️ WARNING: popularLocationList is empty after filtering!');
          }
        } else {
          // Invalid emirate, show all emirates
          popularLocationList = await fetchEmirates();
          // Filter out already selected items
          popularLocationList.removeWhere((loc) =>
              selectedLocationList.any((selected) => selected.id == loc.id));
        }
        notifyListeners();
      } else {
        // First item is a sub-location → find its parent emirate in the selected list
        final parentEmirate = selectedLocationList.firstWhere(
          (loc) => loc.location == null,
          orElse: () => LocationModel(),
        );

        if (parentEmirate.id != null && parentEmirate.location == null) {
          // Found parent emirate in the list → show its sub-locations
          popularLocationList =
              await fetchEmiratesSubLocations(emirateId: parentEmirate.id!);
          // Filter out already selected SUB-LOCATIONS only (not emirates)
          // Only filter sub-locations that match SELECTED SUB-LOCATIONS (not emirates)
          final selectedSubLocationIds = selectedLocationList
              .where((s) =>
                  s.location != null &&
                  s.id != null) // Only selected sub-locations
              .map((s) => s.id!)
              .toSet();
          popularLocationList.removeWhere((loc) =>
              loc.location != null && // Only filter sub-locations
              loc.id != null &&
              selectedSubLocationIds
                  .contains(loc.id)); // Only if matches a selected sub-location
          notifyListeners();
        } else {
          // No parent emirate found in selection → show all emirates
          popularLocationList = await fetchEmirates();
          // Filter out already selected items
          popularLocationList.removeWhere((loc) =>
              selectedLocationList.any((selected) => selected.id == loc.id));
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('❌ Error updating popular search based on first item: $e');
      // Fallback to showing emirates on error
      popularLocationList = await fetchEmirates();
      // Filter out already selected items
      popularLocationList.removeWhere((loc) =>
          selectedLocationList.any((selected) => selected.id == loc.id));
      notifyListeners();
    }
  }

  Future<void> addSelectedLocation(
      {required LocationModel locationModel}) async {
    // Check if already selected - must match both ID and type (emirate vs sub-location)
    // Emirates have location == null, sub-locations have location != null
    final isAlreadySelected = selectedLocationList.any((loc) =>
        loc.id == locationModel.id &&
        (loc.location == null) == (locationModel.location == null));

    if (isAlreadySelected) {
      debugPrint(
          '⚠️ Location already selected: ${locationModel.location ?? locationModel.country} (ID: ${locationModel.id})');
      notifyListeners();
      return;
    }

    // Check if this item is from last search list
    final isFromLastSearch = lastSearchList.any((lastSearch) =>
        lastSearch.id == locationModel.id &&
        (lastSearch.location == null) == (locationModel.location == null));

    // Add to selected list (insert at index 0 to make it first)
    selectedLocationList.insert(0, locationModel);
    debugPrint(
        '✅ Added location: ${locationModel.location ?? locationModel.country} (ID: ${locationModel.id})');

    // Remove from last search list if it came from there
    if (isFromLastSearch) {
      lastSearchList.removeWhere((e) =>
          e.id == locationModel.id &&
          (e.location == null) == (locationModel.location == null));
      debugPrint('🗑️ Removed from last search list');
    }

    // Remove from popular list locally - only remove if it matches both ID and type
    popularLocationList.removeWhere((e) =>
        e.id == locationModel.id &&
        (e.location == null) == (locationModel.location == null));

    // Update popular search based on the first item (which is now the newly added item)
    // If item has emirateId, always fetch sub-locations using that emirateId
    if (locationModel.emirateId != null) {
      // Always fetch sub-locations when selecting from last search (or any item with emirateId)
      popularLocationList =
          await fetchEmiratesSubLocations(emirateId: locationModel.emirateId!);

      // Filter out already selected sub-locations
      final selectedSubLocationIds = selectedLocationList
          .where((s) => s.location != null && s.id != null)
          .map((s) => s.id!)
          .toSet();
      popularLocationList.removeWhere((loc) =>
          loc.location != null &&
          loc.id != null &&
          selectedSubLocationIds.contains(loc.id));

      debugPrint(
          '📋 Fetched sub-locations for emirate ${locationModel.emirateId}');
      notifyListeners();
    } else {
      // Use standard logic for items without emirateId
      await updatePopularSearchBasedOnFirstItem();
    }
  }

  void updatePopularSearchLocally(LocationModel locModel) {
    // Only add if not already in the list
    if (!popularLocationList.any((loc) => loc.id == locModel.id)) {
      popularLocationList.insert(0, locModel);
    }
    notifyListeners();
  }
}
