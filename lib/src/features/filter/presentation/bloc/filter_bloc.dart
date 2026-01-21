//Bloc fILE

// filter_bloc.dart
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../../../../providers/location_picker_provider.dart';
import '../../../property/data/models/amenities_model.dart';
import '../../../property/data/models/property_type_model.dart' hide Data;
import '../../data/model/filtermodel.dart';
import '../../repo/filter_repo.dart';

part 'filter_event.dart';
part 'filter_state.dart';

class FilterBloc extends Bloc<FilterEvent, FilterState> {
  final FilterRepository _repository;
  FilterBloc(this._repository) : super(FilterState.initial()) {
    on<FilterInitFilterFields>(_onInitFilterFields);
    on<FilterSetSelectedProductType>(_onSetSelectedProductType);
    on<FilterSetSelectedPropertyCategoryType>(
        _onSetSelectedPropertyCategoryType);
    on<FilterSetSelectedPropertyType>(_onSetSelectedPropertyType);
    on<FilterSetSelectedBedrooms>(_onSetSelectedBedrooms);
    on<FilterSetSelectedBathrooms>(_onSetSelectedBathrooms);
    on<FilterSetSelectedFurnishedType>(_onSetSelectedFurnishedType);
    on<FilterSetSelectedPriceRange>(_onSetSelectedPriceRange);
    on<FilterSetSelectedAreaRange>(_onSetSelectedAreaRange);
    on<FilterSetSelectedAmenities>(_onSetSelectedAmenities);
    on<FilterSetSelectedRentType>(_onSetSelectedRentType);
    on<FilterSetSelectedCompletionStatus>(_onSetSelectedCompletionStatus);
    on<FilterSetSelectedHandOverBy>(_onSetSelectedHandOverBy);
    on<FilterSetSelectedCompletionPercentage>(
        _onSetSelectedCompletionPercentage);
    on<FilterUpdateFilterCount>(_onUpdateFilterCount);
    on<FilterResetAll>(_onResetAll);
    on<FilterCaptureInitialSnapshot>(_onCaptureInitialSnapshot);
    on<FilterSetInitialHomeCategory>(_onSetInitialHomeCategory);
    on<FilterSetNewProjects>(_onSetNewProjects);
    on<FilterSetProperties>(_onSetProperties);
    on<FilterShowResult>(_onShowResult);
    on<FilterSetFilterNavigation>(_onSetFilterNavigation);
    on<FilterLoadInitialData>(_onLoadInitialData);
    on<FilterPropertyApi>(_onPropertyApi);
    on<FilterFetchAmenities>(_onFetchAmenities);
    on<FilterSetSelectedFilterListProductLocally>(
        _onSetSelectedFilterListProductLocally);
    on<FilterSetSelectedFilterListPropertyCategoryType>(
        _onSetSelectedFilterListPropertyCategoryType);
    on<FilterSetSelectedFilterListPropertyType>(
        _onSetSelectedFilterListPropertyType);
    on<FilterSetSelectedFilterListPropertyCategory>(
        _onSetSelectedFilterListPropertyCategory);
    on<FilterSetSelectedFilterRangePriceRange>(
        _onSetSelectedFilterRangePriceRange);
    on<FilterSetSelectedFilterListBedrooms>(_onSetSelectedFilterListBedrooms);
    on<FilterSetSelectedFilterListBathrooms>(_onSetSelectedFilterListBathrooms);
    on<FilterSetSelectedFilterListAreaSize>(_onSetSelectedFilterListAreaSize);
    on<FilterSetSelectedFilterListCompletionStatus>(
        _onSetSelectedFilterListCompletionStatus);
  }

