import 'dart:convert';

import 'package:Akarat/main.dart';
import 'package:Akarat/src/features/property/data/models/property_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../core/services/api_service.dart';
import '../features/filter/data/model/filtermodel.dart';
import '../features/property/data/models/amenities_model.dart';
// import '../features/property/data/models/property_type_model.dart' hide Data;
import '../features/property/data/models/property_type_model.dart';
import '../utils/shared_preference_manager.dart';
import 'location_picker_provider.dart';

class FilterProvider extends ChangeNotifier {
  int displayedFilterResultCount = 0;
  // late bool isSelected = true;

  int selected = 0;
  bool get isNewProjects => selected == 1;
  List<Amenities> selectedAmenities = [];

  final List<String> completion = const ['All', 'Ready', 'Off-Plan'];

  final List<String> handoverOptions = const [
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

  int selectedHandover = 0; // index within _handoverOptions
  int selectedCompletion = 0;
  final List<String> propTypes = const ['Residential', 'Commercial'];
  int? selectedPropType; // 0 = Residential, 1 = Commercial

// %Completion options
  final List<String> percentCompletionOptions = const [
    'Any',
    '0-25%',
    '25-50%',
    '50-75%',
    '75-100%',
  ];
  int selectedPercentCompletion = 0; // index

  bool isFromFilterList = false;

  void setFilterNavigation(bool value) {
    isFromFilterList = value;
    notifyListeners();
  }

  SfRangeValues values =
      SfRangeValues(500.0, 300000.0); // full range internally

  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();

  bool isMinTyping = false;
  bool isMaxTyping = false;

  RangeController priceRangeController = RangeController(
    start: 500.0,
    end: 300000.0,
  );
  RangeController areaRangeController = RangeController(
    start: 0.0,
    end: 10000,
  );
  RangeController priceRangeSelectionController = RangeController(
    start: 500.0,
    end: 300000.0,
  );
  RangeController areaRangeSelectionController = RangeController(
    start: 0.0,
    end: 10000,
  );

  SfRangeValues valuesArea = SfRangeValues(0.0, 10000);
  TextEditingController minAreaController = TextEditingController();
  TextEditingController maxAreaController = TextEditingController();
  bool isMinAreaTyping = false;
  bool isMaxAreaTyping = false;
  String min_sqrfeet = '';
  String max_sqrfeet = '';
  // late RangeController rangeController;
  // late RangeController rangeControllerarea;
  final agenciesController = TextEditingController();

  final ScrollController scrollController = ScrollController();
  int currentPage = 1;
  bool isLoading = false;
  bool isPropertyTypeLoading = false;
  bool isFilterListFilterModelLoading = false;
  bool hasMore = true;
  FilterModel? filterModel;

  int filterResultCount = 0;

  String token = '';
  String email = '';
  String result = '';
  bool isDataRead = false;
  // Create an object of SharedPreferencesManager class
  SharedPreferencesManager prefManager = SharedPreferencesManager();

  final TextEditingController searchController = TextEditingController();

  List<Amenities> amenities = [];

// Product list (UI display)
  final List<String> product = [
    'Buy',
    'Rent',
  ];

// Bedroom options
  final List<String> bedroomList = [
    'Studio',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7+',
  ];

// Bathroom options
  final List<String> bathroomList = ['1', '2', '3', '4', '5', '6', '7+'];

// Furnished type
  final List<String> ftypeList = [
    'All',
    'Furnished',
    'Semifurnished',
    'Unfurnished',
  ];

// Rent payment period
  final List<String> rentList = ['Yearly', 'Monthly', 'Daily'];

// Chart Y values
  final List<int> yValues = [5000, 3000, 9000, 7000, 10000, 1500, 4000];

// Chart data
  late List<Datas>? chartData;

  final List<Dataarea> chartDataarea = <Dataarea>[
    Dataarea(x: 500, y: 5000),
    Dataarea(x: 600, y: 3000),
    Dataarea(x: 700, y: 6000),
    Dataarea(x: 800, y: 2000),
    Dataarea(x: 900, y: 8000),
    Dataarea(x: 1000, y: 1000),
    Dataarea(x: 1100, y: 3000),
    Dataarea(x: 1200, y: 5000),
    Dataarea(x: 1300, y: 9000),
    Dataarea(x: 1400, y: 4000),
    Dataarea(x: 1500, y: 1500),
    Dataarea(x: 1600, y: 6000),
    Dataarea(x: 1700, y: 9000),
    Dataarea(x: 1800, y: 2000),
    Dataarea(x: 1900, y: 8000),
    Dataarea(x: 2000, y: 1000),
    Dataarea(x: 2100, y: 6000),
    Dataarea(x: 2200, y: 3000),
    Dataarea(x: 2300, y: 5000),
    Dataarea(x: 2400, y: 1000),
    Dataarea(x: 2500, y: 2500),
    Dataarea(x: 2600, y: 5500),
    Dataarea(x: 2700, y: 8000),
    Dataarea(x: 2800, y: 2500),
    Dataarea(x: 2900, y: 6000),
    Dataarea(x: 3000, y: 1000),
    Dataarea(x: 3100, y: 3000),
    Dataarea(x: 3200, y: 5000),
    Dataarea(x: 3300, y: 7000),
    Dataarea(x: 3400, y: 6000),
    Dataarea(x: 3500, y: 4000),
    Dataarea(x: 3600, y: 2000),
    Dataarea(x: 3700, y: 5000),
    Dataarea(x: 3800, y: 7000),
    Dataarea(x: 3900, y: 9000),
    Dataarea(x: 4000, y: 1000),
    Dataarea(x: 4100, y: 3000),
    Dataarea(x: 4200, y: 5000),
    Dataarea(x: 4300, y: 7000),
    Dataarea(x: 4400, y: 4000),
    Dataarea(x: 4500, y: 10000),
    Dataarea(x: 4600, y: 8000),
    Dataarea(x: 4700, y: 6000),
    Dataarea(x: 4800, y: 4000),
    Dataarea(x: 4900, y: 2000),
    Dataarea(x: 5000, y: 5500),
    Dataarea(x: 5100, y: 1000),
    Dataarea(x: 5200, y: 3000),
    Dataarea(x: 5300, y: 5000),
    Dataarea(x: 5400, y: 7000),
    Dataarea(x: 5500, y: 9000),
    Dataarea(x: 5600, y: 3000),
    Dataarea(x: 5700, y: 7500),
    Dataarea(x: 5800, y: 3500),
    Dataarea(x: 5900, y: 4560),
    Dataarea(x: 6000, y: 7500),
    Dataarea(x: 6100, y: 10000),
    Dataarea(x: 6200, y: 6000),
    Dataarea(x: 6300, y: 4000),
    Dataarea(x: 6400, y: 2000),
    Dataarea(x: 6500, y: 6000),
    Dataarea(x: 6600, y: 3000),
    Dataarea(x: 6700, y: 5000),
    Dataarea(x: 6800, y: 7000),
    Dataarea(x: 6900, y: 9000),
    Dataarea(x: 7000, y: 8000),
    Dataarea(x: 7100, y: 6000),
    Dataarea(x: 7200, y: 4000),
    Dataarea(x: 7300, y: 2000),
    Dataarea(x: 7400, y: 6500),
    Dataarea(x: 7500, y: 1000),
    Dataarea(x: 7600, y: 3000),
    Dataarea(x: 7700, y: 5000),
    Dataarea(x: 7800, y: 7000),
    Dataarea(x: 7900, y: 7500),
    Dataarea(x: 8000, y: 5000),
    Dataarea(x: 8100, y: 3000),
    Dataarea(x: 8200, y: 1000),
    Dataarea(x: 8300, y: 5000),
    Dataarea(x: 8400, y: 7000),
    Dataarea(x: 8500, y: 5000),
    Dataarea(x: 8600, y: 6000),
    Dataarea(x: 8700, y: 4000),
    Dataarea(x: 8800, y: 2000),
    Dataarea(x: 8900, y: 8000),
    Dataarea(x: 9000, y: 7000),
    Dataarea(x: 9100, y: 8800),
    Dataarea(x: 9200, y: 10000),
    Dataarea(x: 9300, y: 6600),
    Dataarea(x: 9400, y: 6600),
    Dataarea(x: 9500, y: 9999),
    Dataarea(x: 9600, y: 5555),
    Dataarea(x: 9700, y: 4444),
    Dataarea(x: 9800, y: 6666),
    Dataarea(x: 9900, y: 7777),
    Dataarea(x: 10000, y: 3000),
  ];

  int pageIndex = 0;
  int? selectedIndex; // Holds the index of the selected container
  int? selectedtype; // Holds the index of the selected container
  int? selectedproduct; // Holds the index of the selected container
  int? selectedcategory; // Holds the index of the selected container
  List<String> selectedBedrooms = [];
  List<String> selectedBathrooms = [];

  int? selectedamenities; // Holds the index of the selected container
  int? selectedrent; // Holds the index of the selected container
  String purpose = ' ';
  String? option;
  // String category = ' ';

  String ftype = ' ';
  String amnities = ' ';
  String property_type = ' ';
  String rent = ' ';
  String min_price = '';
  String max_price = ' ';

  TextEditingController agentOrAgencyController = TextEditingController();

  List<int> selectedAmenitiesId = [];
  PropertyTypeModel? propertyTypeModel;

  // /filters expects hyphen format (for-sale / to-rent / new-projects)
  // String purposeForFilters() {
  //   if (selected == 1) return 'Buy'; // New Projects tab
  //   switch (purpose.trim().toLowerCase()) {
  //     case 'buy':
  //       return 'for-sale';
  //     case 'rent':
  //       return 'to-rent';
  //     default:
  //       return '';
  //   }
  // }

  String get currentUiPurpose {
    // if (selected == 1) return 'Buy'; // your New Projects toggle
    return (purpose.isNotEmpty ? purpose : ''); // 'Buy' | 'Rent'
  }

  // Helper: current property type label
  String get currentPropertyType {
    // If user tapped a chip, you already set `property_type`
    if (property_type.trim().isNotEmpty) return property_type.trim();

    // Otherwise, fall back to first type for the current purpose (if exists)
    final first = propertyTypeModel?.data?.isNotEmpty == true
        ? propertyTypeModel!.data!.first.name ?? ''
        : '';
    return first;
  }

  Map<String, dynamic> buildFilterQueryParams({
    String? page,
    List<String?>? search,
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
    String? agentName,
    String? agencyName,
    String? option,
    String? handoverYear,
    String? handoverQuarter,
    int? propertyCategory,
    String? completions_max,
    String? completions_min,
    List<int>? amenities,
  }) {
    final queryParams = <String, dynamic>{};

    final is7PlusBedroomSelected = bedrooms?.contains('7+') ?? false;
    final is7PlusBathroomSelected = bathrooms?.contains('7+') ?? false;

    if (page != null && page.isNotEmpty) queryParams['page'] = page;

    if (completions_min != null && completions_min.isNotEmpty)
      queryParams['completion_min'] = completions_min;

    if (completions_max != null && completions_max.isNotEmpty)
      queryParams['completion_max'] = completions_max;

    if (handoverYear != null && handoverYear.isNotEmpty)
      queryParams['handover_year'] = handoverYear;

    if (handoverQuarter != null && handoverQuarter.isNotEmpty)
      queryParams['handover_quarter'] = handoverQuarter;

    if (propertyCategory != null)
      queryParams['property_category'] =
          propertyCategory == 0 ? 'Residential' : 'Commercial';

    if (option != null && option.isNotEmpty) queryParams['option'] = option;

    if (agentName != null && agentName.isNotEmpty)
      queryParams['agent'] = agentName;

    if (agencyName != null && agencyName.isNotEmpty)
      queryParams['agency'] = agencyName;

    if (search != null && search.isNotEmpty)
      queryParams['search'] = search.join(',');
    if (propertyType != null && propertyType.isNotEmpty)
      queryParams['property_type'] = propertyType;
    if (furnishedStatus != null && furnishedStatus.isNotEmpty)
      queryParams['furnished_status'] = furnishedStatus;
    if (bedrooms != null && bedrooms.isNotEmpty && !is7PlusBedroomSelected) {
      queryParams['bedrooms'] = bedrooms.join(',');
    }
    if (bathrooms != null && bathrooms.isNotEmpty && !is7PlusBathroomSelected) {
      queryParams['bathrooms'] = bathrooms.join(',');
    }
    if (minPrice != null && minPrice.isNotEmpty)
      queryParams['min_price'] = minPrice;
    if (maxPrice != null && maxPrice.isNotEmpty)
      queryParams['max_price'] = maxPrice;
    if (paymentPeriod != null && paymentPeriod.isNotEmpty)
      queryParams['payment_period'] = paymentPeriod;
    if (minSquareFeet != null && minSquareFeet.isNotEmpty)
      queryParams['min_square_feet'] = minSquareFeet;
    if (maxSquareFeet != null && maxSquareFeet.isNotEmpty)
      queryParams['max_square_feet'] = maxSquareFeet;
    if (purpose != null && purpose.isNotEmpty) queryParams['purpose'] = purpose;
    if (amenities != null && amenities.isNotEmpty) {
      queryParams['amenities'] = amenities.join(',');
    }

    return queryParams;
  }

  String? nextPageUrl;

  Future<void> updateFilterCount(
    BuildContext context, {
    bool loadMore = false,
  }) async {
    if (isFilterListFilterModelLoading) return;
    try {
      // Stop if no more pages on loadMore
      if (loadMore && (nextPageUrl == null || nextPageUrl!.isEmpty)) {
        debugPrint("🔴 No more pages to load.");
        return;
      }
      isFilterListFilterModelLoading = true;
      notifyListeners();
      final amenitiesList = selectedAmenitiesId;

      final locList = navigatorKey.currentContext!
          .read<LocationPickerProvider>()
          .selectedLocationList;

      List<String?> locationNames = locList.map((e) {
        debugPrint('⬇⬇⬇ locations: ${e.location}');
        debugPrint('⬇⬇⬇ country: ${e.country}');

        return (e.location ?? e.country)?.toLowerCase();
      }).toList();

      debugPrint(locationNames.join(','));

      String currentPage;
      // Build URL to ALWAYS include sort_by
      if (loadMore) {
        // Derive next page from meta; don't trust links.next because it may drop sort
        final meta = filterModel?.meta;
        final current = meta?.currentPage ?? 1;
        final last = meta?.lastPage ?? 1;

        if (current >= last) {
          isLoading = false;
          notifyListeners();
          debugPrint("🔴 Already at last page.");
          return;
        }

        final nextPage = current + 1;
        currentPage = nextPage.toString();
      } else {
        currentPage = "1";
      }

      final filterQP = buildFilterQueryParams(
        page: currentPage,
        agencyName: agentOrAgencyController.text.trim().toLowerCase(),
        agentName: agentOrAgencyController.text.trim().toLowerCase(),
        search: locationNames,
        propertyType: property_type.trim(),
        furnishedStatus: ftype.trim(),
        bedrooms: selectedBedrooms,
        bathrooms: selectedBathrooms,
        minPrice: min_price.trim(),
        maxPrice: max_price.trim(),
        paymentPeriod: rent.toLowerCase().trim(),
        minSquareFeet: min_sqrfeet.trim(),
        maxSquareFeet: max_sqrfeet.trim(),
        option: option?.trim(),
        purpose: purpose,
        propertyCategory: selectedPropType,
        amenities: amenitiesList,
        handoverQuarter: handoverQuarter.trim(),
        handoverYear: handoverYear.trim(),
        completions_max: completion_max,
        completions_min: completion_min,
      );

      // debugPrint('📢 Filter API URL: $uri'); // log the URL

      // Use the new ApiService
      final response = await ApiService.get(
        'filters',
        query: filterQP,
      );

      // final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final feature = FilterResponseModel.fromJson(data);

        final List<Property> incoming = feature.data?.data ?? <Property>[];
        final List<Property> currentList =
            loadMore ? (filterModel?.data ?? <Property>[]) : <Property>[];

        // Merge + de-dupe by id
        final merged = mergeDedupData(currentList, incoming);

        filterModel = FilterModel(
          data: merged,
          links: feature.data?.links,
          meta: feature.data?.meta,
        );

        // filterModel = feature.data!;
        debugPrint('✅ filter modell count: ${filterModel?.data?.length}');

        filterResultCount = filterModel?.meta?.total ?? 0;
        displayedFilterResultCount = filterResultCount;
        debugPrint('✅ Updated filter count: $filterResultCount');

        // Compute a safe nextPageUrl that preserves sort_by
        final m = feature.data?.meta;
        if (m != null) {
          final cur = m.currentPage ?? 1;
          final last = m.lastPage ?? 1;
          nextPageUrl = (cur < last)
              ? ApiService.buildUri(
                  'properties',
                  query: {
                    'page': '${cur + 1}',
                  },
                ).toString()
              : null;
        } else {
          nextPageUrl = null;
        }
      } else {
        debugPrint("❌ API Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Error in updateFilterCount: $e");
    }
    isFilterListFilterModelLoading = false;
    notifyListeners();
  }

  List<Property> mergeDedupData(List<Property> a, List<Property> b) {
    final map = <int, Property>{};

    for (Property item in [...a, ...b]) {
      final id = (int.parse(item.id)) ?? -1;
      if (id != -1) {
        map[id] = item; // later item replaces old one
      }
    }

    return map.values.toList();
  }

  Future<void> propertyApi(String purpose) async {
    try {
      isPropertyTypeLoading = true;
      notifyListeners();

      // final uri = ApiService.buildUri('property-types/$purpose');
      //
      // final response = await http.get(uri);

      final response = await ApiService.get('property-types/$purpose');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final feature = PropertyTypeModel.fromJson(data);

        propertyTypeModel = feature;
        notifyListeners();
      } else {
        debugPrint("❌ Property API failed: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("🚨 Property API error: $e");
    }
    isPropertyTypeLoading = false;
    notifyListeners();
  }

  Future<void> fetchAmenities() async {
    // Fetch data from API if not cached or cache has expired
    try {
      // final uri = ApiService.buildUri('amenities');

      // final response = await http.get(uri).timeout(const Duration(seconds: 8));

      final response = await ApiService.get('amenities')
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        amenities = jsonData.map((data) => Amenities.fromJson(data)).toList();
      } else {
        debugPrint("❌ Failed to load amenities: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("🚨 Error fetching amenities: $e");
    }
    notifyListeners();
  }

  Future<void> loadInitialData() async {
    try {
      isLoading = true;
      notifyListeners();

      // FETCH AMENITIES

      // final uri = ApiService.buildUri('amenities');

      // final response = await http.get(uri).timeout(const Duration(seconds: 8));

      final response = await ApiService.get('amenities')
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as List;
        amenities = jsonData.map((e) => Amenities.fromJson(e)).toList();
      } else {
        debugPrint(
            '❌❌❌ Failed to Fetch Amenities, Status Code :${response.statusCode} ❌❌❌');
      }

      // FETCH PROPERTY

      if (selectedPropType != null) {
        final initialPropertyType =
            selectedPropType == 0 ? 'Residential' : 'Commercial';

        // final propertyUri =
        //     ApiService.buildUri('property-types/$initialPropertyType');
        //
        // final propertyResponse =
        //     await http.get(propertyUri).timeout(const Duration(seconds: 8));

        final propertyResponse =
            await ApiService.get('property-types/$purpose');

        if (propertyResponse.statusCode == 200) {
          final data = json.decode(propertyResponse.body);
          propertyTypeModel = PropertyTypeModel.fromJson(data);
        } else {
          debugPrint(
              '❌❌❌ Failed to Fetch Property Type, Status Code :${propertyResponse.statusCode} ❌❌❌');
        }
      }

      isLoading = false;
    } catch (e) {
      debugPrint('Error loading initial data: $e');
      isLoading = false;
    }
    notifyListeners();
  }

// Inside your State class:

  bool isResetLoading = false;

  Future<void> resetAll(BuildContext context, {required bool isUpdate}) async {
    isResetLoading = true;

    notifyListeners();
    // Reset all filter variables

    selectedtype = null;
    property_type = "";

    // Reset sliders to full range
    // priceRangeController = RangeController(start: 500, end: 300000);
    priceRangeController.start = 500;
    priceRangeController.end = 300000;

    // areaRangeController = RangeController(start: 0, end: 10000);
    areaRangeController.start = 0;
    areaRangeController.end = 10000;

    // priceRangeSelectionController = RangeController(start: 500, end: 300000);
    priceRangeSelectionController.start = 500;
    priceRangeSelectionController.end = 300000;

    // areaRangeSelectionController = RangeController(start: 0, end: 10000);
    areaRangeSelectionController.start = 0;
    areaRangeSelectionController.end = 10000;

    selected = 0;
    completion_min = "";
    completion_max = "";
    handoverQuarter = "";
    handoverYear = "";
    ftype = '';
    rent = '';
    min_price = '';
    max_price = '';
    min_sqrfeet = '';
    max_sqrfeet = '';
    agentOrAgencyController.clear();
    // Reset selected indexes and lists
    selectedIndex = null;
    selectedcategory = null;
    selectedBedrooms.clear();
    selectedBathrooms.clear();
    selectedrent = null;
    selectedAmenitiesId.clear();
    selectedHandover = 0;
    selectedPercentCompletion = 0;

    // Clear all text field controllers
    minPriceController.clear();
    maxPriceController.clear();
    minAreaController.clear();
    maxAreaController.clear();
    searchController.clear();
    agenciesController.clear();

    if (initialHomeCategory == 0) {
      //////// FOR RENT ////////
      selectedproduct = 1;
      purpose = product[selectedproduct ?? 1];
      // final purposeType = selectedPropType == 0 ? 'Residential' : 'Commercial';

      selectedPropType = null;
      // await propertyApi('Residential');
      selectedCompletion = 0;
      option = null;
    } else if (initialHomeCategory == 1) {
      //////// FOR BUY ////////
      selectedproduct = 0;
      purpose = product[selectedproduct ?? 0];
      selectedPropType = null;
      // await propertyApi('Residential');
      selectedCompletion = 0;
      option = null;
    } else if (initialHomeCategory == 2) {
      //////// OFFPLAN PROPERTIES ////////
      selectedproduct = 0;
      purpose = product[selectedproduct ?? 0];
      selectedPropType = null;
      // await propertyApi('Residential');

      selectedCompletion = 2;
      option = 'offplan';
    } else if (initialHomeCategory == 3) {
      //////// COMMERCIALS ////////
      selectedproduct = 1;
      purpose = product[selectedproduct ?? 1];

      selectedPropType = 1;
      await propertyApi('Commercial');
      selectedCompletion = 0;
      option = null;
    } else if (initialHomeCategory == 4) {
      //////// VILLAS ////////
      selectedproduct = 1;
      purpose = product[selectedproduct ?? 1];
      selectedPropType = 0;
      await propertyApi('Residential');

      String propertyCategoryType = "Villa";
      final index = propertyTypeModel!.data!.indexWhere(
        (item) =>
            item.name?.trim().toLowerCase() ==
            propertyCategoryType.trim().toLowerCase(),
      );
      selectedtype = index;
      property_type = propertyTypeModel!.data![index].name.toString();
      selectedCompletion = 0;
      option = null;
    } else if (initialHomeCategory == 5) {
      //////// APARTMENT ////////
      selectedproduct = 1;
      purpose = product[selectedproduct ?? 1];
      selectedPropType = 0;
      await propertyApi('Residential');

      String propertyCategoryType = "Apartment";
      final index = propertyTypeModel!.data!.indexWhere(
        (item) =>
            item.name?.trim().toLowerCase() ==
            propertyCategoryType.trim().toLowerCase(),
      );
      selectedtype = index;
      property_type = propertyTypeModel!.data![index].name.toString();
      selectedCompletion = 0;
      option = null;
    }

    context.read<LocationPickerProvider>().selectedLocationList.clear();

    if (isUpdate) {
      // Update filter count (UI)
      updateFilterCount(context);
    }
    isResetLoading = false;
    notifyListeners();
  }

  FilterSnapshot? initialSnapshot;

  FilterSnapshot get currentSnapshot => FilterSnapshot(
        agencyName: agentOrAgencyController.text.trim().toLowerCase(),
        agentName: agentOrAgencyController.text.trim().toLowerCase(),
        search: navigatorKey.currentContext!
            .read<LocationPickerProvider>()
            .selectedLocationList
            .map((e) {
          return (e.location ?? e.country)?.toLowerCase();
        }).toList(),
        propertyType: property_type.trim(),
        furnishedStatus: ftype.trim(),
        bedrooms: List.from(selectedBedrooms),
        bathrooms: List.from(selectedBathrooms),
        minPrice: min_price.trim(),
        maxPrice: max_price.trim(),
        paymentPeriod: rent.toLowerCase().trim(),
        minSquareFeet: min_sqrfeet.trim(),
        maxSquareFeet: max_sqrfeet.trim(),
        option: option?.trim(),
        purpose: purpose,
        propertyCategory: selectedPropType,
        amenities: List.from(selectedAmenitiesId),
        handoverQuarter: handoverQuarter.trim(),
        handoverYear: handoverYear.trim(),
        completionsMax: completion_max,
        completionsMin: completion_min,
      );

  void captureInitialSnapshot() {
    initialSnapshot = currentSnapshot;
    notifyListeners();
  }

  bool get hasChanges {
    if (initialSnapshot == null) return false;

    return !initialSnapshot!.isEqual(currentSnapshot);
  }

  int? initialHomeCategory;
  void setInitialHomeCategory(int index) {
    initialHomeCategory = index;

    notifyListeners();
  }

  void initFilterFields(
    BuildContext context, {
    required dynamic data,
    required int? propertyType,
    String? propertyCategoryType,
    String? optionType,
  }) {
    selected = 0;
    // values = const SfRangeValues(500.0, 300000.0);
    // valuesArea = SfRangeValues(0.0, 10000);

    // priceRangeController = RangeController(start: 500, end: 300000);
    // priceRangeSelectionController = RangeController(start: 500, end: 300000);
    //
    // areaRangeController = RangeController(start: 0, end: 10000);
    // areaRangeSelectionController = RangeController(start: 0, end: 10000);

    // Set selected product index and purpose
    selectedproduct = product.indexOf(data);
    selectedtype = null;

    selectedPropType = propertyType;
    purpose = data;
    selectedCompletion = 0;
    option = null;
    if (optionType != null && optionType.isNotEmpty) {
      selectedCompletion = 2;
      option = optionType;
    }

    // Initially property_type empty
    property_type = '';

    handoverQuarter = "";
    handoverYear = "";

    // Initialize range controllers
    // priceRangeController =
    //     RangeController(start: start.toString(), end: end.toString());
    // areaRangeController =
    //     RangeController(start: startarea.toString(), end: endarea.toString());

    // Build chart data
    chartData = List.generate(
      96,
      (index) => Datas(
          500 + index * 100.0, yValues[index % yValues.length].toDouble()),
    );

    // Now load initial data (property types + amenities)
    loadInitialData().then((_) {
      // After loading property types → set first type
      if (selectedPropType != null && propertyCategoryType != null) {
        final index = propertyTypeModel!.data!.indexWhere(
          (item) =>
              item.name?.trim().toLowerCase() ==
              propertyCategoryType?.trim().toLowerCase(),
        );

        if (index != -1) {
          selectedtype = index;
          property_type = propertyTypeModel!.data![index].name ?? '';
        } else {
          selectedtype = 0;
          property_type = propertyTypeModel!.data!.first.name ?? '';
        }
      } else {
        // selectedtype = 0;
        // property_type = propertyTypeModel!.data!.first.name ?? '';
      }

      // Now that we have purpose + property_type → update count
      captureInitialSnapshot();
      // updateFilterCount(context);
    });

    notifyListeners();
  }

  Future<void> setProperties(BuildContext context) async {
    isLoading = true; // hide type chips briefly
    option = null;
    selected = 0;
    selectedCompletion = 0; // reset Handover/Completion
    selectedproduct ??= 0; // default to "Buy" when coming from New Projects
    purpose = product[selectedproduct!]; // "Buy" or "Rent"
    if (purpose != 'Rent') {
      selectedrent = null;
      rent = '';
    }

    // 1) Reload property types for the chosen purpose
    // await propertyApi(purpose);
    //
    // // 2) Pick the first type safely (if any)
    // final firstTypeName = (propertyTypeModel?.data?.isNotEmpty ?? false)
    //     ? (propertyTypeModel!.data!.first.name ?? '')
    //     : '';

    // selectedtype = firstTypeName.isNotEmpty ? 0 : null;
    // property_type = firstTypeName; // '' if none returned

    // 3) Update the live count → drives "Showing X Results"
    // await updateFilterCount(context);
    isLoading = false;

    notifyListeners();
  }

  Future<void> setNewProjects(BuildContext context) async {
    selected = 1;
    selectedCompletion = 0; // default to “All”
    selectedproduct = null;
    purpose = 'Buy';
    option = 'offplan';
    selectedrent = null;
    rent = '';
    selectedtype = null;
    property_type = '';

    // await updateFilterCount(context);
    notifyListeners();
  }

  Future<void> setSelectedProductType(BuildContext context, int index) async {
    isLoading = true;
    notifyListeners();
    selectedproduct = index;
    purpose = product[index];

    selectedCompletion = 0;

    option = index == 0 ? 'All' : null;

    // // fetch property types for the selected purpose
    // await propertyApi(purpose);
    //
    // // pick the first type safely (if any)
    // final firstTypeName = (propertyTypeModel?.data?.isNotEmpty ?? false)
    //     ? (propertyTypeModel!.data!.first.name ?? '')
    //     : '';
    //
    // selectedtype = 0; // select first chip
    // property_type = firstTypeName; // set its name ('' if none)

    // refresh the live “Showing X Results” count
    // await updateFilterCount(context);
    isLoading = false;

    notifyListeners();
  }

  Future<void> setSelectedPropertyCategoryType(
    BuildContext context, {
    required int index,
  }) async {
    if (selectedtype == index) {
      selectedtype = null;
      property_type = "";
    } else {
      selectedtype = index;
      property_type = propertyTypeModel!.data![index].name.toString();
    }

    // await updateFilterCount(context); // 👈 add this line
    notifyListeners();
  }

  Future<void> setSelectedPropertyType(
    BuildContext context, {
    required int? index,
  }) async {
    if (index == null) return;
    if (isPropertyTypeLoading) return;
    selectedtype = null;
    property_type = "";
    selectedPropType = index;

    // // fetch property types for the selected purpose
    final purposeType = selectedPropType == 0 ? 'Residential' : 'Commercial';
    await propertyApi(purposeType);

    // // pick the first type safely (if any)
    // final firstTypeName = (propertyTypeModel?.data?.isNotEmpty ?? false)
    //     ? (propertyTypeModel!.data!.first.name ?? '')
    //     : '';
    //
    // selectedtype = 0; // select first chip
    // property_type = firstTypeName; // set its name ('' if none)
    // await updateFilterCount(context);

    notifyListeners();
  }

  Future<void> showResult(
    BuildContext context, {
    bool autoUpdate = false,
    required VoidCallback onFilterResultZero,
    required VoidCallback onFilterResultNotZero,
  }) async {
    isLoading = true;
    notifyListeners();

    await updateFilterCount(context); // ✅ Call update first

    // After updating count — if NOT autoUpdate → navigate
    if (!autoUpdate) {
      if (filterModel?.data?.isEmpty ?? false) {
        onFilterResultZero();
      } else {
        // ✅ Push Replacement with route name to avoid duplicate FliterList
        // REPLACE your current Navigator call inside the big red button:

        // context
        //     .read<MainBottomNavBarProvider>()
        //     .setSelectedItemIndex(ScreenEnum.fliterListScreen);
        onFilterResultNotZero();
      }
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> setSelectedBedrooms(
    BuildContext context, {
    required int index,
  }) async {
    final item = bedroomList[index];
    if (selectedBedrooms.contains(item)) {
      selectedBedrooms.remove(item);
    } else {
      selectedBedrooms.add(item);
    }

    // await updateFilterCount(context); // ✅ NOW this will work
    notifyListeners();
  }

  Future<void> setSelectedBathrooms(
    BuildContext context, {
    required int index,
  }) async {
    final item = bathroomList[index];

    if (selectedBathrooms.contains(item)) {
      selectedBathrooms.remove(item);
    } else {
      selectedBathrooms.add(item);
    }

    // await updateFilterCount(context); // ✅ call API to update count
    notifyListeners();
  }

  Future<void> setSelectedFurnishedType(
    BuildContext context, {
    required int index,
  }) async {
    selectedIndex = index;
    ftype = formateSelectedFurnishedType(ftypeList[index]);
    // await updateFilterCount(context); // ✅ call API to update count
    notifyListeners();
  }

  String formateSelectedFurnishedType(String name) {
    switch (name) {
      case 'All':
        return 'all';
      case 'Furnished':
        return 'furnished';
      case 'Semifurnished':
        return 'semiFurnished';
      case 'Unfurnished':
        return 'unfurnished';
      default:
        return '';
    }
  }

  Future<void> setSelectedAreaRange(BuildContext context,
      {required SfRangeValues value}) async {
    valuesArea = SfRangeValues(value.start, value.end);
    min_sqrfeet = value.start.toStringAsFixed(0);
    max_sqrfeet = value.end.toStringAsFixed(0);

    // Sync text fields only if user isn't editing
    if (!isMinAreaTyping ||
        minAreaController.text != value.start.toStringAsFixed(0)) {
      minAreaController.text = value.start.toStringAsFixed(0);
    }

    if (!isMaxAreaTyping ||
        maxAreaController.text != value.end.toStringAsFixed(0)) {
      maxAreaController.text = value.end.toStringAsFixed(0);
    }
    // updateFilterCount(context);

    notifyListeners();
  }

  Future<void> setSelectedAmenities(
    BuildContext context, {
    required int index,
  }) async {
    if (selectedAmenitiesId.contains(amenities[index].id)) {
      selectedAmenitiesId.remove(amenities[index].id);
    } else {
      selectedAmenitiesId.add(amenities[index].id!);
    }
    // await updateFilterCount(context);
    notifyListeners();
  }

  Future<void> setSelectedRentType(
    BuildContext context, {
    required int index,
  }) async {
    selectedrent = index;
    rent = rentList[index];
    // await updateFilterCount(context);
    notifyListeners();
  }

  Future<void> setSelectedCompletionStatus(
    BuildContext context, {
    required int index,
  }) async {
    selectedCompletion = index;
    final name = completion[selectedCompletion];

    option = formateSelectedCompletionStatus(name);
    notifyListeners();

    // await updateFilterCount(context);
  }

  String formateSelectedCompletionStatus(String name) {
    switch (name) {
      case 'All':
        return 'all';
      case 'Ready':
        return 'ready';
      case 'Off-Plan':
        return 'offplan';
      default:
        return '';
    }
  }

  String handoverYear = '';
  String handoverQuarter = '';

  Future<void> setSelectedHandOverBy(
    BuildContext context, {
    required int index,
  }) async {
    selectedHandover = index;
    final handoverBy =
        (handoverOptions[index] == 'Any') ? '' : handoverOptions[index];

    final reg = RegExp(r'^(Q\d)\s+(\d{4})$');
    final match = reg.firstMatch(handoverBy);

    if (match != null) {
      final quarter = match.group(1)!;
      final year = match.group(2)!;

      handoverYear = year;
      handoverQuarter = quarter;

      debugPrint("quarter : ${quarter} --- year : ${year}");
    } else {
      handoverYear = handoverBy;
    }

    // await updateFilterCount(context);
    notifyListeners();
  }

  String completion_min = '';
  String completion_max = '';

  Future<void> setSelectedCompletionPercentage(
    BuildContext context, {
    required int index,
  }) async {
    selectedPercentCompletion = index;

    final selected = percentCompletionOptions[index];

    if (selected == 'Any') {
      completion_min = '';
      completion_max = '';
    } else {
      // Example: "25-50%" → split
      final range = selected.replaceAll('%', '').split('-');

      completion_min = range[0].trim(); // "25"
      completion_max = range[1].trim(); // "50"
    }

    debugPrint('min: $completion_min , max: $completion_max');

    // await updateFilterCount(context);
    notifyListeners();
  }

  /////////////////////////////////  FILTER LIST SCREEN FUNCTIONALITY   /////////////////////////////////

  // void initFilterListFunctions() {
  //   setSelectedFilterListProductLocally(selectedproduct!);
  //   notifyListeners();
  // }

  int? filterListSelectedProduct;

  void setSelectedFilterListProductLocally(int index) {
    filterListSelectedCompletion = 0;
    filterListSelectedProduct = index;
    notifyListeners();
  }

  int? filterListSelectedPropertyCategoryType;

  void setSelectedFilterListPropertyCategoryType(int index) {
    filterListSelectedPropertyCategoryType = index;
    notifyListeners();
  }

  ////// PROPERTY TYPE ///////

  int? filterListSelectedPropType;
  int? filterListSelectedType;

  Future<void> setSelectedFilterListPropertyType({
    required int? index,
  }) async {
    if (isFilterListPropertyTypeLoading) return;
    filterListSelectedType = null;
    filterListSelectedPropType = index;

    if (filterListSelectedPropType != null) {
      // // fetch property types for the selected purpose
      final purposeType =
          filterListSelectedPropType == 0 ? 'Residential' : 'Commercial';
      await filterListPropertyApi(purposeType);
    }

    notifyListeners();
  }

  PropertyTypeModel? filterListPropertyTypeModel;
  bool isFilterListPropertyTypeLoading = false;

  Future<void> filterListPropertyApi(String purpose) async {
    try {
      isFilterListPropertyTypeLoading = true;
      notifyListeners();

      // final uri = ApiService.buildUri('property-types/$purpose');

      // final response = await http.get(uri).timeout(const Duration(seconds: 10));
      final response = await ApiService.get('property-types/$purpose')
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final feature = PropertyTypeModel.fromJson(data);

        filterListPropertyTypeModel = feature;
      } else {
        debugPrint("❌ Property API failed: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("🚨 Property API error: $e");
    }
    isFilterListPropertyTypeLoading = false;
    notifyListeners();
  }

  void setSelectedFilterListPropertyCategory(int? index) {
    if (filterListSelectedType == index) {
      filterListSelectedType = null;
    } else {
      filterListSelectedType = index;
    }

    notifyListeners();
  }

  ///// PRICE RANGE /////

  SfRangeValues filterListValues =
      SfRangeValues(500.0, 300000.0); // full range internally

  String filterList_Min_price = '';
  String filterList_Max_price = ' ';

  void setSelectedFilterRangePriceRange({
    required double minPrice,
    required double maxPrice,
  }) {
    debugPrint("min price: ${minPrice} ,   maxPrice: ${maxPrice}");

    filterListValues = SfRangeValues(minPrice, maxPrice);

    filterList_Min_price = minPrice.toStringAsFixed(0);
    filterList_Max_price = maxPrice.toStringAsFixed(0);
    notifyListeners();
  }

  ///BEDROOM ////

  List<String> selectedFilterListBedroomsList = [];

  Future<void> setSelectedFilterListBedrooms({
    required int index,
  }) async {
    final item = bedroomList[index];
    if (selectedFilterListBedroomsList.contains(item)) {
      selectedFilterListBedroomsList.remove(item);
    } else {
      selectedFilterListBedroomsList.add(item);
    }

    notifyListeners();
  }

  ///BATHROOM ////

  List<String> selectedFilterListBathroomsList = [];

  Future<void> setSelectedFilterListBathrooms({
    required int index,
  }) async {
    final item = bathroomList[index];

    if (selectedFilterListBathroomsList.contains(item)) {
      selectedFilterListBathroomsList.remove(item);
    } else {
      selectedFilterListBathroomsList.add(item);
    }

    notifyListeners();
  }

//////// AREA / SIZE ////////

  SfRangeValues filterListValuesArea = SfRangeValues(0.0, 10000.0);

  String filterList_Min_sqr_feet = '';
  String filterList_Max_sqr_feet = ' ';

  void setSelectedFilterListAreaSize({
    required double minSqrFeet,
    required double maxSqrFeet,
  }) {
    filterListValuesArea = SfRangeValues(minSqrFeet, maxSqrFeet);

    filterList_Min_sqr_feet = minSqrFeet.toStringAsFixed(0);
    filterList_Max_sqr_feet = maxSqrFeet.toStringAsFixed(0);
    notifyListeners();
  }

  int filterListSelectedCompletion = 0;

  Future<void> setSelectedFilterListCompletionStatus({
    required int index,
  }) async {
    filterListSelectedCompletion = index;
    notifyListeners();
  }
}
