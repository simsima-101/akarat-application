// // STATE FILE
//
// // filter_state.dart
// part of 'filter_bloc.dart';
//
// class FilterState extends Equatable {
//   final int displayedFilterResultCount;
//   final int selected;
//   final List<Amenities> selectedAmenities;
//   final int selectedHandover;
//   final int selectedCompletion;
//   final int? selectedPropType;
//   final int selectedPercentCompletion;
//   final bool isFromFilterList;
//
//   SfRangeValues values;
//   SfRangeValues valuesArea;
//   String min_price;
//   String max_price;
//   String min_sqrfeet;
//   String max_sqrfeet;
//
//   final String agentOrAgencyController;
//
//   final bool isLoading;
//   final bool isPropertyTypeLoading;
//   final bool isFilterListFilterModelLoading;
//   final bool hasMore;
//   final FilterModel? filterModel;
//   final int filterResultCount;
//   final String? nextPageUrl;
//
//   final List<Amenities> amenities;
//   final PropertyTypeModel? propertyTypeModel;
//
//   final int? selectedIndex;
//   final int? selectedtype;
//   final int? selectedproduct;
//
//   List<String> selectedBedrooms;
//   List<String> selectedBathrooms;
//
//   final int? selectedrent;
//
//   final String purpose;
//   final String? option;
//   final String ftype;
//   final String property_type;
//   final String rent;
//
//   List<int> selectedAmenitiesId;
//
//   final String handoverYear;
//   final String handoverQuarter;
//   final String completion_min;
//   final String completion_max;
//
//   final FilterSnapshot? initialSnapshot;
//   final int? initialHomeCategory;
//   final bool isResetLoading;
//
//   // Filter List Screen fields - ORIGINAL NAMES KEPT
//   final int? filterListSelectedProduct;
//   final int?
//       filterListSelectedPropertyCategoryType; // ← Kept exactly as your original code
//   final int? filterListSelectedPropType;
//   final int? filterListSelectedType;
//   final PropertyTypeModel? filterListPropertyTypeModel;
//   final bool isFilterListPropertyTypeLoading;
//
//   final SfRangeValues filterListValues;
//   final String filterList_Min_price;
//   final String filterList_Max_price;
//
//   List<String> selectedFilterListBedroomsList;
//   List<String> selectedFilterListBathroomsList;
//
//   SfRangeValues filterListValuesArea;
//   final String filterList_Min_sqr_feet;
//   final String filterList_Max_sqr_feet;
//
//   final int filterListSelectedCompletion;
//   final List<Datas>? chartData;
//   final List<Dataarea> chartDataarea;
//
//   FilterState({
//     required this.displayedFilterResultCount,
//     required this.selected,
//     required this.selectedAmenities,
//     required this.selectedHandover,
//     required this.selectedCompletion,
//     this.selectedPropType,
//     required this.selectedPercentCompletion,
//     required this.isFromFilterList,
//     required this.values,
//     required this.valuesArea,
//     required this.min_price,
//     required this.max_price,
//     required this.min_sqrfeet,
//     required this.max_sqrfeet,
//     required this.agentOrAgencyController,
//     required this.isLoading,
//     required this.isPropertyTypeLoading,
//     required this.isFilterListFilterModelLoading,
//     required this.hasMore,
//     this.filterModel,
//     required this.filterResultCount,
//     this.nextPageUrl,
//     required this.amenities,
//     this.propertyTypeModel,
//     this.selectedIndex,
//     this.selectedtype,
//     this.selectedproduct,
//     required this.selectedBedrooms,
//     required this.selectedBathrooms,
//     this.selectedrent,
//     required this.selectedAmenitiesId,
//     required this.purpose,
//     this.option,
//     required this.ftype,
//     required this.property_type,
//     required this.rent,
//     required this.handoverYear,
//     required this.handoverQuarter,
//     required this.completion_min,
//     required this.completion_max,
//     this.initialSnapshot,
//     this.initialHomeCategory,
//     required this.isResetLoading,
//     this.filterListSelectedProduct,
//     this.filterListSelectedPropertyCategoryType,
//     this.filterListSelectedPropType,
//     this.filterListSelectedType,
//     this.filterListPropertyTypeModel,
//     required this.isFilterListPropertyTypeLoading,
//     required this.filterListValues,
//     required this.filterList_Min_price,
//     required this.filterList_Max_price,
//     required this.selectedFilterListBedroomsList,
//     required this.selectedFilterListBathroomsList,
//     required this.filterListValuesArea,
//     required this.filterList_Min_sqr_feet,
//     required this.filterList_Max_sqr_feet,
//     required this.filterListSelectedCompletion,
//     this.chartData,
//     required this.chartDataarea,
//   });
//
//   factory FilterState.initial() {
//     return FilterState(
//       displayedFilterResultCount: 0,
//       selected: 0,
//       selectedAmenities: [],
//       selectedHandover: 0,
//       selectedCompletion: 0,
//       selectedPropType: null,
//       selectedPercentCompletion: 0,
//       isFromFilterList: false,
//       values: const SfRangeValues(500.0, 300000.0),
//       valuesArea: const SfRangeValues(0.0, 10000.0),
//       min_price: '',
//       max_price: '',
//       min_sqrfeet: '',
//       max_sqrfeet: '',
//       agentOrAgencyController: '',
//       isLoading: false,
//       isPropertyTypeLoading: false,
//       isFilterListFilterModelLoading: false,
//       hasMore: true,
//       filterModel: null,
//       filterResultCount: 0,
//       nextPageUrl: null,
//       amenities: [],
//       propertyTypeModel: null,
//       selectedIndex: null,
//       selectedtype: null,
//       selectedproduct: null,
//       selectedBedrooms: [],
//       selectedBathrooms: [],
//       selectedrent: null,
//       selectedAmenitiesId: [],
//       purpose: ' ',
//       option: null,
//       ftype: ' ',
//       property_type: ' ',
//       rent: ' ',
//       handoverYear: '',
//       handoverQuarter: '',
//       completion_min: '',
//       completion_max: '',
//       initialSnapshot: null,
//       initialHomeCategory: null,
//       isResetLoading: false,
//       filterListSelectedProduct: null,
//       filterListSelectedPropertyCategoryType: null,
//       filterListSelectedPropType: null,
//       filterListSelectedType: null,
//       filterListPropertyTypeModel: null,
//       isFilterListPropertyTypeLoading: false,
//       filterListValues: const SfRangeValues(500.0, 300000.0),
//       filterList_Min_price: '',
//       filterList_Max_price: '',
//       selectedFilterListBedroomsList: [],
//       selectedFilterListBathroomsList: [],
//       filterListValuesArea: const SfRangeValues(0.0, 10000.0),
//       filterList_Min_sqr_feet: '',
//       filterList_Max_sqr_feet: '',
//       filterListSelectedCompletion: 0,
//       chartDataarea: [],
//     );
//   }
//
//   FilterState copyWith({
//     int? displayedFilterResultCount,
//     int? selected,
//     List<Amenities>? selectedAmenities,
//     int? selectedHandover,
//     int? selectedCompletion,
//     int? selectedPropType,
//     int? selectedPercentCompletion,
//     bool? isFromFilterList,
//     SfRangeValues? values,
//     SfRangeValues? valuesArea,
//     String? min_price,
//     String? max_price,
//     String? min_sqrfeet,
//     String? max_sqrfeet,
//     String? agentOrAgencyController,
//     bool? isLoading,
//     bool? isPropertyTypeLoading,
//     bool? isFilterListFilterModelLoading,
//     bool? hasMore,
//     FilterModel? filterModel,
//     int? filterResultCount,
//     String? nextPageUrl,
//     List<Amenities>? amenities,
//     PropertyTypeModel? propertyTypeModel,
//     int? selectedIndex,
//     int? selectedtype,
//     int? selectedproduct,
//     List<String>? selectedBedrooms,
//     List<String>? selectedBathrooms,
//     int? selectedrent,
//     List<int>? selectedAmenitiesId,
//     String? purpose,
//     String? option,
//     String? ftype,
//     String? property_type,
//     String? rent,
//     String? handoverYear,
//     String? handoverQuarter,
//     String? completion_min,
//     String? completion_max,
//     FilterSnapshot? initialSnapshot,
//     int? initialHomeCategory,
//     bool? isResetLoading,
//     int? filterListSelectedProduct,
//     int? filterListSelectedPropertyCategoryType,
//     int? filterListSelectedPropType,
//     int? filterListSelectedType,
//     PropertyTypeModel? filterListPropertyTypeModel,
//     bool? isFilterListPropertyTypeLoading,
//     SfRangeValues? filterListValues,
//     String? filterList_Min_price,
//     String? filterList_Max_price,
//     List<String>? selectedFilterListBedroomsList,
//     List<String>? selectedFilterListBathroomsList,
//     SfRangeValues? filterListValuesArea,
//     String? filterList_Min_sqr_feet,
//     String? filterList_Max_sqr_feet,
//     int? filterListSelectedCompletion,
//   }) {
//     return FilterState(
//       chartDataarea: chartDataarea,
//       displayedFilterResultCount:
//           displayedFilterResultCount ?? this.displayedFilterResultCount,
//       selected: selected ?? this.selected,
//       selectedAmenities: selectedAmenities ?? this.selectedAmenities,
//       selectedHandover: selectedHandover ?? this.selectedHandover,
//       selectedCompletion: selectedCompletion ?? this.selectedCompletion,
//       selectedPropType: selectedPropType ?? this.selectedPropType,
//       selectedPercentCompletion:
//           selectedPercentCompletion ?? this.selectedPercentCompletion,
//       isFromFilterList: isFromFilterList ?? this.isFromFilterList,
//       values: values ?? this.values,
//       valuesArea: valuesArea ?? this.valuesArea,
//       min_price: min_price ?? this.min_price,
//       max_price: max_price ?? this.max_price,
//       min_sqrfeet: min_sqrfeet ?? this.min_sqrfeet,
//       max_sqrfeet: max_sqrfeet ?? this.max_sqrfeet,
//       agentOrAgencyController:
//           agentOrAgencyController ?? this.agentOrAgencyController,
//       isLoading: isLoading ?? this.isLoading,
//       isPropertyTypeLoading:
//           isPropertyTypeLoading ?? this.isPropertyTypeLoading,
//       isFilterListFilterModelLoading:
//           isFilterListFilterModelLoading ?? this.isFilterListFilterModelLoading,
//       hasMore: hasMore ?? this.hasMore,
//       filterModel: filterModel ?? this.filterModel,
//       filterResultCount: filterResultCount ?? this.filterResultCount,
//       nextPageUrl: nextPageUrl ?? this.nextPageUrl,
//       amenities: amenities ?? this.amenities,
//       propertyTypeModel: propertyTypeModel ?? this.propertyTypeModel,
//       selectedIndex: selectedIndex ?? this.selectedIndex,
//       selectedtype: selectedtype ?? this.selectedtype,
//       selectedproduct: selectedproduct ?? this.selectedproduct,
//       selectedBedrooms: selectedBedrooms ?? this.selectedBedrooms,
//       selectedBathrooms: selectedBathrooms ?? this.selectedBathrooms,
//       selectedrent: selectedrent ?? this.selectedrent,
//       selectedAmenitiesId: selectedAmenitiesId ?? this.selectedAmenitiesId,
//       purpose: purpose ?? this.purpose,
//       option: option ?? this.option,
//       ftype: ftype ?? this.ftype,
//       property_type: property_type ?? this.property_type,
//       rent: rent ?? this.rent,
//       handoverYear: handoverYear ?? this.handoverYear,
//       handoverQuarter: handoverQuarter ?? this.handoverQuarter,
//       completion_min: completion_min ?? this.completion_min,
//       completion_max: completion_max ?? this.completion_max,
//       initialSnapshot: initialSnapshot ?? this.initialSnapshot,
//       initialHomeCategory: initialHomeCategory ?? this.initialHomeCategory,
//       isResetLoading: isResetLoading ?? this.isResetLoading,
//       filterListSelectedProduct:
//           filterListSelectedProduct ?? this.filterListSelectedProduct,
//       filterListSelectedPropertyCategoryType:
//           filterListSelectedPropertyCategoryType ??
//               this.filterListSelectedPropertyCategoryType,
//       filterListSelectedPropType:
//           filterListSelectedPropType ?? this.filterListSelectedPropType,
//       filterListSelectedType:
//           filterListSelectedType ?? this.filterListSelectedType,
//       filterListPropertyTypeModel:
//           filterListPropertyTypeModel ?? this.filterListPropertyTypeModel,
//       isFilterListPropertyTypeLoading: isFilterListPropertyTypeLoading ??
//           this.isFilterListPropertyTypeLoading,
//       filterListValues: filterListValues ?? this.filterListValues,
//       filterList_Min_price: filterList_Min_price ?? this.filterList_Min_price,
//       filterList_Max_price: filterList_Max_price ?? this.filterList_Max_price,
//       selectedFilterListBedroomsList:
//           selectedFilterListBedroomsList ?? this.selectedFilterListBedroomsList,
//       selectedFilterListBathroomsList: selectedFilterListBathroomsList ??
//           this.selectedFilterListBathroomsList,
//       filterListValuesArea: filterListValuesArea ?? this.filterListValuesArea,
//       filterList_Min_sqr_feet:
//           filterList_Min_sqr_feet ?? this.filterList_Min_sqr_feet,
//       filterList_Max_sqr_feet:
//           filterList_Max_sqr_feet ?? this.filterList_Max_sqr_feet,
//       filterListSelectedCompletion:
//           filterListSelectedCompletion ?? this.filterListSelectedCompletion,
//     );
//   }
//
//   bool get isNewProjects => selected == 1;
//
//   String get currentUiPurpose => purpose.trim();
//
//   String get currentPropertyType {
//     if (property_type.trim().isNotEmpty) return property_type.trim();
//     return propertyTypeModel?.data?.firstOrNull?.name ?? '';
//   }
//
//   FilterSnapshot get currentSnapshot => FilterSnapshot(
//         agencyName: agentOrAgencyController.trim().toLowerCase(),
//         agentName: agentOrAgencyController.trim().toLowerCase(),
//         search: [],
//         propertyType: property_type.trim(),
//         furnishedStatus: ftype.trim(),
//         bedrooms: List.from(selectedBedrooms),
//         bathrooms: List.from(selectedBathrooms),
//         minPrice: min_price.trim(),
//         maxPrice: max_price.trim(),
//         paymentPeriod: rent.toLowerCase().trim(),
//         minSquareFeet: min_sqrfeet.trim(),
//         maxSquareFeet: max_sqrfeet.trim(),
//         option: option?.trim(),
//         purpose: purpose.trim(),
//         propertyCategory: selectedPropType,
//         amenities: List.from(selectedAmenitiesId),
//         handoverQuarter: handoverQuarter.trim(),
//         handoverYear: handoverYear.trim(),
//         completionsMax: completion_max,
//         completionsMin: completion_min,
//       );
//
//   bool get hasChanges {
//     if (initialSnapshot == null) return false;
//     return !initialSnapshot!.isEqual(currentSnapshot);
//   }
//
//   @override
//   List<Object?> get props => [
//         displayedFilterResultCount,
//         selected,
//         selectedAmenities,
//         selectedHandover,
//         selectedCompletion,
//         selectedPropType,
//         selectedPercentCompletion,
//         isFromFilterList,
//         values,
//         valuesArea,
//         min_price,
//         max_price,
//         min_sqrfeet,
//         max_sqrfeet,
//         agentOrAgencyController,
//         isLoading,
//         isPropertyTypeLoading,
//         isFilterListFilterModelLoading,
//         hasMore,
//         filterModel,
//         filterResultCount,
//         nextPageUrl,
//         amenities,
//         propertyTypeModel,
//         selectedIndex,
//         selectedtype,
//         selectedproduct,
//         selectedBedrooms,
//         selectedBathrooms,
//         selectedrent,
//         selectedAmenitiesId,
//         purpose,
//         option,
//         ftype,
//         property_type,
//         rent,
//         handoverYear,
//         handoverQuarter,
//         completion_min,
//         completion_max,
//         initialSnapshot,
//         initialHomeCategory,
//         isResetLoading,
//         filterListSelectedProduct,
//         filterListSelectedPropertyCategoryType,
//         filterListSelectedPropType,
//         filterListSelectedType,
//         filterListPropertyTypeModel,
//         isFilterListPropertyTypeLoading,
//         filterListValues,
//         filterList_Min_price,
//         filterList_Max_price,
//         selectedFilterListBedroomsList,
//         selectedFilterListBathroomsList,
//         filterListValuesArea,
//         filterList_Min_sqr_feet,
//         filterList_Max_sqr_feet,
//         filterListSelectedCompletion,
//       ];
// }
