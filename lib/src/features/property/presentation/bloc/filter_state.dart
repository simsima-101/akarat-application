part of 'filter_bloc.dart';

// Optional: Define your models here or import them
class PropertyTypeResponse {
  final List<PropertyCategory> data;
  PropertyTypeResponse({required this.data});

  factory PropertyTypeResponse.fromJson(Map<String, dynamic> json) {
    return PropertyTypeResponse(
      data: (json['data'] as List)
          .map((e) => PropertyCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PropertyCategory {
  final int? id;
  final String? name;
  final String? icon;

  PropertyCategory({this.id, this.name, this.icon});

  factory PropertyCategory.fromJson(Map<String, dynamic> json) {
    return PropertyCategory(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
    );
  }
}

class Amenity {
  final int id;
  final String title;
  final String? icon;

  Amenity({required this.id, required this.title, this.icon});

  factory Amenity.fromJson(Map<String, dynamic> json) {
    return Amenity(
      id: json['id'],
      title: json['title'] ?? '',
      icon: json['icon'],
    );
  }
}

class ChartData {
  final double x;
  final double y;
  ChartData(this.x, this.y);
}

class ChartDataArea {
  final double x;
  final double y;
  ChartDataArea(this.x, this.y);
}

class FilterState {
  // Tabs
  final int selectedTab; // 0 = Properties, 1 = New Projects

  // Purpose (Rent / Buy)
  final int selectedProductIndex; // 0 = Rent, 1 = Buy

  // Property Type (Residential / Commercial)
  final int? propertyType; // 0 = Residential, 1 = Commercial

  // Property Category (Apartment, Villa, etc.)
  final String? propertyCategory;

  // Dynamic loaded categories (from API)
  final PropertyTypeResponse? propertyTypeModel;

  // Price & Area
  final double minPrice;
  final double maxPrice;
  final double minArea;
  final double maxArea;

  // Chart data for sliders (optional visual bars)
  final List<ChartData> chartData;
  final List<ChartDataArea> chartDataArea;

  // Multi-select filters
  final List<String> selectedBedrooms;
  final List<String> selectedBathrooms;
  final List<String> selectedLocations;

  // Amenities
  final List<Amenity> amenities; // Full list from API
  final List<int> selectedAmenitiesIds;

  // Furnished Type (single select)
  final List<String> furnishedTypes;
  final int selectedFurnishedIndex; // -1 = none

  // Completion Status (Off-plan / Ready)
  final List<String> completion;
  final int? selectedCompletionIndex;

  // Handover By (Q1 2025, etc.)
  final List<String> handoverOptions;
  final int selectedHandoverIndex; // -1 = none

  // % Completion
  final List<String> percentCompletionOptions;
  final int selectedPercentCompletionIndex; // -1 = none

  // Rent is Paid (Yearly, Monthly, etc.)
  final List<String> rentPaidOptions;
  final int selectedRentPaidIndex; // -1 = none

  // Agent / Agency search
  final String agentOrAgencySearchText;

  // Loading & UI states
  final bool isLoading; // General loading (e.g. property types, amenities)
  final bool isSearchingResults; // Searching properties on "Show Results"
  final bool hasChanges;

  // Bedroom & Bathroom static lists (shown in UI)
  final List<String> bedroomList;
  final List<String> bathroomList;

  FilterState({
    this.selectedTab = 0,
    this.selectedProductIndex = 1, // Default to Buy
    this.propertyType,
    this.propertyCategory,
    this.propertyTypeModel,
    this.minPrice = 500,
    this.maxPrice = 300000,
    this.minArea = 0,
    this.maxArea = 10000,
    this.chartData = const [],
    this.chartDataArea = const [],
    this.selectedBedrooms = const [],
    this.selectedBathrooms = const [],
    this.selectedLocations = const [],
    this.amenities = const [],
    this.selectedAmenitiesIds = const [],
    this.furnishedTypes = const ['Unfurnished', 'Furnished', 'Semi-Furnished'],
    this.selectedFurnishedIndex = -1,
    this.completion = const ['Ready', 'Off-Plan'],
    this.selectedCompletionIndex,
    this.handoverOptions = const [
      'Q1 2025',
      'Q2 2025',
      'Q3 2025',
      'Q4 2025',
      '2026',
      '2027',
      'Ready'
    ],
    this.selectedHandoverIndex = -1,
    this.percentCompletionOptions = const ['0-25%', '26-50%', '51-75%', '76-100%'],
    this.selectedPercentCompletionIndex = -1,
    this.rentPaidOptions = const ['Yearly', 'Monthly', 'Quarterly', 'Weekly'],
    this.selectedRentPaidIndex = -1,
    this.agentOrAgencySearchText = '',
    this.isLoading = false,
    this.isSearchingResults = false,
    this.hasChanges = false,
    this.bedroomList = const ['Studio', '1', '2', '3', '4', '5', '6+'],
    this.bathroomList = const ['1', '2', '3', '4', '5', '6+'],
  });

  static final FilterState initial = FilterState();

  FilterState copyWith({
    int? selectedTab,
    int? selectedProductIndex,
    int? propertyType,
    String? propertyCategory,
    PropertyTypeResponse? propertyTypeModel,
    double? minPrice,
    double? maxPrice,
    double? minArea,
    double? maxArea,
    List<ChartData>? chartData,
    List<ChartDataArea>? chartDataArea,
    List<String>? selectedBedrooms,
    List<String>? selectedBathrooms,
    List<String>? selectedLocations,
    List<Amenity>? amenities,
    List<int>? selectedAmenitiesIds,
    List<String>? furnishedTypes,
    int? selectedFurnishedIndex,
    List<String>? completion,
    int? selectedCompletionIndex,
    List<String>? handoverOptions,
    int? selectedHandoverIndex,
    List<String>? percentCompletionOptions,
    int? selectedPercentCompletionIndex,
    List<String>? rentPaidOptions,
    int? selectedRentPaidIndex,
    String? agentOrAgencySearchText,
    bool? isLoading,
    bool? isSearchingResults,
    bool? hasChanges,
    List<String>? bedroomList,
    List<String>? bathroomList,
  }) {
    return FilterState(
      selectedTab: selectedTab ?? this.selectedTab,
      selectedProductIndex: selectedProductIndex ?? this.selectedProductIndex,
      propertyType: propertyType ?? this.propertyType,
      propertyCategory: propertyCategory ?? this.propertyCategory,
      propertyTypeModel: propertyTypeModel ?? this.propertyTypeModel,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minArea: minArea ?? this.minArea,
      maxArea: maxArea ?? this.maxArea,
      chartData: chartData ?? this.chartData,
      chartDataArea: chartDataArea ?? this.chartDataArea,
      selectedBedrooms: selectedBedrooms ?? this.selectedBedrooms,
      selectedBathrooms: selectedBathrooms ?? this.selectedBathrooms,
      selectedLocations: selectedLocations ?? this.selectedLocations,
      amenities: amenities ?? this.amenities,
      selectedAmenitiesIds: selectedAmenitiesIds ?? this.selectedAmenitiesIds,
      furnishedTypes: furnishedTypes ?? this.furnishedTypes,
      selectedFurnishedIndex: selectedFurnishedIndex ?? this.selectedFurnishedIndex,
      completion: completion ?? this.completion,
      selectedCompletionIndex: selectedCompletionIndex ?? this.selectedCompletionIndex,
      handoverOptions: handoverOptions ?? this.handoverOptions,
      selectedHandoverIndex: selectedHandoverIndex ?? this.selectedHandoverIndex,
      percentCompletionOptions: percentCompletionOptions ?? this.percentCompletionOptions,
      selectedPercentCompletionIndex:
      selectedPercentCompletionIndex ?? this.selectedPercentCompletionIndex,
      rentPaidOptions: rentPaidOptions ?? this.rentPaidOptions,
      selectedRentPaidIndex: selectedRentPaidIndex ?? this.selectedRentPaidIndex,
      agentOrAgencySearchText: agentOrAgencySearchText ?? this.agentOrAgencySearchText,
      isLoading: isLoading ?? this.isLoading,
      isSearchingResults: isSearchingResults ?? this.isSearchingResults,
      hasChanges: hasChanges ?? this.hasChanges,
      bedroomList: bedroomList ?? this.bedroomList,
      bathroomList: bathroomList ?? this.bathroomList,
    );
  }

  // Optional: Helpful getter to detect if any filter is active
  bool get hasActiveFilters =>
      selectedProductIndex != 1 ||
          propertyType != null ||
          propertyCategory != null ||
          minPrice != 500 ||
          maxPrice != 300000 ||
          minArea != 0 ||
          maxArea != 10000 ||
          selectedBedrooms.isNotEmpty ||
          selectedBathrooms.isNotEmpty ||
          selectedLocations.isNotEmpty ||
          selectedFurnishedIndex != -1 ||
          selectedCompletionIndex != null ||
          selectedHandoverIndex != -1 ||
          selectedPercentCompletionIndex != -1 ||
          selectedAmenitiesIds.isNotEmpty ||
          selectedRentPaidIndex != -1 ||
          agentOrAgencySearchText.isNotEmpty;
}