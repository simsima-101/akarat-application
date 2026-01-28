import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';

import '../../device_id.dart';
import '../core/services/api_service.dart';
import '../core/utils/secure_storage.dart';
import '../features/property/data/models/location_model.dart';

class LocationPickerProvider extends ChangeNotifier {
  Future<void> clearAll() async {
    List<LocationModel> snapshot = [];
    if (selectedLocationList.isNotEmpty) {
      snapshot = List<LocationModel>.from(selectedLocationList);
    }

    clearSearchSuggestions();
    selectedLocationList.clear();

    // Reset popular search to show emirates
    popularLocationList = await fetchEmirates();
    notifyListeners();

    if (snapshot.isNotEmpty) {
      await saveLastSearch(snapshot);
    }
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

    // Remove using ID and type comparison (not object equality)
    selectedLocationList.removeWhere((loc) =>
        loc.id == locModel.id &&
        (loc.location == null) == (locModel.location == null));

    debugPrint(
        '🗑️ Removed location: ${locModel.location ?? locModel.country} (ID: ${locModel.id})');

    // Save to last search via API
    await saveLastSearch([locModel]);

    // Update popular search based on the new first item in selectedLocationList
    debugPrint('🔄 Updating popular search based on first item after removal');
    if (selectedLocationList.isNotEmpty) {
      debugPrint(
          '📌 First item after removal: ${selectedLocationList.first.location ?? selectedLocationList.first.country} (ID: ${selectedLocationList.first.id})');
    } else {
      debugPrint('📌 No items in selected list after removal');
    }
    await updatePopularSearchBasedOnFirstItem();

    // Add back to popular search if appropriate (after updating)
    // Check what we're currently showing in popular search
    // If popularLocationList contains items with location == null, we're showing emirates
    final isShowingEmirates = popularLocationList.isNotEmpty &&
        popularLocationList.any((loc) => loc.location == null);

    if (locModel.location != null) {
      // Removed a sub-location
      // Add it back if we're showing sub-locations (not emirates)
      if (!isShowingEmirates && popularLocationList.isNotEmpty) {
        // Check if it belongs to the emirate we're showing sub-locations for
        // All sub-locations in popularLocationList should have the same emirateId
        final firstSubLocation = popularLocationList.firstWhere(
          (loc) => loc.location != null,
          orElse: () => LocationModel(),
        );
        if (firstSubLocation.emirateId != null &&
            locModel.emirateId == firstSubLocation.emirateId) {
          updatePopularSearchLocally(locModel);
        }
      }
    } else {
      // Removed an emirate
      // Add it back if we're showing emirates
      if (isShowingEmirates) {
        updatePopularSearchLocally(locModel);
      }
    }
  }

  ////////////////////////// ⬇⬇⬇  FETCH LAST SEARCH FUNCTIONALITY  ⬇⬇⬇ //////////////////////////

  bool isLoadingLastSearch = false;
  List<LocationModel> lastSearchList = [];

  LocationModel _normalizeLocationForLastSearch(LocationModel locModel) {
    if (locModel.location == null) {
      return LocationModel(
        id: locModel.id,
        slug: locModel.slug,
        country: locModel.country ?? locModel.location,
        location: null,
        emirateId: locModel.emirateId ?? locModel.id,
      );
    }
    return LocationModel(
      id: locModel.id,
      slug: locModel.slug,
      country: locModel.country,
      location: locModel.location,
      emirateId: locModel.emirateId,
    );
  }

  LocationModel _mapLastSearchItem(Map<String, dynamic> data) {
    final sublocationId = data['sublocation_id'];
    final emirateId = data['emirate_id'];
    final locationName = data['location'];
    final countryName = data['country'];

    if (sublocationId == null || sublocationId == 0) {
      // Treat as emirate
      return LocationModel(
        id: emirateId,
        slug: data['slug'],
        country: locationName ?? countryName,
        location: null,
        emirateId: emirateId,
      );
    } else {
      return LocationModel(
        id: sublocationId,
        slug: data['slug'],
        country: countryName,
        location: locationName ?? countryName,
        emirateId: emirateId,
      );
    }
  }

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