  static const List<String> product = ['Buy', 'Rent'];
  static const List<String> completion = ['All', 'Ready', 'Off-Plan'];
  static const List<String> handoverOptions = [
    'Any',
    'Q3 2025',
    'Q4 2025',
    'Q5 2025',
    'Q1 2026',
    'Q2 2026',
    'Q3 2026',
    'Q4 2026',
    '2027',
    '2028',
    '2029',
    '2030',
    '2031',
  ];
  static const List<String> percentCompletionOptions = [
    'Any',
    '0-25%',
    '25-50%',
    '50-75%',
    '75-100%',
  ];
  static const List<String> bedroomList = [
    'Studio',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7+',
  ];
  static const List<String> bathroomList = ['1', '2', '3', '4', '5', '6', '7+'];
  static const List<String> ftypeList = [
    'All',
    'Furnished',
    'Semifurnished',
    'Unfurnished',
  ];
  static const List<String> rentList = ['Yearly', 'Monthly', 'Daily'];

  Future<void> _onInitFilterFields(
      FilterInitFilterFields event, Emitter<FilterState> emit) async {
    emit(state.copyWith(
      selected: 0,
      selectedproduct: product.indexOf(event.data),
      selectedtype: null,
      selectedPropType: event.propertyType,
      purpose: event.data,
      selectedCompletion:
          event.optionType != null && event.optionType!.isNotEmpty ? 2 : 0,
      option: event.optionType,
      property_type: null,
      handoverQuarter: null,
      handoverYear: null,
    ));
    // add(const FilterLoadInitialData());

    final fetchedAmenities = await _repository.fetchAmenities();

    PropertyTypeModel? fetchedPropertyType;
    if (state.selectedPropType != null) {
      final type = state.selectedPropType == 0 ? 'Residential' : 'Commercial';
      // final propertyUri = ApiService.buildUri('property-types/$type');
      // final propertyResponse =
      //     await http.get(propertyUri).timeout(const Duration(seconds: 8));
      // if (propertyResponse.statusCode == 200) {
      //   fetchedPropertyType =
      //       PropertyTypeModel.fromJson(json.decode(propertyResponse.body));
      fetchedPropertyType = await _repository.fetchPropertyTypes(type);

      // }
    }

    emit(state.copyWith(
      isLoading: false,
      amenities: fetchedAmenities,
      propertyTypeModel: fetchedPropertyType,
    ));
  }

  void _onSetSelectedProductType(
      FilterSetSelectedProductType event, Emitter<FilterState> emit) {
    emit(state.copyWith(
      selectedproduct: event.index,
      purpose: product[event.index],
      selectedCompletion: 0,
      option: event.index == 0 ? 'All' : null,
    ));
  }

  void _onSetSelectedPropertyCategoryType(
      FilterSetSelectedPropertyCategoryType event, Emitter<FilterState> emit) {
    if (state.selectedtype == event.index) {
      emit(state.copyWith(selectedtype: null, property_type: null));
    } else {
      emit(state.copyWith(
        selectedtype: event.index,
        property_type: state.propertyTypeModel?.data?[event.index].name ?? '',
      ));
    }
  }

  void _onSetSelectedPropertyType(
      FilterSetSelectedPropertyType event, Emitter<FilterState> emit) {
    if (event.index == null) return;

    emit(state.copyWith(
      selectedtype: null,
      property_type: "",
      selectedPropType: event.index,
    ));

    final purposeType = event.index == 0 ? 'Residential' : 'Commercial';
    add(FilterPropertyApi(purposeType));
  }

  void _onSetSelectedBedrooms(
      FilterSetSelectedBedrooms event, Emitter<FilterState> emit) {
    final item = bedroomList[event.index];
    final newList = List<String>.from(state.selectedBedrooms);
    if (newList.contains(item)) {
      newList.remove(item);
    } else {
      newList.add(item);
    }
    emit(state.copyWith(selectedBedrooms: newList));
  }

  void _onSetSelectedBathrooms(
      FilterSetSelectedBathrooms event, Emitter<FilterState> emit) {
    final item = bathroomList[event.index];
    final newList = List<String>.from(state.selectedBathrooms);
    if (newList.contains(item)) {
      newList.remove(item);
    } else {
      newList.add(item);
    }
    emit(state.copyWith(selectedBathrooms: newList));
  }

  void _onSetSelectedFurnishedType(
      FilterSetSelectedFurnishedType event, Emitter<FilterState> emit) {
    final formatted = switch (ftypeList[event.index]) {
      'All' => 'all',
      'Furnished' => 'furnished',
      'Semifurnished' => 'semiFurnished',
      'Unfurnished' => 'unfurnished',
      _ => '',
    };
    emit(state.copyWith(selectedIndex: event.index, ftype: formatted));
  }

