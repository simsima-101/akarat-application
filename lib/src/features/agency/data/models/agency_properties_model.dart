// lib/features/agency/data/models/agency_properties_model.dart

import 'package:Akarat/src/features/property/data/models/property_model.dart';
/// This import provides:
/// - The unified Property class (used by PropertyCard)
/// - Media class
/// - getFullImageUrl() helper function

/// Top-level response model for paginated agency properties
class AgencyPropertiesResponseModel {
  bool? success;
  String? message;
  AgencyPropertiesData? data;

  AgencyPropertiesResponseModel({this.success, this.message, this.data});

  AgencyPropertiesResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? AgencyPropertiesData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['success'] = success;
    map['message'] = message;
    if (data != null) {
      map['data'] = data!.toJson();
    }
    return map;
  }
}

/// Paginated data wrapper
class AgencyPropertiesData {
  List<Data>? data;
  Links? links;
  Meta? meta;

  AgencyPropertiesData({this.data, this.links, this.meta});

  AgencyPropertiesData.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    links = json['links'] != null ? Links.fromJson(json['links']) : null;
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    if (data != null) {
      map['data'] = data!.map((v) => v.toJson()).toList();
    }
    if (links != null) {
      map['links'] = links!.toJson();
    }
    if (meta != null) {
      map['meta'] = meta!.toJson();
    }
    return map;
  }
}

/// Individual property item returned by the agency properties endpoint
class Data {
  int? id;
  String? title;
  String? price;
  String? paymentPeriod;
  String? address;
  String? location;
  String? phoneNumber;
  String? whatsapp;
  List<Media>? media;           // Shared Media class from property_model.dart
  String? agentName;
  String? agentImage;
  String? agencyLogo;
  String? postedOn;
  String? image;                // Fallback single image if media is empty
  bool? saved;

  int? bedrooms;
  int? bathrooms;

  dynamic propertySizeSqft;     // Can be int, double, or String from API
  String? squareFeet;

  Data({
    this.id,
    this.title,
    this.price,
    this.paymentPeriod,
    this.address,
    this.location,
    this.phoneNumber,
    this.whatsapp,
    this.media,
    this.agentName,
    this.agentImage,
    this.agencyLogo,
    this.postedOn,
    this.image,
    this.saved,
    this.bedrooms,
    this.bathrooms,
    this.propertySizeSqft,
    this.squareFeet,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['id'],
      title: json['title']?.toString(),
      price: json['price']?.toString(),
      paymentPeriod: json['payment_period']?.toString(),
      address: json['address']?.toString(),
      location: json['location']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      whatsapp: json['whatsapp']?.toString(),
      agentName: json['agent']?.toString(),
      agentImage: json['agent_image']?.toString(),
      agencyLogo: json['agency_logo']?.toString(),
      postedOn: json['posted_on']?.toString(),
      image: json['image']?.toString(),
      saved: json['saved'],

      bedrooms: int.tryParse(json['bedrooms']?.toString() ?? '') ?? 0,
      bathrooms: int.tryParse(json['bathrooms']?.toString() ?? '') ?? 0,

      propertySizeSqft: json['propertySizeSqft'],
      squareFeet: json['square_feet']?.toString(),

      media: json['media'] != null
          ? (json['media'] as List<dynamic>)
          .map((v) => Media.fromJson(v as Map<String, dynamic>))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['id'] = id;
    map['title'] = title;
    map['price'] = price;
    map['payment_period'] = paymentPeriod;
    map['address'] = address;
    map['location'] = location;
    map['phone_number'] = phoneNumber;
    map['whatsapp'] = whatsapp;
    map['agent'] = agentName;
    map['agent_image'] = agentImage;
    map['agency_logo'] = agencyLogo;
    map['posted_on'] = postedOn;
    map['image'] = image;
    map['saved'] = saved;
    map['bedrooms'] = bedrooms;
    map['bathrooms'] = bathrooms;
    map['propertySizeSqft'] = propertySizeSqft;
    map['square_feet'] = squareFeet;

    if (media != null) {
      map['media'] = media!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// Pagination links
class Links {
  String? first;
  String? last;
  String? prev;
  String? next;

  Links({this.first, this.last, this.prev, this.next});

  factory Links.fromJson(Map<String, dynamic> json) {
    return Links(
      first: json['first'],
      last: json['last'],
      prev: json['prev'],
      next: json['next'],
    );
  }

  Map<String, dynamic> toJson() => {
    'first': first,
    'last': last,
    'prev': prev,
    'next': next,
  };
}

/// Pagination meta
class Meta {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;

  Meta({this.currentPage, this.lastPage, this.perPage, this.total});

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      currentPage: json['current_page'],
      lastPage: json['last_page'],
      perPage: json['per_page'],
      total: json['total'],
    );
  }

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'last_page': lastPage,
    'per_page': perPage,
    'total': total,
  };
}

/// ===============================================================
/// EXTENSION: Convert agency property (Data) → unified Property
/// This allows full reuse of PropertyCard without any changes
/// ===============================================================

extension DataToProperty on Data {
  Property toProperty() {
    // Safely handle price to avoid showing "AED 0"
    final String displayPrice = _safePrice ?? 'Price on request';

    return Property(
      id: id?.toString() ?? '',
      title: title ?? 'No title',
      description: '', // Description not available in agency properties endpoint
      image: media?.isNotEmpty == true
          ? getFullImageUrl(media!.first.originalUrl)
          : getFullImageUrl(image),
      price: displayPrice,
      location: location ?? address ?? 'Location not available',
      media: media ?? [],
      bedrooms: bedrooms ?? 0,
      bathrooms: bathrooms ?? 0,
      squareFeet: squareFeet ?? '',
      propertySizeSqft: _parseDouble(propertySizeSqft),
      phoneNumber: phoneNumber,
      whatsapp: whatsapp,
      agent: agentName,
      agentImage: agentImage,
      agencyLogo: agencyLogo,
      postedOn: postedOn,
      saved: saved ?? false,
    );
  }

  /// Avoid displaying "0" or empty prices
  String? get _safePrice {
    if (price == null || price!.trim().isEmpty) return null;
    final trimmed = price!.trim();
    if (trimmed == "0" || trimmed == "0.00" || trimmed == "null") return null;
    return trimmed;
  }

  /// Safe parsing for propertySizeSqft (can come as int, double, or String)
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') return null;
      return double.tryParse(trimmed);
    }
    return null;
  }
}