      // final uri = Uri.parse('${ApiService.baseUrl}/last-search');
      // final response = await http.get(
      //   uri,
      //   headers: token != null
      //       ? {
      //           'Accept': 'application/json',
      //           'Authorization': 'Bearer $token',
      //           'X-Device-ID': deviceId,
      //         }
      //       : {
      //           'Accept': 'application/json',
      //           'X-Device-ID': deviceId,
      //         },
      // );

      final response = await ApiService.get(
        'last-search',
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'X-Device-ID': deviceId,
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map && decoded['data'] is List) {
          lastSearchList = (decoded['data'] as List)
              .whereType<Map<String, dynamic>>()
              .map(_mapLastSearchItem)
              .toList();
          debugPrint('👀👀👀👀: ${lastSearchList.length}');
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
    final normalized = _normalizeLocationForLastSearch(locModel);
    lastSearchList.removeWhere((loc) =>
        loc.id == normalized.id &&
        (loc.location == null) == (normalized.location == null));
    lastSearchList.insert(0, normalized);
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

      // final uri = Uri.parse('${ApiService.baseUrl}/emirates');
      // final response = await http.get(uri);
      final response = await ApiService.get('emirates');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          emiratesList = decoded.map((e) => LocationModel.fromJson(e)).toList();
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
      //
      // final uri =
      //     Uri.parse('${ApiService.baseUrl}/emirates-sub-location/$emirateId');
      // final response = await http.get(uri);

      final response = await ApiService.get('emirates-sub-location/$emirateId');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          emiratesSubLocationList =
              decoded.map((e) => LocationModel.fromJson(e)).toList();
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

  Future<void> saveLastSearch(List<LocationModel> locations) async {
    if (locations.isEmpty) return;

    final normalizedLocations =
        locations.map(_normalizeLocationForLastSearch).toList();

    // Optimistically update UI so removing a location immediately places it in last search
    for (final item in normalizedLocations.reversed) {
      updateLastSearchLocally(item);
    }

    final locationTexts = normalizedLocations
        .map((loc) => loc.location ?? loc.country ?? loc.slug)
        .where((name) => name != null && name.trim().isNotEmpty)
        .map((name) => name!.trim())
        .toList();

    if (locationTexts.isEmpty) {
      debugPrint('⚠️ Cannot save last search, missing location text(s)');
      return;
    }

    final token = await SecureStorage.getToken();
    debugPrint('token: $token');

    final deviceId = await getDeviceId();
    debugPrint('device id: $deviceId');

    if (deviceId == null) {
      debugPrint('❌❌❌ Device ID is NULL : $deviceId');
      return;
    }

    try {
      // final headers = {
      //   'Accept': 'application/json',
      //   'Content-Type': 'application/json',
      //   'X-Device-ID': deviceId,
      //   if (token != null) 'Authorization': 'Bearer $token',
      // };
      //
      // final uri = Uri.parse('${ApiService.baseUrl}/save-last-search');
      //
      // final response = await http.post(
      //   uri,
      //   headers: headers,
      //   body: jsonEncode({'locations': locationTexts}),
      // );

      final response = await ApiService.post(
        'save-last-search',
        body: {'locations': locationTexts},
        headers: {
          'X-Device-ID': deviceId ?? '',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded['success'] == true) {
          final data = decoded['data'];

          if (data is List) {
            final mapped = data
                .whereType<Map<String, dynamic>>()
                .map(_mapLastSearchItem)
                .toList();

            if (mapped.isNotEmpty) {
              for (final item in mapped.reversed) {
                if (item.id != null) {
                  updateLastSearchLocally(item);
                }
              }
              debugPrint(
                  '🎯 Added ${mapped.length} search item(s) to last search list');
              return;
            }
          } else if (data is Map<String, dynamic>) {
            final newItem = _mapLastSearchItem(data);
            if (newItem.id != null) {
              updateLastSearchLocally(newItem);
            }
            debugPrint('🎯 Added new search to list: ${newItem.location}');
            debugPrint('📌 Total items: ${lastSearchList.length}');
            return;
          }

          // If API response doesn't include usable data, fallback to normalized list
          debugPrint(
              '⚠️ API response missing usable data, fallback to local update');
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
  /// - If first item is emirate (location == null) → show its sub-locations
  /// - If first item is sub-location (location != null) → find parent emirate using emirateId → show parent's sub-locations
  /// - If no parent emirate found → show all emirates
  Future<void> updatePopularSearchBasedOnFirstItem() async {
    try {
      if (selectedLocationList.isEmpty) {
        // No selection → show emirates
        popularLocationList = await fetchEmirates();
        notifyListeners();
        return;
      }

      // Get the first item (most recently selected)
      final firstItem = selectedLocationList.first;

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
        // First item is a sub-location → find its parent emirate
        // First try to find parent emirate in selected list
        LocationModel? parentEmirate;
        if (firstItem.emirateId != null) {
          parentEmirate = selectedLocationList.firstWhere(
            (loc) => loc.location == null && loc.id == firstItem.emirateId,
            orElse: () => LocationModel(),
          );

          // If not found in selected list, use emirateId directly
          if (parentEmirate?.id == null && firstItem.emirateId != null) {
            parentEmirate = LocationModel(
              id: firstItem.emirateId,
              country: null,
              location: null,
            );
          }
        }

        if (parentEmirate?.id != null) {
          // Found parent emirate → show its sub-locations
          popularLocationList =
              await fetchEmiratesSubLocations(emirateId: parentEmirate!.id!);
          debugPrint(
              '📋 Fetched ${popularLocationList.length} sub-locations for parent emirate ${parentEmirate.id}');
          // Filter out already selected SUB-LOCATIONS only (not emirates)
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
          // No parent emirate found → show all emirates
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

    // Add to selected list (insert at index 0 to make it first)
    selectedLocationList.insert(0, locationModel);
    debugPrint(
        '✅ Added location: ${locationModel.location ?? locationModel.country} (ID: ${locationModel.id})');

    // Remove from popular list locally - only remove if it matches both ID and type
    final beforePopularCount = popularLocationList.length;
    popularLocationList.removeWhere((e) =>
        e.id == locationModel.id &&
        (e.location == null) == (locationModel.location == null));
    final afterPopularCount = popularLocationList.length;
    if (beforePopularCount != afterPopularCount) {
      debugPrint(
          '🗑️ Removed from popular search: ${locationModel.location ?? locationModel.country} (ID: ${locationModel.id})');
    }

    // Remove from last search list locally - only remove if it matches both ID and type
    final beforeLastCount = lastSearchList.length;
    lastSearchList.removeWhere((e) =>
        e.id == locationModel.id &&
        (e.location == null) == (locationModel.location == null));
    final afterLastCount = lastSearchList.length;
    if (beforeLastCount != afterLastCount) {
      debugPrint(
          '🗑️ Removed from last search: ${locationModel.location ?? locationModel.country} (ID: ${locationModel.id})');
    } else {
      debugPrint(
          '⚠️ Could not remove from last search: ${locationModel.location ?? locationModel.country} (ID: ${locationModel.id})');
      debugPrint(
          '   Last search list IDs: ${lastSearchList.map((e) => '${e.id}(${e.location == null ? "emirate" : "sub-loc"})').join(", ")}');
      debugPrint(
          '   Trying to remove: ID=${locationModel.id}, type=${locationModel.location == null ? "emirate" : "sub-loc"}');
    }

    // Update popular search based on the first item (which is now the newly added item)
    await updatePopularSearchBasedOnFirstItem();
  }

  /// Selects a location from last search - always fetches sub-locations
  /// regardless of whether the selected item is an emirate or sub-location
  Future<void> addSelectedLocationFromLastSearch(
      {required LocationModel locationModel}) async {
    // Check if already selected - must match both ID and type (emirate vs sub-location)
    final isAlreadySelected = selectedLocationList.any((loc) =>
        loc.id == locationModel.id &&
        (loc.location == null) == (locationModel.location == null));

    if (isAlreadySelected) {
      debugPrint(
          '⚠️ Location already selected: ${locationModel.location ?? locationModel.country} (ID: ${locationModel.id})');
      notifyListeners();
      return;
    }

    // Add to selected list (insert at index 0 to make it first)
    selectedLocationList.insert(0, locationModel);
    debugPrint(
        '✅ Added location from last search: ${locationModel.location ?? locationModel.country} (ID: ${locationModel.id})');

    // Remove from popular list locally
    popularLocationList.removeWhere((e) =>
        e.id == locationModel.id &&
        (e.location == null) == (locationModel.location == null));

    // Remove from last search list locally
    lastSearchList.removeWhere((e) =>
        e.id == locationModel.id &&
        (e.location == null) == (locationModel.location == null));

    // Always fetch sub-locations when selecting from last search
    // Determine which emirate's sub-locations to fetch
    int? emirateIdToFetch;

    if (locationModel.location == null) {
      // It's an emirate, use its ID
      emirateIdToFetch = locationModel.id;
    } else {
      // It's a sub-location, use its emirateId
      emirateIdToFetch = locationModel.emirateId;
    }

    if (emirateIdToFetch != null) {
      // Fetch sub-locations for the determined emirate
      isLoadingPopularSearch = true;
      notifyListeners();

      try {
        popularLocationList =
            await fetchEmiratesSubLocations(emirateId: emirateIdToFetch);
        debugPrint(
            '📋 Fetched ${popularLocationList.length} sub-locations for emirate $emirateIdToFetch');

        // Filter out already selected sub-locations
        final selectedSubLocationIds = selectedLocationList
            .where((s) => s.location != null && s.id != null)
            .map((s) => s.id!)
            .toSet();
        popularLocationList.removeWhere((loc) =>
            loc.location != null &&
            loc.id != null &&
            selectedSubLocationIds.contains(loc.id));
      } catch (e) {
        debugPrint('❌ Error fetching sub-locations: $e');
        // Fallback to updating based on first item
        await updatePopularSearchBasedOnFirstItem();
      }

      isLoadingPopularSearch = false;
      notifyListeners();
    } else {
      // Fallback to updating based on first item
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

  ////////////////////////// ⬇⬇⬇ FETCH LOCATIONS SUGGESTIONS ⬇⬇⬇ //////////////////////////

  TextEditingController searchController = TextEditingController();

  List<LocationModel> locationSuggestionsList = [];

  Future<void> fetchLocationSuggestions(String query) async {
    final q = query.toString().toLowerCase().trim();

    // final uri = Uri.parse('${ApiService.baseUrl}/locations?q=$q');

    try {
      // final response = await http.get(uri);

      final response = await ApiService.get(
        'locations',
        query: {'q': q},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        locationSuggestionsList =
            data.map((e) => LocationModel.fromJson(e)).toList();

        // Remove already-selected items from suggestions
        locationSuggestionsList.removeWhere((suggestion) {
          return selectedLocationList.any((selected) {
            // CASE 1: Country (parent) suggestion
            if (suggestion.location == null) {
              return selected.country == suggestion.location;
            }

            // CASE 2: Sub-location suggestion
            return selected.location == suggestion.location;
          });
        });

        notifyListeners();
        debugPrint(
            ' Suggestion list Length: ${locationSuggestionsList.length}');
      } else {
        print('❌ Failed to load suggestions: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error while fetching locations: $e');
    }
  }

  void clearSearchSuggestions() {
    searchController.clear();
    locationSuggestionsList.clear();
    notifyListeners();
  }
}