  void _onSetSelectedPriceRange(
      FilterSetSelectedPriceRange event, Emitter<FilterState> emit) {
    emit(state.copyWith(
      values: SfRangeValues(event.value.start, event.value.end),
      min_price: event.value.start.toStringAsFixed(0),
      max_price: event.value.end.toStringAsFixed(0),
    ));
  }

  void _onSetSelectedAreaRange(
      FilterSetSelectedAreaRange event, Emitter<FilterState> emit) {
    emit(state.copyWith(
      valuesArea: SfRangeValues(event.value.start, event.value.end),
      min_sqrfeet: event.value.start.toStringAsFixed(0),
      max_sqrfeet: event.value.end.toStringAsFixed(0),
    ));
  }

  void _onSetSelectedAmenities(
      FilterSetSelectedAmenities event, Emitter<FilterState> emit) {
    final id = state.amenities[event.index].id!;
    final newList = List<int>.from(state.selectedAmenitiesId);
    if (newList.contains(id)) {
      newList.remove(id);
    } else {
      newList.add(id);
    }
    emit(state.copyWith(selectedAmenitiesId: newList));
  }

  void _onSetSelectedRentType(
      FilterSetSelectedRentType event, Emitter<FilterState> emit) {
    emit(
        state.copyWith(selectedrent: event.index, rent: rentList[event.index]));
  }

  void _onSetSelectedCompletionStatus(
      FilterSetSelectedCompletionStatus event, Emitter<FilterState> emit) {
    final name = completion[event.index];
    final formatted = switch (name) {
      'All' => 'all',
      'Ready' => 'ready',
      'Off-Plan' => 'offplan',
      _ => '',
    };
    emit(state.copyWith(selectedCompletion: event.index, option: formatted));
  }

  void _onSetSelectedHandOverBy(
      FilterSetSelectedHandOverBy event, Emitter<FilterState> emit) {
    final handoverBy = handoverOptions[event.index] == 'Any'
        ? ''
        : handoverOptions[event.index];
    final reg = RegExp(r'^(Q\d)\s+(\d{4})$');
    final match = reg.firstMatch(handoverBy);

    String year = '';
    String quarter = '';
    if (match != null) {
      quarter = match.group(1)!;
      year = match.group(2)!;
    } else {
      year = handoverBy;
    }

    emit(state.copyWith(
      selectedHandover: event.index,
      handoverQuarter: quarter,
      handoverYear: year,
    ));
  }

  void _onSetSelectedCompletionPercentage(
      FilterSetSelectedCompletionPercentage event, Emitter<FilterState> emit) {
    final selected = percentCompletionOptions[event.index];
    String min = '';
    String max = '';
    if (selected != 'Any') {
      final range = selected.replaceAll('%', '').split('-');
      min = range[0].trim();
      max = range[1].trim();
    }
    emit(state.copyWith(
      selectedPercentCompletion: event.index,
      completion_min: min,
      completion_max: max,
    ));
  }

