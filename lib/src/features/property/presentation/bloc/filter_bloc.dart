import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../../../screen/filter_list.dart';

part 'filter_event.dart';
part 'filter_state.dart';

class FilterBloc extends Bloc<FilterEvent, FilterState> {
  FilterBloc() : super(FilterState.initial) {
    // Tab switch: Properties ↔ New Projects
    on<SwitchTab>((event, emit) {
      emit(state.copyWith(
        selectedTab: event.tabIndex,
        hasChanges: true,
      ));
    });

    // Rent / Buy pills
    on<SelectProduct>((event, emit) {
      emit(state.copyWith(
        selectedProductIndex: event.index,
        hasChanges: true,
      ));
    });

    // Residential vs Commercial
    on<SelectPropertyType>((event, emit) {
      emit(state.copyWith(
        propertyType: event.type,
        propertyCategory: null,
        propertyTypeModel: null,
        hasChanges: true,
      ));

      if (event.type != null) {
        add(LoadPropertyTypes(event.type!)); // Now valid!
      }
    });

    // Category icons (Apartment, Villa, etc.)
    on<SelectPropertyCategory>((event, emit) {
      emit(state.copyWith(
        propertyCategory: event.category,
        hasChanges: true,
      ));
    });

    // Price range
    on<UpdatePriceRange>((event, emit) {
      emit(state.copyWith(
        minPrice: event.min,
        maxPrice: event.max,
        hasChanges: true,
      ));
    });

    // Area range
    on<UpdateAreaRange>((event, emit) {
      emit(state.copyWith(
        minArea: event.min,
        maxArea: event.max,
        hasChanges: true,
      ));
    });

    // Bedrooms multi-select
    on<ToggleBedroom>((event, emit) {
      final updated = List<String>.from(state.selectedBedrooms);
      if (updated.contains(event.bedroom)) {
        updated.remove(event.bedroom);
      } else {
        updated.add(event.bedroom);
      }
      emit(state.copyWith(selectedBedrooms: updated, hasChanges: true));
    });

    // Bathrooms multi-select
    on<ToggleBathroom>((event, emit) {
      final updated = List<String>.from(state.selectedBathrooms);
      if (updated.contains(event.bathroom)) {
        updated.remove(event.bathroom);
      } else {
        updated.add(event.bathroom);
      }
      emit(state.copyWith(selectedBathrooms: updated, hasChanges: true));
    });

    // Locations (if used)
    on<AddLocation>((event, emit) {
      final updated = List<String>.from(state.selectedLocations)..add(event.location);
      emit(state.copyWith(selectedLocations: updated, hasChanges: true));
    });

    on<RemoveLocation>((event, emit) {
      final updated = List<String>.from(state.selectedLocations)..remove(event.location);
      emit(state.copyWith(selectedLocations: updated, hasChanges: true));
    });

    // Furnished Type - single select by index (matches your UI)
    on<SelectFurnishedType>((event, emit) {
      emit(state.copyWith(
        selectedFurnishedIndex: event.index,
        hasChanges: true,
      ));
    });

    // Completion Status (Ready / Off-Plan)
    on<SelectCompletionStatus>((event, emit) {
      emit(state.copyWith(
        selectedCompletionIndex: event.index,
        hasChanges: true,
      ));
    });

    // Handover By (Q1 2025, etc.) - matches your UI call
    on<SelectHandover>((event, emit) {
      emit(state.copyWith(
        selectedHandoverIndex: event.index,
        hasChanges: true,
      ));
    });

    // % Completion
    on<SelectPercentCompletion>((event, emit) {
      emit(state.copyWith(
        selectedPercentCompletionIndex: event.index,
        hasChanges: true,
      ));
    });

    // Rent is Paid (Yearly, Monthly, etc.)
    on<SelectRentPaid>((event, emit) {
      emit(state.copyWith(
        selectedRentPaidIndex: event.index,
        hasChanges: true,
      ));
    });

    // Agent or Agency search text
    on<UpdateAgentOrAgencySearch>((event, emit) {
      emit(state.copyWith(
        agentOrAgencySearchText: event.text,
        hasChanges: true,
      ));
    });

    // Amenities - single toggle
    on<ToggleAmenity>((event, emit) {
      final updated = List<int>.from(state.selectedAmenitiesIds);
      if (updated.contains(event.amenityId)) {
        updated.remove(event.amenityId);
      } else {
        updated.add(event.amenityId);
      }
      emit(state.copyWith(selectedAmenitiesIds: updated, hasChanges: true));
    });

    // Amenities - bulk update from FullAmenitiesScreen
    on<UpdateSelectedAmenities>((event, emit) {
      emit(state.copyWith(
        selectedAmenitiesIds: event.selectedIds,
        hasChanges: true,
      ));
    });

    on<LoadPropertyTypes>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        final typeString = event.type == 0 ? 'Residential' : 'Commercial';
        final uri = Uri.https('akarat.com', '/api/property-types/$typeString');

        final response = await http.get(uri).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonData = json.decode(response.body);

          final PropertyTypeResponse responseModel = PropertyTypeResponse.fromJson(jsonData);

          emit(state.copyWith(
            propertyTypeModel: responseModel,
            isLoading: false,
          ));
        } else {
          debugPrint('Failed to load property types: ${response.statusCode}');
          emit(state.copyWith(
            propertyTypeModel: null,
            isLoading: false,
          ));
        }
      } catch (e) {
        debugPrint('Error loading property types: $e');
        emit(state.copyWith(
          propertyTypeModel: null,
          isLoading: false,
        ));
      }
    });

    // Load amenities from real /amenities endpoint
    on<LoadAmenities>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        // Use the same URL as in your old FilterProvider
        final uri = Uri.https('akarat.com', '/api/amenities');

        final response = await http.get(uri).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          // The response is a direct List of amenity objects
          final List<dynamic> jsonData = json.decode(response.body);

          final List<Amenity> loadedAmenities = jsonData
              .map((json) => Amenity.fromJson(json as Map<String, dynamic>))
              .toList();

          emit(state.copyWith(
            amenities: loadedAmenities,
            isLoading: false,
          ));
        } else {
          debugPrint('Failed to load amenities: ${response.statusCode}');
          emit(state.copyWith(
            amenities: [],
            isLoading: false,
          ));
        }
      } catch (e) {
        debugPrint('Error loading amenities: $e');
        emit(state.copyWith(
          amenities: [],
          isLoading: false,
        ));
      }
    });

    // Reset all filters
    on<ResetFilter>((event, emit) {
      emit(FilterState.initial.copyWith(hasChanges: false));
    });

    // Search properties (final submit)
    on<SearchProperties>((event, emit) async {
      emit(state.copyWith(isSearchingResults: true));
      try {
        // Call your search API here using all values from state
        // await repository.searchProperties(state.toJson());
        await Future.delayed(const Duration(seconds: 2)); // simulate network
        emit(state.copyWith(isSearchingResults: false));
        // Navigation is handled via BlocListener in UI
      } catch (e) {
        emit(state.copyWith(isSearchingResults: false));
      }
    });


    // Show Results button pressed
    on<ShowFilterResults>((event, emit) async {
      emit(state.copyWith(isSearchingResults: true));

      try {
        // TODO: Replace with real API call
        // final int resultCount = await repository.searchPropertiesCount(state);
        // For now, simulate API delay and random result count
        await Future.delayed(const Duration(seconds: 2));

        // Simulate result count (replace with real logic later)
        final int resultCount = 0; // Change to >0 to test success case

        if (resultCount > 0) {
          // Navigate to results list
          Navigator.of(event.context).push(
            MaterialPageRoute(
              settings: const RouteSettings(name: 'FliterList'),
              builder: (context) => const FliterList(),
            ),
          );
        } else {
          // Show "No Property Found" screen
          Navigator.of(event.context).push(
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  title: const Text('Results'),
                  backgroundColor: Colors.red,
                ),
                body: Container(
                  color: Colors.white,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/images/not_found.png",
                            width: 50, height: 50),
                        const SizedBox(height: 20),
                        const Text('No Property Found',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        const Text(
                          'Please select other filters to get results.',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        // Optional: Add a button to go back
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      } catch (e) {
        // Handle error (optional: show snackbar)
        ScaffoldMessenger.of(event.context).showSnackBar(
          const SnackBar(content: Text('Error searching properties')),
        );
      } finally {
        emit(state.copyWith(isSearchingResults: false));
      }
    });

    // From home screen category cards
    on<SetHomeCategory>((event, emit) {
      int selectedProductIndex = 0;
      String? propertyCategory;
      int? propertyType;

      switch (event.categoryIndex) {
        case 0: // Property For Rent
          selectedProductIndex = 0;
          break;
        case 1: // Property For Sale
          selectedProductIndex = 1;
          break;
        case 2: // Off-Plan Properties
          selectedProductIndex = 1;
          // Optionally set completion status to Off-Plan
          break;
        case 3: // Commercial
          propertyType = 1;
          selectedProductIndex = 0;
          break;
        case 4: // Villas
          propertyCategory = 'Villa';
          selectedProductIndex = 0;
          break;
        case 5: // Apartment
          propertyCategory = 'Apartment';
          selectedProductIndex = 0;
          break;
        default:
          selectedProductIndex = 0;
      }

      emit(state.copyWith(
        selectedProductIndex: selectedProductIndex,
        propertyType: propertyType,
        propertyCategory: propertyCategory,
        hasChanges: true,
      ));
    });
  }
}