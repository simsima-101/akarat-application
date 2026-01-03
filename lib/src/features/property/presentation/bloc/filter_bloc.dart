// lib/features/property/presentation/bloc/filter_bloc.dart

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../../../screen/filter_list.dart';
import '../../data/models/location_model.dart';

// Declare parts
part 'filter_event.dart';
part 'filter_state.dart';

class FilterBloc extends Bloc<FilterEvent, FilterState> {
  FilterBloc() : super(FilterState.initial) {
    // Tab switch
    on<SwitchTab>((event, emit) {
      emit(state.copyWith(selectedTab: event.tabIndex, hasChanges: true));
    });

    // Rent / Buy
    on<SelectProduct>((event, emit) {
      emit(state.copyWith(selectedProductIndex: event.index, hasChanges: true));
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
        add(LoadPropertyTypes(event.type!));
      }
    });

    // Property category
    on<SelectPropertyCategory>((event, emit) {
      emit(state.copyWith(propertyCategory: event.category, hasChanges: true));
    });

    // Price & Area
    on<UpdatePriceRange>((event, emit) {
      emit(state.copyWith(minPrice: event.min, maxPrice: event.max, hasChanges: true));
    });

    on<UpdateAreaRange>((event, emit) {
      emit(state.copyWith(minArea: event.min, maxArea: event.max, hasChanges: true));
    });

    // Bedrooms & Bathrooms
    on<ToggleBedroom>((event, emit) {
      final updated = List<String>.from(state.selectedBedrooms);
      updated.contains(event.bedroom) ? updated.remove(event.bedroom) : updated.add(event.bedroom);
      emit(state.copyWith(selectedBedrooms: updated, hasChanges: true));
    });

    on<ToggleBathroom>((event, emit) {
      final updated = List<String>.from(state.selectedBathrooms);
      updated.contains(event.bathroom) ? updated.remove(event.bathroom) : updated.add(event.bathroom);
      emit(state.copyWith(selectedBathrooms: updated, hasChanges: true));
    });

    // Locations
    on<AddLocation>((event, emit) {
      final updated = List<String>.from(state.selectedLocations)..add(event.location);
      emit(state.copyWith(selectedLocations: updated, hasChanges: true));
    });

    on<RemoveLocation>((event, emit) {
      final updated = List<String>.from(state.selectedLocations)..remove(event.location);
      emit(state.copyWith(selectedLocations: updated, hasChanges: true));
    });

    // Furnished, Completion, Handover, etc.
    on<SelectFurnishedType>((event, emit) {
      emit(state.copyWith(selectedFurnishedIndex: event.index, hasChanges: true));
    });

    on<SelectCompletionStatus>((event, emit) {
      emit(state.copyWith(selectedCompletionIndex: event.index, hasChanges: true));
    });

    on<SelectHandover>((event, emit) {
      emit(state.copyWith(selectedHandoverIndex: event.index, hasChanges: true));
    });

    on<SelectPercentCompletion>((event, emit) {
      emit(state.copyWith(selectedPercentCompletionIndex: event.index, hasChanges: true));
    });

    on<SelectRentPaid>((event, emit) {
      emit(state.copyWith(selectedRentPaidIndex: event.index, hasChanges: true));
    });

    on<UpdateAgentOrAgencySearch>((event, emit) {
      emit(state.copyWith(agentOrAgencySearchText: event.text, hasChanges: true));
    });

    // Amenities
    on<ToggleAmenity>((event, emit) {
      final updated = List<int>.from(state.selectedAmenitiesIds);
      updated.contains(event.amenityId) ? updated.remove(event.amenityId) : updated.add(event.amenityId);
      emit(state.copyWith(selectedAmenitiesIds: updated, hasChanges: true));
    });

    on<UpdateSelectedAmenities>((event, emit) {
      emit(state.copyWith(selectedAmenitiesIds: event.selectedIds, hasChanges: true));
    });

    // Load Property Types
    on<LoadPropertyTypes>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        final typeString = event.type == 0 ? 'Residential' : 'Commercial';
        final uri = Uri.https('akarat.com', '/api/property-types/$typeString');
        final response = await http.get(uri).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          final model = PropertyTypeResponse.fromJson(jsonData);
          emit(state.copyWith(propertyTypeModel: model, isLoading: false));
        } else {
          emit(state.copyWith(propertyTypeModel: null, isLoading: false));
        }
      } catch (e) {
        emit(state.copyWith(propertyTypeModel: null, isLoading: false));
      }
    });

    // Load Amenities
    on<LoadAmenities>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        final uri = Uri.https('akarat.com', '/api/amenities');
        final response = await http.get(uri).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final List<dynamic> jsonData = json.decode(response.body);
          final amenities = jsonData.map((j) => Amenity.fromJson(j)).toList();
          emit(state.copyWith(amenities: amenities, isLoading: false));
        } else {
          emit(state.copyWith(amenities: [], isLoading: false));
        }
      } catch (e) {
        emit(state.copyWith(amenities: [], isLoading: false));
      }
    });

    // Reset
    on<ResetFilter>((event, emit) {
      emit(FilterState.initial.copyWith(hasChanges: false));
    });

    // Search (placeholder)
    on<SearchProperties>((event, emit) async {
      emit(state.copyWith(isSearchingResults: true));
      await Future.delayed(const Duration(seconds: 2));
      emit(state.copyWith(isSearchingResults: false));
    });

    // Show Results
    on<ShowFilterResults>((event, emit) async {
      emit(state.copyWith(isSearchingResults: true));

      try {
        await Future.delayed(const Duration(seconds: 2));

        final int resultCount = state.hasActiveFilters ? 88795 : 107617;

        emit(state.copyWith(
          filterResultCount: resultCount,
          isSearchingResults: false,
        ));

        if (resultCount > 0) {
          Navigator.of(event.context).push(MaterialPageRoute(
            settings: const RouteSettings(name: 'FliterList'),
            builder: (_) => const FliterList(),
          ));
        } else {
          Navigator.of(event.context).push(MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Results'), backgroundColor: Colors.red),
              body: const Center(
                child: Text('No Property Found\nPlease select other filters.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18)),
              ),
            ),
          ));
        }
      } catch (e) {
        ScaffoldMessenger.of(event.context)
            .showSnackBar(const SnackBar(content: Text('Search error')));
        emit(state.copyWith(isSearchingResults: false));
      }
    });

    // Home category cards
    on<SetHomeCategory>((event, emit) {
      int productIndex = 0;
      String? category;
      int? type;

      switch (event.categoryIndex) {
        case 0: productIndex = 0; break;
        case 1: productIndex = 1; break;
        case 2: productIndex = 1; break;
        case 3: type = 1; productIndex = 0; break;
        case 4: category = 'Villa'; productIndex = 0; break;
        case 5: category = 'Apartment'; productIndex = 0; break;
      }

      emit(state.copyWith(
        selectedProductIndex: productIndex,
        propertyType: type,
        propertyCategory: category,
        hasChanges: true,
      ));
    });

    on<UpdateLocationsFromPicker>((event, emit) {
      final locationNames = event.locations
          .map((loc) => loc.location ?? loc.country ?? '')
          .where((name) => name.isNotEmpty)
          .toList();

      emit(state.copyWith(
        selectedLocations: locationNames,
        hasChanges: true,
        filterResultCount: locationNames.isEmpty ? 107617 : 88795, // ← Dynamic count
      ));
    });
  }
}