  Future<void> _onUpdateFilterCount(
      FilterUpdateFilterCount event, Emitter<FilterState> emit) async {
    if (state.isFilterListFilterModelLoading) return;

    emit(state.copyWith(isFilterListFilterModelLoading: true));

    try {
      final locList =
          event.context.read<LocationPickerProvider>().selectedLocationList;
      final locationNames = locList
          .map((e) => (e.location ?? e.country)?.toLowerCase())
          .whereType<String>()
          .toList();

      final uri = _buildFilterUri(
        page: event.loadMore
            ? "${(state.filterModel?.meta?.currentPage ?? 0) + 1}"
            : "1",
        search: locationNames,
        propertyType: state.property_type.trim(),
        furnishedStatus: state.ftype.trim(),
        bedrooms: state.selectedBedrooms,
        bathrooms: state.selectedBathrooms,
        minPrice: state.min_price.trim(),
        maxPrice: state.max_price.trim(),
        paymentPeriod: state.rent.toLowerCase().trim(),
        minSquareFeet: state.min_sqrfeet.trim(),
        maxSquareFeet: state.max_sqrfeet.trim(),
        purpose: state.purpose.trim(),
        option: state.option?.trim(),
        propertyCategory: state.selectedPropType,
        amenities: state.selectedAmenitiesId,
        handoverQuarter: state.handoverQuarter.trim(),
        handoverYear: state.handoverYear.trim(),
        completions_min: state.completion_min,
        completions_max: state.completion_max,
        agencyName: state.agentOrAgencyController.trim().toLowerCase(),
        agentName: state.agentOrAgencyController.trim().toLowerCase(),
      );

      debugPrint('Filter API URL: $uri');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final feature = FilterResponseModel.fromJson(json);

        final incoming = feature.data?.data ?? <Data>[];
        final currentList =
            event.loadMore ? (state.filterModel?.data ?? <Data>[]) : <Data>[];
        final merged = _mergeDedupData(currentList, incoming);

        final meta = feature.data?.meta;

        emit(state.copyWith(
          filterModel:
              FilterModel(data: merged, links: feature.data?.links, meta: meta),
          filterResultCount: meta?.total ?? 0,
          displayedFilterResultCount: meta?.total ?? 0,
          nextPageUrl: (meta?.currentPage ?? 1) < (meta?.lastPage ?? 1)
              ? uri.replace(queryParameters: {
                  'page': '${(meta?.currentPage ?? 1) + 1}'
                }).toString()
              : null,
        ));
      }
    } catch (e) {
      debugPrint('UpdateFilterCount error: $e');
    }

