// // lib/features/property/presentation/bloc/location_picker_bloc.dart
//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../data/models/location_model.dart';
//
// // ====================== EVENTS ======================
// abstract class LocationPickerEvent {}
//
// class SearchLocations extends LocationPickerEvent {
//   final String query;
//   SearchLocations({required this.query});
// }
//
// class ClearLocationSuggestions extends LocationPickerEvent {}
//
// class SelectLocation extends LocationPickerEvent {  // ← Renamed from AddLocation
//   final LocationModel location;
//   SelectLocation({required this.location});
// }
//
// class DeselectLocation extends LocationPickerEvent {  // ← Renamed from RemoveLocation
//   final LocationModel location;
//   DeselectLocation({required this.location});
// }
//
// class ClearAllLocations extends LocationPickerEvent {}
//
// class LoadLastSearchedLocations extends LocationPickerEvent {}
//
// class UpdatePopularSearches extends LocationPickerEvent {}
//
// class LoadPopularSearches extends LocationPickerEvent {
//   final int? locationId;
//   LoadPopularSearches({this.locationId});
// }
//
// // ====================== STATE ======================
// class LocationPickerState {
//   final List<LocationModel> selectedLocations;
//   final List<LocationModel> suggestions;
//   final List<LocationModel> lastSearched;
//   final List<LocationModel> popularLocations;
//   final bool isLoadingPopular;
//   final TextEditingController searchController;
//
//   LocationPickerState({
//     required this.selectedLocations,
//     required this.suggestions,
//     required this.lastSearched,
//     required this.popularLocations,
//     required this.isLoadingPopular,
//     required this.searchController,
//   });
//
//   factory LocationPickerState.initial() {
//     return LocationPickerState(
//       selectedLocations: [],
//       suggestions: [],
//       lastSearched: [],
//       popularLocations: [],
//       isLoadingPopular: false,
//       searchController: TextEditingController(),
//     );
//   }
//
//   LocationPickerState copyWith({
//     List<LocationModel>? selectedLocations,
//     List<LocationModel>? suggestions,
//     List<LocationModel>? lastSearched,
//     List<LocationModel>? popularLocations,
//     bool? isLoadingPopular,
//     TextEditingController? searchController,
//   }) {
//     return LocationPickerState(
//       selectedLocations: selectedLocations ?? this.selectedLocations,
//       suggestions: suggestions ?? this.suggestions,
//       lastSearched: lastSearched ?? this.lastSearched,
//       popularLocations: popularLocations ?? this.popularLocations,
//       isLoadingPopular: isLoadingPopular ?? this.isLoadingPopular,
//       searchController: searchController ?? this.searchController,
//     );
//   }
// }
//
// // ====================== BLOC ======================
// class LocationPickerBloc extends Bloc<LocationPickerEvent, LocationPickerState> {
//   LocationPickerBloc() : super(LocationPickerState.initial()) {
//     on<SearchLocations>(_onSearchLocations);
//     on<ClearLocationSuggestions>(_onClearSuggestions);
//     on<SelectLocation>(_onSelectLocation);           // ← Updated
//     on<DeselectLocation>(_onDeselectLocation);       // ← Updated
//     on<ClearAllLocations>(_onClearAll);
//     on<LoadLastSearchedLocations>(_onLoadLastSearched);
//     on<UpdatePopularSearches>(_onUpdatePopularSearches);
//     on<LoadPopularSearches>(_onLoadPopularSearches);
//   }
//
//   Future<void> _onSearchLocations(
//       SearchLocations event, Emitter<LocationPickerState> emit) async {
//     final mockSuggestions = [
//       LocationModel(id: 1, location: "${event.query} Marina", country: "UAE"),
//       LocationModel(id: 2, location: "${event.query} Hills", country: "UAE"),
//       LocationModel(id: 3, location: "${event.query} Downtown", country: "UAE"),
//     ];
//
//     emit(state.copyWith(suggestions: mockSuggestions));
//   }
//
//   void _onClearSuggestions(
//       ClearLocationSuggestions event, Emitter<LocationPickerState> emit) {
//     state.searchController.clear();
//     emit(state.copyWith(suggestions: []));
//   }
//
//   void _onSelectLocation(SelectLocation event, Emitter<LocationPickerState> emit) {
//     final updated = List<LocationModel>.from(state.selectedLocations)
//       ..add(event.location);
//
//     emit(state.copyWith(selectedLocations: updated));
//   }
//
//   void _onDeselectLocation(DeselectLocation event, Emitter<LocationPickerState> emit) {
//     final updated = state.selectedLocations
//         .where((loc) => loc.id != event.location.id)
//         .toList();
//
//     emit(state.copyWith(selectedLocations: updated));
//   }
//
//   void _onClearAll(ClearAllLocations event, Emitter<LocationPickerState> emit) {
//     state.searchController.clear();
//     emit(state.copyWith(
//       selectedLocations: [],
//       suggestions: [],
//     ));
//   }
//
//   void _onLoadLastSearched(
//       LoadLastSearchedLocations event, Emitter<LocationPickerState> emit) async {
//     final mockLast = [
//       LocationModel(id: 10, location: "Jumeirah Beach Residence", country: "UAE"),
//       LocationModel(id: 11, location: "Palm Jumeirah", country: "UAE"),
//     ];
//
//     emit(state.copyWith(lastSearched: mockLast));
//   }
//
//   void _onUpdatePopularSearches(
//       UpdatePopularSearches event, Emitter<LocationPickerState> emit) {
//     int? locationId;
//     if (state.selectedLocations.isNotEmpty) {
//       final first = state.selectedLocations.first;
//       locationId = first.location == null ? first.id : first.emirateId;
//     }
//
//     add(LoadPopularSearches(locationId: locationId));
//   }
//
//   Future<void> _onLoadPopularSearches(
//       LoadPopularSearches event, Emitter<LocationPickerState> emit) async {
//     emit(state.copyWith(isLoadingPopular: true));
//
//     await Future.delayed(const Duration(seconds: 1));
//
//     final mockPopular = [
//       LocationModel(id: 20, location: "Dubai Marina", country: "UAE"),
//       LocationModel(id: 21, location: "Downtown Dubai", country: "UAE"),
//       LocationModel(id: 22, location: "Palm Jumeirah", country: "UAE"),
//       LocationModel(id: 23, location: "Jumeirah Beach Residence", country: "UAE"),
//       LocationModel(id: 24, location: "Business Bay", country: "UAE"),
//     ];
//
//     emit(state.copyWith(
//       popularLocations: mockPopular,
//       isLoadingPopular: false,
//     ));
//   }
//
//   @override
//   Future<void> close() {
//     state.searchController.dispose();
//     return super.close();
//   }
// }
