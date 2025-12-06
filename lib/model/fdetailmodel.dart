import 'dart:convert';

import 'package:get/get.dart';

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
    // 1) Read property normally
    final propJson = (json['property'] != null) ? json['property'] : json;
    property = Property.fromJson(propJson);

    // ✅ 2) If agency_name exists at DATA level, inject it into property
    final dataAgency = json['agency_name'] ?? json['agencyName'];
    if (dataAgency != null) {
      final current = property?.agencyName?.trim() ?? '';
      if (current.isEmpty || current.toLowerCase() == 'null') {
        property?.agencyName = dataAgency.toString();
      }
    }

    // recommended
    final recJson = json['recommended'] ?? json['recommended_properties'];
    if (recJson is List) {
      recommended = <Recommended>[];
      for (var v in recJson) {
        recommended!.add(Recommended.fromJson(v));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (property != null) data['property'] = property!.toJson();
    if (recommended != null) {
      data['recommended_properties'] =
          recommended!.map((v) => v.toJson()).toList();
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
  String? propertySizeSqft;     // ← ADD THIS LINE (this was missing!)
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

  // outer JSON fields
  String? project;
  String? developer;
  String? deliveryDate;
  String? zoneName;
  String? reference;

  // ✅ NEW: user-entered agency name
  String? agencyName;

  // ✅ Project Information (typed model)
  ProjectInformation? projectInformation;

  // ✅ Old flat Project Information fields (kept for backward compatibility)
  String? completionPercentage;
  String? deliveryYear;
  String? projectAnnouncementDate;
  String? constructionStartDate;
  String? expectedCompletionDate;
  String? salesStartDate;
  String? governmentFee;

  // ✅ permit_info for QR
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
    this.projectInformation, // ✅ added
    this.permitInfo,
    this.completionPercentage,
    this.deliveryYear,
    this.projectAnnouncementDate,
    this.constructionStartDate,
    this.expectedCompletionDate,
    this.salesStartDate,
    this.governmentFee,
    this.propertySizeSqft,
  });

  // helper to read multiple possible keys
  String? _readAny(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v != null &&
          v.toString().trim().isNotEmpty &&
          v.toString() != "null") {
        return v.toString();
      }
    }
    return null;
  }

  String? _cleanStr(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.isEmpty || s.toLowerCase() == 'null' || s == '0') return null;
    return s;
  }

  Property.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    // title can be {en, ar} or plain string
    if (json['title'] is Map) {
      title = json['title']['en']?.toString() ??
          json['title']['ar']?.toString() ??
          '';
    } else {
      title = json['title']?.toString();
    }

    price = json['price']?.toString();
    address = json['address']?.toString();

    phoneNumber = json['phone_number'];
    whatsapp = json['whatsapp'];
    email = json['email'];
    location = json['location'];

    if (json['description'] is Map) {
      description = json['description']['en']?.toString() ??
          json['description']['ar']?.toString() ??
          '';
    } else {
      description = json['description']?.toString();
    }

    // ✅ payment_period sometimes comes twice in API
    paymentPeriod = _readAny(json, ['payment_period', 'Payment Period']);

    bedrooms = json['bedrooms'];
    bathrooms = json['bathrooms'];

    // Add this line — it reads the new field from API
    propertySizeSqft = json['propertySizeSqft']?.toString();
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
            ].firstWhereOrNull((e) => e != null && e.toString().trim().isNotEmpty && e.toString() != 'null');
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
    purpose = json['purpose'];
    propertyType = json['property_type'];
    agent = json['agent'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    agentId = json['agent_id'];

    agentImage = json['agent_image'];
    postedOn = json['posted_on']?.toString();

    // outer fields
    project = json['project']?.toString();
    developer = json['developer']?.toString();
    deliveryDate = json['delivery_date']?.toString();
    zoneName = json['zone_name']?.toString();
    reference = json['reference']?.toString();

    // ✅ NEW: agency_name (supports multiple possible keys + nested object)
    agencyName = _readAny(json, [
      'agency_name',
      'agencyName',
      'agency',
      'agency_title',
      'agencyTitle',
    ]);

    // If API sends nested agency object: { agency: { name: "..." } }
    if (agencyName == null && json['agency'] is Map) {
      final a = json['agency'] as Map;
      agencyName = _cleanStr(a['name']) ?? _cleanStr(a['title']);
    }

    // ✅ if agency is nested object like {agency:{name:"..."}}
    final agencyObj = json['agency'];
    if ((agencyName == null || agencyName!.trim().isEmpty) && agencyObj is Map) {
      final a = Map<String, dynamic>.from(agencyObj);
      agencyName = _readAny(a, ['name', 'title', 'company_name', 'agency_name']);
    }

    // ==========================================================
    // ✅ NEW: Parse project_information into typed model
    // ==========================================================
    if (json['project_information'] is Map<String, dynamic>) {
      projectInformation =
          ProjectInformation.fromJson(json['project_information']);
    }

    // ✅ Old flat Project Information mapping
    completionPercentage = _readAny(json, [
      'completion_percentage',
      'Completion',
      'completion',
    ]) ?? projectInformation?.completion;

    deliveryYear = _readAny(json, [
      'delivery_year',
      'Delivery Year',
    ]) ?? projectInformation?.deliveryYear;

    projectAnnouncementDate = _readAny(json, [
      'project_announcement_date',
      'Project Announcement',
      'project_announcement',
    ]) ?? projectInformation?.projectAnnouncement;

    constructionStartDate = _readAny(json, [
      'construction_start_date',
      'Construction Started',
      'construction_started',
    ]) ?? projectInformation?.constructionStarted;

    expectedCompletionDate = _readAny(json, [
      'expected_completion_date',
      'Expected Completion',
      'expected_completion',
    ]) ?? projectInformation?.expectedCompletion;

    salesStartDate = _readAny(json, [
      'sales_start_date',
      'Sales Started',
      'sales_started',
    ]) ?? projectInformation?.salesStarted;

    governmentFee = _readAny(json, [
      'government_fee',
      'Government Fee',
    ]) ?? projectInformation?.governmentFee;

    if (json['media'] != null) {
      media = <Media>[];
      for (var v in json['media']) {
        media!.add(Media.fromJson(v));
      }
    }

    if (json['floor'] != null) {
      floor = <Floor>[];
      for (var v in json['floor']) {
        floor!.add(Floor.fromJson(v));
      }
    }

    regulatoryInfo = json['regulatory_info'] != null
        ? RegulatoryInfo.fromJson(json['regulatory_info'])
        : null;

    // ✅ Robust Amenities parsing
    final rawAmenities = json['amenities'];

    if (rawAmenities is List) {
      amenities = <Amenities>[];
      for (var v in rawAmenities) {
        if (v is Map<String, dynamic>) {
          amenities!.add(Amenities.fromJson(v));
        } else if (v is Map) {
          amenities!.add(Amenities.fromJson(Map<String, dynamic>.from(v)));
        }
      }
    } else if (rawAmenities is String) {
      // Sometimes backend sends JSON as a string
      try {
        final decoded = jsonDecode(rawAmenities);
        if (decoded is List) {
          amenities = <Amenities>[];
          for (var v in decoded) {
            if (v is Map<String, dynamic>) {
              amenities!.add(Amenities.fromJson(v));
            } else if (v is Map) {
              amenities!.add(Amenities.fromJson(Map<String, dynamic>.from(v)));
            }
          }
        }
      } catch (_) {
        // ignore parse error
      }
    } else if (rawAmenities is Map) {
      // Just in case it comes wrapped, e.g. { "data": [ ... ] }
      final list = rawAmenities['data'] ?? rawAmenities['items'];
      if (list is List) {
        amenities = <Amenities>[];
        for (var v in list) {
          if (v is Map<String, dynamic>) {
            amenities!.add(Amenities.fromJson(v));
          } else if (v is Map) {
            amenities!.add(Amenities.fromJson(Map<String, dynamic>.from(v)));
          }
        }
      }
    }

    permitInfo = json['permit_info'] != null
        ? PermitInfo.fromJson(json['permit_info'])
        : null;
  }

  bool get hasPermitQr =>
      permitInfo != null &&
          permitInfo!.qr != null &&
          permitInfo!.qr!.isNotEmpty;

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
    data['propertySizeSqft'] = propertySizeSqft;  // ← ADD THIS
    data['purpose'] = purpose;
    data['property_type'] = propertyType;
    data['agent'] = agent;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['agent_id'] = agentId;
    data['agent_image'] = agentImage;
    data['posted_on'] = postedOn;

    // outer fields
    data['project'] = project;
    data['developer'] = developer;
    data['delivery_date'] = deliveryDate;
    data['zone_name'] = zoneName;
    data['reference'] = reference;

    // ✅ NEW: agency_name
    data['agency_name'] = agencyName;

    // ✅ NEW: project_information typed
    data['project_information'] = projectInformation?.toJson();

    // ✅ Old flat Project Information fields (still stored for safety)
    data['completion_percentage'] = completionPercentage;
    data['delivery_year'] = deliveryYear;
    data['project_announcement_date'] = projectAnnouncementDate;
    data['construction_start_date'] = constructionStartDate;
    data['expected_completion_date'] = expectedCompletionDate;
    data['sales_start_date'] = salesStartDate;
    data['government_fee'] = governmentFee;

    if (media != null) {
      data['media'] = media!.map((v) => v.toJson()).toList();
    }

    if (floor != null) {
      data['floor'] = floor!.map((v) => v.toJson()).toList();
    }
    if (regulatoryInfo != null) {
      data['regulatory_info'] = regulatoryInfo!.toJson();
    }
    if (amenities != null) {
      data['amenities'] = amenities!.map((v) => v.toJson()).toList();
    }
    if (permitInfo != null) {
      data['permit_info'] = permitInfo!.toJson();
    }

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

  ProjectInformation({
    this.completion,
    this.deliveryYear,
    this.projectAnnouncement,
    this.constructionStarted,
    this.expectedCompletion,
    this.salesStarted,
    this.governmentFee,
    this.paymentPeriod,
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
    return 'https://qa.akarat.com/$value';
    // or use https://akarat.com/ if you’re on prod:
    // return 'https://akarat.com/$value';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['icon'] = icon;
    return data;
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
            ].firstWhereOrNull((e) => e != null && e.toString().trim().isNotEmpty && e.toString() != 'null');
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
