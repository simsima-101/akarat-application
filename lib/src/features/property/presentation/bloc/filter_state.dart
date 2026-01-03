part of 'filter_bloc.dart';

// Models
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

// State
class FilterState {
  final int selectedTab;
  final int selectedProductIndex;
  final int? propertyType;
  final String? propertyCategory;
  final PropertyTypeResponse? propertyTypeModel;

  final double minPrice;
  final double maxPrice;
  final double minArea;
  final double maxArea;

  final List<ChartData> chartData;
  final List<ChartDataArea> chartDataArea;

  final List<String> selectedBedrooms;
  final List<String> selectedBathrooms;
  final List<String> selectedLocations;

  final List<Amenity> amenities;
  final List<int> selectedAmenitiesIds;

  final List<String> furnishedTypes;
  final int selectedFurnishedIndex;

  final List<String> completion;
  final int? selectedCompletionIndex;

  final List<String> handoverOptions;
  final int selectedHandoverIndex;

  final List<String> percentCompletionOptions;
  final int selectedPercentCompletionIndex;

  final List<String> rentPaidOptions;
  final int selectedRentPaidIndex;

  final String agentOrAgencySearchText;

  final bool isLoading;
  final bool isSearchingResults;
  final bool hasChanges;

  final List<String> bedroomList;
  final List<String> bathroomList;

  final int filterResultCount; // ← Added

  FilterState({
    this.selectedTab = 0,
    this.selectedProductIndex = 1,
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
    this.handoverOptions = const ['Q1 2025', 'Q2 2025', 'Q3 2025', 'Q4 2025', '2026', '2027', 'Ready'],
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
    this.filterResultCount = 107617,
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
    int? filterResultCount,
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
      selectedPercentCompletionIndex: selectedPercentCompletionIndex ?? this.selectedPercentCompletionIndex,
      rentPaidOptions: rentPaidOptions ?? this.rentPaidOptions,
      selectedRentPaidIndex: selectedRentPaidIndex ?? this.selectedRentPaidIndex,
      agentOrAgencySearchText: agentOrAgencySearchText ?? this.agentOrAgencySearchText,
      isLoading: isLoading ?? this.isLoading,
      isSearchingResults: isSearchingResults ?? this.isSearchingResults,
      hasChanges: hasChanges ?? this.hasChanges,
      bedroomList: bedroomList ?? this.bedroomList,
      bathroomList: bathroomList ?? this.bathroomList,
      filterResultCount: filterResultCount ?? this.filterResultCount,
    );
  }

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