    emit(state.copyWith(isFilterListFilterModelLoading: false));
  }

  Uri _buildFilterUri({
    String? page,
    List<String>? search,
    String? propertyType,
    String? furnishedStatus,
    List<String>? bedrooms,
    List<String>? bathrooms,
    String? minPrice,
    String? maxPrice,
    String? paymentPeriod,
    String? minSquareFeet,
    String? maxSquareFeet,
    String? purpose,
    String? option,
    int? propertyCategory,
    List<int>? amenities,
    String? handoverQuarter,
    String? handoverYear,
    String? completions_min,
    String? completions_max,
    String? agencyName,
    String? agentName,
  }) {
    final queryParams = <String, dynamic>{};

    if (page != null && page.isNotEmpty) queryParams['page'] = page;
    if (completions_min?.isNotEmpty == true)
      queryParams['completion_min'] = completions_min;
    if (completions_max?.isNotEmpty == true)
      queryParams['completion_max'] = completions_max;
    if (handoverYear?.isNotEmpty == true)
      queryParams['handover_year'] = handoverYear;
    if (handoverQuarter?.isNotEmpty == true)
      queryParams['handover_quarter'] = handoverQuarter;
    if (propertyCategory != null) {
      queryParams['property_category'] =
          propertyCategory == 0 ? 'Residential' : 'Commercial';
    }
    if (option?.isNotEmpty == true) queryParams['option'] = option;
    if (agentName?.isNotEmpty == true) queryParams['agent'] = agentName;
    if (agencyName?.isNotEmpty == true) queryParams['agency'] = agencyName;
    if (search != null && search.isNotEmpty)
      queryParams['search'] = search.join(',');
    if (propertyType?.isNotEmpty == true)
      queryParams['property_type'] = propertyType;
    if (furnishedStatus?.isNotEmpty == true)
      queryParams['furnished_status'] = furnishedStatus;
    final is7PlusBed = bedrooms?.contains('7+') ?? false;
    final is7PlusBath = bathrooms?.contains('7+') ?? false;
    if (bedrooms != null && bedrooms.isNotEmpty && !is7PlusBed)
      queryParams['bedrooms'] = bedrooms.join(',');
    if (bathrooms != null && bathrooms.isNotEmpty && !is7PlusBath)
      queryParams['bathrooms'] = bathrooms.join(',');
    if (minPrice?.isNotEmpty == true) queryParams['min_price'] = minPrice;
    if (maxPrice?.isNotEmpty == true) queryParams['max_price'] = maxPrice;
    if (paymentPeriod?.isNotEmpty == true)
      queryParams['payment_period'] = paymentPeriod;
    if (minSquareFeet?.isNotEmpty == true)
      queryParams['min_square_feet'] = minSquareFeet;
    if (maxSquareFeet?.isNotEmpty == true)
      queryParams['max_square_feet'] = maxSquareFeet;
    if (purpose?.isNotEmpty == true) queryParams['purpose'] = purpose;
    if (amenities != null && amenities.isNotEmpty)
      queryParams['amenities'] = amenities.join(',');

    return Uri.https('akarat.com', '/api/filters', queryParams);
  }

  List<Data> _mergeDedupData(List<Data> a, List<Data> b) {
    final map = <int, Data>{};
    for (var item in [...a, ...b]) {
      final id = item.id ?? -1;
      if (id != -1) map[id] = item;
    }
    return map.values.toList();
  }

  Future<void> _onResetAll(
      FilterResetAll event, Emitter<FilterState> emit) async {
    emit(state.copyWith(isResetLoading: true));

    final cat = state.initialHomeCategory;

    int? prodIndex;
    String? newPurpose;
    int? propType;
    String newOption = '';
    int completionIndex = 0;
    int? selectedtype;
    String? property_type;

    //////// FOR RENT ////////

    // Match original Provider resetAll() logic exactly
    if (cat == 0) {
      // Rent (general)
      prodIndex = 1;
      newPurpose = product[prodIndex];
      propType = null;
      completionIndex = 0;
      newOption = '';
    } else if (cat == 1) {
      // Buy (general)
      prodIndex = 0;
      newPurpose = product[prodIndex];
      propType = null;
      completionIndex = 0;
      newOption = '';
    } else if (cat == 2) {
      // Off-Plan
      prodIndex = 0;
      newPurpose = product[prodIndex];
      propType = null;
      newOption = 'offplan';
      completionIndex = 2;
    } else if (cat == 3) {
      // Commercial
      prodIndex = 1; // Rent
      newPurpose = product[prodIndex];
      propType = 1; // Commercial
      add(FilterPropertyApi('Commercial'));

      final propertYTypeModel =
          await _repository.fetchPropertyTypes("Commercial");

      completionIndex = 0;
      newOption = '';
    } else if (cat == 4) {
      // Villas (Rent + Residential)
      prodIndex = 1;
      newPurpose = product[prodIndex];
      propType = 0;
      add(FilterPropertyApi('Residential'));

      String propertyCategoryType = "Villa";
      final index = state.propertyTypeModel!.data!.indexWhere(
        (item) =>
            item.name?.trim().toLowerCase() ==
            propertyCategoryType.trim().toLowerCase(),
      );
      selectedtype = index;
      property_type = state.propertyTypeModel!.data![index].name.toString();

      completionIndex = 0;
      newOption = '';
    } else if (cat == 5) {
      // Apartments (Rent + Residential)
      prodIndex = 1;
      newPurpose = product[prodIndex];
      propType = 0;
      add(FilterPropertyApi('Residential'));
      String propertyCategoryType = "Apartment";
      final index = state.propertyTypeModel!.data!.indexWhere(
        (item) =>
            item.name?.trim().toLowerCase() ==
            propertyCategoryType.trim().toLowerCase(),
      );
      selectedtype = index;
      property_type = state.propertyTypeModel!.data![index].name.toString();

      completionIndex = 0;
      newOption = '';
    }

    // Reset all UI fields
    emit(state.copyWith(
      selectedtype: selectedtype,
      property_type: property_type,
      values: const SfRangeValues(500.0, 300000.0),
      valuesArea: const SfRangeValues(0.0, 10000.0),
      min_price: '',
      max_price: '',
      min_sqrfeet: '',
      max_sqrfeet: '',
      selected: 0,
      completion_min: "",
      completion_max: "",
      handoverQuarter: "",
      handoverYear: "",
      ftype: '',
      rent: '',
      agentOrAgencyController: '',
      selectedIndex: null,
      selectedBedrooms: [],
      selectedBathrooms: [],
      selectedrent: null,
      selectedAmenitiesId: [],
      selectedHandover: 0,
      selectedPercentCompletion: 0,
      selectedproduct: prodIndex,
      purpose: newPurpose,
      option: newOption.isEmpty ? null : newOption,
      selectedCompletion: completionIndex,
      selectedPropType: propType,
      isResetLoading: false,
    ));

    // Clear locations
    event.context.read<LocationPickerProvider>().selectedLocationList.clear();

    // Trigger update only if requested
    if (event.isUpdate) {
      add(FilterUpdateFilterCount(context: event.context));
    }
  }

  void _onCaptureInitialSnapshot(
      FilterCaptureInitialSnapshot event, Emitter<FilterState> emit) {
    emit(state.copyWith(initialSnapshot: state.currentSnapshot));
  }

  void _onSetInitialHomeCategory(
      FilterSetInitialHomeCategory event, Emitter<FilterState> emit) {
    emit(state.copyWith(initialHomeCategory: event.index));
  }

  void _onSetNewProjects(
      FilterSetNewProjects event, Emitter<FilterState> emit) {
    emit(state.copyWith(
      selected: 1,
      selectedCompletion: 0,
      selectedproduct: null,
      purpose: 'Buy',
      option: 'offplan',
      selectedrent: null,
      rent: '',
      selectedtype: null,
      property_type: '',
    ));
  }

  void _onSetProperties(FilterSetProperties event, Emitter<FilterState> emit) {
    emit(state.copyWith(
      selected: 0,
      option: null,
      selectedCompletion: 0,
      purpose: product[state.selectedproduct ?? 0],
    ));
  }

  void _onShowResult(FilterShowResult event, Emitter<FilterState> emit) {
    emit(state.copyWith(isLoading: true));
    add(FilterUpdateFilterCount(context: event.context));
    emit(state.copyWith(isLoading: false));

    if (!event.autoUpdate) {
      if (state.filterModel?.data?.isEmpty ?? true) {
        event.onFilterResultZero();
      } else {
        event.onFilterResultNotZero();
      }
    }
  }

  void _onSetFilterNavigation(
      FilterSetFilterNavigation event, Emitter<FilterState> emit) {
    emit(state.copyWith(isFromFilterList: event.value));
  }

  Future<void> _onLoadInitialData(
      FilterLoadInitialData event, Emitter<FilterState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      // final amenitiesUri = ApiService.buildUri('amenities');
      // final amenitiesResponse =
      //     await http.get(amenitiesUri).timeout(const Duration(seconds: 8));
      // List<Amenities> fetchedAmenities = [];
      // if (amenitiesResponse.statusCode == 200) {
      //   final jsonData = json.decode(amenitiesResponse.body) as List;
      //   fetchedAmenities = jsonData.map((e) => Amenities.fromJson(e)).toList();
      // }

      final fetchedAmenities = await _repository.fetchAmenities();

      PropertyTypeModel? fetchedPropertyType;
      if (state.selectedPropType != null) {
        final type = state.selectedPropType == 0 ? 'Residential' : 'Commercial';
        // final propertyUri = ApiService.buildUri('property-types/$type');
        // final propertyResponse =
        //     await http.get(propertyUri).timeout(const Duration(seconds: 8));
        // if (propertyResponse.statusCode == 200) {
        //   fetchedPropertyType =
        //       PropertyTypeModel.fromJson(json.decode(propertyResponse.body));
        fetchedPropertyType = await _repository.fetchPropertyTypes(type);

        // }
      }

      emit(state.copyWith(
        isLoading: false,
        amenities: fetchedAmenities,
        propertyTypeModel: fetchedPropertyType,
      ));
    } catch (e) {
      debugPrint('LoadInitialData error: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onPropertyApi(
      FilterPropertyApi event, Emitter<FilterState> emit) async {
    emit(state.copyWith(isPropertyTypeLoading: true));
    try {
      // final uri = ApiService.buildUri('property-types/${event.purpose}');
      // final response = await http.get(uri);
      // if (response.statusCode == 200) {
      //   final model = PropertyTypeModel.fromJson(jsonDecode(response.body));
      final model = await _repository.fetchPropertyTypes(event.purpose);
      emit(state.copyWith(propertyTypeModel: model));
      // }
    } catch (e) {
      debugPrint('PropertyApi error: $e');
    }
    emit(state.copyWith(isPropertyTypeLoading: false));
  }

  Future<void> _onFetchAmenities(
      FilterFetchAmenities event, Emitter<FilterState> emit) async {
    try {
      // final uri = ApiService.buildUri('amenities');
      // final response = await http.get(uri).timeout(const Duration(seconds: 8));
      // if (response.statusCode == 200) {
      //   final list = (json.decode(response.body) as List)
      //       .map((e) => Amenities.fromJson(e))
      //       .toList();
      final list = await _repository.fetchAmenities();
      emit(state.copyWith(amenities: list));
      // }
    } catch (e) {
      debugPrint('FetchAmenities error: $e');
    }
  }

  void _onSetSelectedFilterListProductLocally(
      FilterSetSelectedFilterListProductLocally event,
      Emitter<FilterState> emit) {
    emit(state.copyWith(
      filterListSelectedCompletion: 0,
      filterListSelectedProduct: event.index,
    ));
  }

  void _onSetSelectedFilterListPropertyCategoryType(
      FilterSetSelectedFilterListPropertyCategoryType event,
      Emitter<FilterState> emit) {
    emit(state.copyWith(filterListSelectedPropertyCategoryType: event.index));
  }

  void _onSetSelectedFilterListPropertyType(
      FilterSetSelectedFilterListPropertyType event,
      Emitter<FilterState> emit) {
    emit(state.copyWith(
      filterListSelectedType: null,
      filterListSelectedPropType: event.index,
    ));
  }

  void _onSetSelectedFilterListPropertyCategory(
      FilterSetSelectedFilterListPropertyCategory event,
      Emitter<FilterState> emit) {
    if (state.filterListSelectedType == event.index) {
      emit(state.copyWith(filterListSelectedType: null));
    } else {
      emit(state.copyWith(filterListSelectedType: event.index));
    }
  }

  void _onSetSelectedFilterRangePriceRange(
      FilterSetSelectedFilterRangePriceRange event, Emitter<FilterState> emit) {
    emit(state.copyWith(
      filterListValues: SfRangeValues(event.minPrice, event.maxPrice),
      filterList_Min_price: event.minPrice.toStringAsFixed(0),
      filterList_Max_price: event.maxPrice.toStringAsFixed(0),
    ));
  }

  void _onSetSelectedFilterListBedrooms(
      FilterSetSelectedFilterListBedrooms event, Emitter<FilterState> emit) {
    final item = bedroomList[event.index];
    final newList = List<String>.from(state.selectedFilterListBedroomsList);
    if (newList.contains(item)) {
      newList.remove(item);
    } else {
      newList.add(item);
    }
    emit(state.copyWith(selectedFilterListBedroomsList: newList));
  }

  void _onSetSelectedFilterListBathrooms(
      FilterSetSelectedFilterListBathrooms event, Emitter<FilterState> emit) {
    final item = bathroomList[event.index];
    final newList = List<String>.from(state.selectedFilterListBathroomsList);
    if (newList.contains(item)) {
      newList.remove(item);
    } else {
      newList.add(item);
    }
    emit(state.copyWith(selectedFilterListBathroomsList: newList));
  }

  void _onSetSelectedFilterListAreaSize(
      FilterSetSelectedFilterListAreaSize event, Emitter<FilterState> emit) {
    emit(state.copyWith(
      filterListValuesArea: SfRangeValues(event.minSqrFeet, event.maxSqrFeet),
      filterList_Min_sqr_feet: event.minSqrFeet.toStringAsFixed(0),
      filterList_Max_sqr_feet: event.maxSqrFeet.toStringAsFixed(0),
    ));
  }

  void _onSetSelectedFilterListCompletionStatus(
      FilterSetSelectedFilterListCompletionStatus event,
      Emitter<FilterState> emit) {
    emit(state.copyWith(filterListSelectedCompletion: event.index));
  }
}
