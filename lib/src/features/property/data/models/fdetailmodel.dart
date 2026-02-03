import 'dart:convert';

class Featured_DetailModel {
  bool? success;
  String? message;
  Data? data;

  Featured_DetailModel({this.success, this.message, this.data});

  Featured_DetailModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  Property? property;
  List<Recommended>? recommended;

  Data({this.property, this.recommended});

  Data.fromJson(Map<String, dynamic> json) {
    // Property parsing
    final propJson = json['property'] ?? json;
    property = Property.fromJson(propJson);

    // Inject agency_name if present at data level
    final dataAgency = json['agency_name'] ?? json['agencyName'];
    if (dataAgency != null && (property?.agencyName?.trim().isEmpty ?? true)) {
      property?.agencyName = dataAgency.toString().trim();
    }

    // Recommended properties
    final recJson = json['recommended'] ?? json['recommended_properties'];
    if (recJson is List) {
      recommended = recJson.map((v) => Recommended.fromJson(v)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (property != null) data['property'] = property!.toJson();
    if (recommended != null) {
      data['recommended_properties'] = recommended!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Property {
  int? id;
  String? title;
  String? price;
  String? address;
  String? phoneNumber;
  String? whatsapp;
  String? email;
  String? location;
  String? description;
  String? paymentPeriod;
  int? bedrooms;
  int? bathrooms;
  String? squareFeet;
  String? propertySizeSqft;
  String? purpose;
  String? propertyType;
  String? agent;
  String? latitude;
  String? longitude;
  int? agentId;
  String? agentImage;
  String? postedOn;
  List<Media>? media;
  List<Floor>? floor;
  RegulatoryInfo? regulatoryInfo;
  List<Amenities>? amenities;

  // Outer/project-level fields
  String? project;
  String? developer;
  String? deliveryDate;
  String? zoneName;
  String? reference;
  String? agencyName;

  // Typed project information
  ProjectInformation? projectInformation;

  // Flat fallback fields (for backward compatibility)
  String? completionPercentage;
  String? deliveryYear;
  String? projectAnnouncementDate;
  String? constructionStartDate;
  String? expectedCompletionDate;
  String? salesStartDate;
  String? governmentFee;

  PermitInfo? permitInfo;

  Property({
    this.id,
    this.title,
    this.price,
    this.address,
    this.phoneNumber,
    this.whatsapp,
    this.email,
    this.location,
    this.description,
    this.paymentPeriod,
    this.bedrooms,
    this.bathrooms,
    this.squareFeet,
    this.propertySizeSqft,
    this.purpose,
    this.propertyType,
    this.agent,
    this.latitude,
    this.longitude,
    this.agentId,
    this.agentImage,
    this.postedOn,
    this.media,
    this.floor,
    this.regulatoryInfo,
    this.amenities,
    this.project,
    this.developer,
    this.deliveryDate,
    this.zoneName,
    this.reference,
    this.agencyName,
    this.projectInformation,
    this.permitInfo,
    this.completionPercentage,
    this.deliveryYear,
    this.projectAnnouncementDate,
    this.constructionStartDate,
    this.expectedCompletionDate,
    this.salesStartDate,
    this.governmentFee,
  });

  Property.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    title = json['title'] is Map
        ? (json['title']['en'] ?? json['title']['ar'])?.toString()
        : json['title']?.toString();

    price = json['price']?.toString();
    address = json['address']?.toString();

    phoneNumber = json['phone_number']?.toString();
    whatsapp = json['whatsapp']?.toString();
    email = json['email']?.toString();
    location = json['location']?.toString();

    description = json['description'] is Map
        ? (json['description']['en'] ?? json['description']['ar'])?.toString()
        : json['description']?.toString();

    paymentPeriod = json['payment_period']?.toString() ?? json['Payment Period']?.toString();

    bedrooms = json['bedrooms'];
    bathrooms = json['bathrooms'];

    // Smart size parsing
    String? dldSize;
    final permitResponse = json['regulatory_info']?['permit_response'];
    if (permitResponse != null) {
      try {
        final decoded = permitResponse is String ? jsonDecode(permitResponse) : permitResponse;
        final result = decoded['result'];
        if (result is List && result.isNotEmpty) {
          final prop = result.first['property'];
          if (prop is Map) {
            dldSize = [
              prop['propertySizeSqft'],
              prop['propertySize'],
              prop['size'],
              prop['area'],
            ].firstWhere(
                  (e) => e != null && e.toString().trim().isNotEmpty && e.toString() != 'null',
              orElse: () => null,
            );
          }
        }
      } catch (_) {}
    }

    propertySizeSqft = dldSize ?? json['propertySizeSqft']?.toString();
    squareFeet = propertySizeSqft ?? json['square_feet']?.toString();

    purpose = json['purpose']?.toString();
    propertyType = json['property_type']?.toString();
    agent = json['agent']?.toString();
    latitude = json['latitude']?.toString();
    longitude = json['longitude']?.toString();
    agentId = json['agent_id'];
    agentImage = json['agent_image']?.toString();
    postedOn = json['posted_on']?.toString();

    project = json['project']?.toString();
    developer = json['developer']?.toString();
    deliveryDate = json['delivery_date']?.toString();
    zoneName = json['zone_name']?.toString();
    reference = json['reference']?.toString();

    // Agency name (multiple possible keys)
    agencyName = json['agency_name']?.toString() ??
        json['agencyName']?.toString() ??
        json['agency']?['name']?.toString();

    // Project information (typed)
    if (json['project_information'] is Map<String, dynamic>) {
      projectInformation = ProjectInformation.fromJson(json['project_information']);
    }

    // Flat fallbacks
    completionPercentage = json['completion_percentage']?.toString() ??
        projectInformation?.completion;

    deliveryYear = json['delivery_year']?.toString() ?? projectInformation?.deliveryYear;

    projectAnnouncementDate = json['project_announcement_date']?.toString() ??
        projectInformation?.projectAnnouncement;

    constructionStartDate = json['construction_start_date']?.toString() ??
        projectInformation?.constructionStarted;

    expectedCompletionDate = json['expected_completion_date']?.toString() ??
        projectInformation?.expectedCompletion;

    salesStartDate = json['sales_start_date']?.toString() ??
        projectInformation?.salesStarted;

    governmentFee = json['government_fee']?.toString() ?? projectInformation?.governmentFee;

    // Media
    if (json['media'] is List) {
      media = (json['media'] as List).map((v) => Media.fromJson(v)).toList();
    }

    // Floor
    if (json['floor'] is List) {
      floor = (json['floor'] as List).map((v) => Floor.fromJson(v)).toList();
    }

    // Regulatory Info
    regulatoryInfo = json['regulatory_info'] != null
        ? RegulatoryInfo.fromJson(json['regulatory_info'])
        : null;

    // Amenities (robust parsing)
    final rawAmenities = json['amenities'];
    if (rawAmenities is List) {
      amenities = rawAmenities.map((v) => Amenities.fromJson(v)).toList();
    } else if (rawAmenities is String) {
      try {
        final decoded = jsonDecode(rawAmenities);
        if (decoded is List) {
          amenities = decoded.map((v) => Amenities.fromJson(v)).toList();
        }
      } catch (_) {}
    }

    // Permit Info
    permitInfo = json['permit_info'] != null
        ? PermitInfo.fromJson(json['permit_info'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['price'] = price;
    data['address'] = address;
    data['phone_number'] = phoneNumber;
    data['whatsapp'] = whatsapp;
    data['email'] = email;
    data['location'] = location;
    data['description'] = description;
    data['payment_period'] = paymentPeriod;
    data['bedrooms'] = bedrooms;
    data['bathrooms'] = bathrooms;
    data['square_feet'] = squareFeet;
    data['propertySizeSqft'] = propertySizeSqft;
    data['purpose'] = purpose;
    data['property_type'] = propertyType;
    data['agent'] = agent;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['agent_id'] = agentId;
    data['agent_image'] = agentImage;
    data['posted_on'] = postedOn;
    data['project'] = project;
    data['developer'] = developer;
    data['delivery_date'] = deliveryDate;
    data['zone_name'] = zoneName;
    data['reference'] = reference;
    data['agency_name'] = agencyName;

    if (projectInformation != null) {
      data['project_information'] = projectInformation!.toJson();
    }

    data['completion_percentage'] = completionPercentage;
    data['delivery_year'] = deliveryYear;
    data['project_announcement_date'] = projectAnnouncementDate;
    data['construction_start_date'] = constructionStartDate;
    data['expected_completion_date'] = expectedCompletionDate;
    data['sales_start_date'] = salesStartDate;
    data['government_fee'] = governmentFee;

    if (media != null) data['media'] = media!.map((v) => v.toJson()).toList();
    if (floor != null) data['floor'] = floor!.map((v) => v.toJson()).toList();
    if (regulatoryInfo != null) data['regulatory_info'] = regulatoryInfo!.toJson();
    if (amenities != null) data['amenities'] = amenities!.map((v) => v.toJson()).toList();
    if (permitInfo != null) data['permit_info'] = permitInfo!.toJson();

    return data;
  }
}

class ProjectInformation {
  final String? completion;
  final String? deliveryYear;
  final String? projectAnnouncement;
  final String? constructionStarted;
  final String? expectedCompletion;
  final String? salesStarted;
  final String? governmentFee;
  final String? paymentPeriod;

  // Added missing building-related fields
  final String? buildingName;
  final String? totalParking;
  final String? buildingArea;
  final String? yearOfCompletion;
  final String? elevators;
  final String? totalFloors;
  final String? swimmingPools;
  final String? retailCenters;

  ProjectInformation({
    this.completion,
    this.deliveryYear,
    this.projectAnnouncement,
    this.constructionStarted,
    this.expectedCompletion,
    this.salesStarted,
    this.governmentFee,
    this.paymentPeriod,
    this.buildingName,
    this.totalParking,
    this.buildingArea,
    this.yearOfCompletion,
    this.elevators,
    this.totalFloors,
    this.swimmingPools,
    this.retailCenters,
  });

  factory ProjectInformation.fromJson(Map<String, dynamic> json) {
    String? clean(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      return (s.isEmpty || s.toLowerCase() == 'null') ? null : s;
    }

    return ProjectInformation(
      completion: clean(json['completion']),
      deliveryYear: clean(json['delivery_year']),
      projectAnnouncement: clean(json['project_announcement']),
      constructionStarted: clean(json['construction_started']),
      expectedCompletion: clean(json['expected_completion']),
      salesStarted: clean(json['sales_started']),
      governmentFee: clean(json['government_fee']),
      paymentPeriod: clean(json['payment_period']),

      // Building info fields (from project_information)
      buildingName: clean(json['building_name'] ?? json['buildingName']),
      totalParking: clean(json['total_parking'] ?? json['totalParking']),
      buildingArea: clean(json['building_area'] ?? json['buildingArea']),
      yearOfCompletion: clean(json['year_of_completion'] ?? json['yearOfCompletion']),
      elevators: clean(json['elevators'] ?? json['lift_count'] ?? json['lifts']),
      totalFloors: clean(json['total_floors'] ?? json['totalFloors']),
      swimmingPools: clean(json['swimming_pools'] ?? json['swimmingPools']),
      retailCenters: clean(json['retail_centers'] ?? json['retailCenters']),
    );
  }

  Map<String, dynamic> toJson() => {
    'completion': completion,
    'delivery_year': deliveryYear,
    'project_announcement': projectAnnouncement,
    'construction_started': constructionStarted,
    'expected_completion': expectedCompletion,
    'sales_started': salesStarted,
    'government_fee': governmentFee,
    'payment_period': paymentPeriod,
    'building_name': buildingName,
    'total_parking': totalParking,
    'building_area': buildingArea,
    'year_of_completion': yearOfCompletion,
    'elevators': elevators,
    'total_floors': totalFloors,
    'swimming_pools': swimmingPools,
    'retail_centers': retailCenters,
  };
}

class Media {
  String? originalUrl;

  Media({this.originalUrl});

  Media.fromJson(Map<String, dynamic> json) {
    originalUrl = json['original_url']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['original_url'] = originalUrl;
    return data;
  }
}

class Floor {
  String? floorUrl;

  Floor({this.floorUrl});

  Floor.fromJson(Map<String, dynamic> json) {
    floorUrl = json['floor_url']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['floor_url'] = floorUrl;
    return data;
  }
}

class RegulatoryInfo {
  String? ded;
  String? dldPermitNumber;
  String? rera;
  String? brn;
  dynamic permitResponse;

  RegulatoryInfo({
    this.ded,
    this.dldPermitNumber,
    this.rera,
    this.brn,
    this.permitResponse,
  });

  RegulatoryInfo.fromJson(Map<String, dynamic> json) {
    ded = json['ded']?.toString();
    dldPermitNumber = json['dld_permit_number']?.toString();
    rera = json['rera']?.toString();
    brn = json['brn']?.toString();
    permitResponse = json['permit_response'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ded'] = ded;
    data['dld_permit_number'] = dldPermitNumber;
    data['rera'] = rera;
    data['brn'] = brn;
    data['permit_response'] = permitResponse;
    return data;
  }
}

class PermitInfo {
  final String? qr; // base64 PNG string
  final String? url; // DLD validation link

  const PermitInfo({this.qr, this.url});

  factory PermitInfo.fromJson(Map<String, dynamic> json) {
    return PermitInfo(
      qr: json['qr'] as String?,
      url: json['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'qr': qr,
      'url': url,
    };
  }
}

class Amenities {
  String? title;
  String? icon;

  Amenities({this.title, this.icon});

  Amenities.fromJson(Map<String, dynamic> json) {
    title = json['title']?.toString();

    // Raw value from API (can be full URL, relative, etc.)
    final rawIcon = (json['icon'] ??
        json['icon_url'] ??
        json['image'])
        ?.toString()
        .trim();

    icon = _normalizeIcon(rawIcon);
  }

  /// Make sure the amenity icon is a clean, usable URL
  String? _normalizeIcon(String? value) {
    if (value == null || value.isEmpty || value.toLowerCase() == 'null') {
      return null;
    }

    // If API already sends full URL (like in your example), just use it
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    // Otherwise treat it as a relative path
    return 'https://akarat.com/$value';
    // or use https://akarat.com/ if you’re on prod:
    // return 'https://akarat.com/$value';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['icon'] = icon;
    return data;
  }

  String getTitle(String currentLang) {
    // If title is stored as plain string (most common case in your current model)
    return title ?? '';

    // ──────────────────────────────────────────────
    // OR — if title can be a map like {'en': '...', 'ar': '...'}
    // (uncomment if your API sometimes sends localized objects)
    /*
  if (title == null) return '';

  try {
    final decoded = jsonDecode(title!);
    if (decoded is Map<String, dynamic>) {
      final key = currentLang.toLowerCase() == 'ar' ? 'ar' : 'en';
      return decoded[key]?.toString() ?? decoded['en']?.toString() ?? title!;
    }
  } catch (_) {
    // not json → use as-is
  }

  return title!;
  */
  }
}

class Recommended {
  int? id;
  String? title;
  String? price;
  String? address;
  String? location;
  String? phoneNumber;
  String? whatsapp;
  String? paymentPeriod;
  int? bedrooms;
  int? bathrooms;
  String? squareFeet;
  String? propertySizeSqft;
  List<Media>? media;

  RegulatoryInfo? regulatoryInfo;

  Recommended({
    this.id,
    this.title,
    this.price,
    this.address,
    this.location,
    this.phoneNumber,
    this.whatsapp,
    this.paymentPeriod,
    this.bedrooms,
    this.bathrooms,
    this.squareFeet,
    this.propertySizeSqft,
    this.media,
    this.regulatoryInfo,
  });

  Recommended.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title']?.toString();
    price = json['price']?.toString();
    address = json['address']?.toString();
    location = json['location']?.toString();
    phoneNumber = json['phone_number']?.toString();
    whatsapp = json['whatsapp']?.toString();
    paymentPeriod = json['payment_period']?.toString();
    bedrooms = json['bedrooms'];
    bathrooms = json['bathrooms'];
    // ============ SMART SIZE PARSING (DLD FIRST) ============
    String? dldSize;

// Try to get size from DLD permit_response (most accurate)
    final permitResponse = json['regulatory_info']?['permit_response'];
    if (permitResponse != null) {
      try {
        final decoded = permitResponse is String ? jsonDecode(permitResponse) : permitResponse;
        final result = decoded['result'];
        if (result is List && result.isNotEmpty) {
          final prop = result.first['property'];
          if (prop is Map) {
            dldSize = [
              prop['propertySizeSqft'],
              prop['propertySize'],
              prop['size'],
              prop['area'],
            ].firstWhere(
                  (e) => e != null && e.toString().trim().isNotEmpty && e.toString() != 'null',
              orElse: () => null,
            );
          }
        }
      } catch (_) {}
    }

// New flat field from API
    final newSize = json['propertySizeSqft']?.toString();

// Final priority: DLD → new field → old square_feet
    final bestSize = dldSize ?? newSize ?? json['square_feet']?.toString();

    propertySizeSqft = dldSize ?? newSize;  // Keep the best source
    squareFeet = bestSize;                  // Keep old field working
    propertySizeSqft = json['propertySizeSqft']?.toString();

    // ✅ FIXED: this was using ":" instead of assignment before
    regulatoryInfo = json['regulatory_info'] != null
        ? RegulatoryInfo.fromJson(json['regulatory_info'])
        : null;

    if (json['media'] != null) {
      media = <Media>[];
      for (var v in json['media']) {
        media!.add(Media.fromJson(v));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['price'] = price;
    data['address'] = address;
    data['location'] = location;
    data['phone_number'] = phoneNumber;
    data['whatsapp'] = whatsapp;
    data['payment_period'] = paymentPeriod;
    data['bedrooms'] = bedrooms;
    data['bathrooms'] = bathrooms;
    data['square_feet'] = squareFeet;
    data['propertySizeSqft'] = squareFeet;
    if (media != null) {
      data['media'] = media!.map((v) => v.toJson()).toList();
    }
    if (regulatoryInfo != null) {
      data['regulatory_info'] = regulatoryInfo!.toJson();
    }
    return data;
  }
}
