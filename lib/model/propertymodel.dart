import 'dart:convert';
import 'package:flutter/material.dart';

import 'projectmodel.dart' as projectDetail;
import 'productmodel.dart' as productModel;
import 'searchmodel.dart' as search;

/// Build a full image URL from a relative path, with a placeholder fallback.
String getFullImageUrl(String? url) {
  if (url == null || url.isEmpty) {
    return 'https://via.placeholder.com/400x300.png?text=No+Image';
  }
  if (url.startsWith('http')) return url;
  return 'https://akarat.com/$url';
}

String sanitizeImageUrl(String? url) {
  if (url == null || url.isEmpty) {
    return 'https://via.placeholder.com/400x300.png?text=No+Image';
  }
  return url;
}

// ================================================
// DLD Permit Info Class
// ================================================
class DldPermitInfo {
  final String? propertySize;
  final String? plotSize;
  final String? permitNumber;

  DldPermitInfo({this.propertySize, this.plotSize, this.permitNumber});

  factory DldPermitInfo.fromJson(Map<String, dynamic> json) {
    return DldPermitInfo(
      propertySize: json['property_size']?.toString(),
      plotSize: json['plot_size']?.toString(),
      permitNumber: json['permit_number']?.toString(),
    );
  }

  factory DldPermitInfo.fromPermitResponse(String response) {
    try {
      final decoded = jsonDecode(response);
      final result = decoded['result'] as List?;
      if (result != null && result.isNotEmpty) {
        final propertyNode = result[0]['property'] as Map<String, dynamic>?;
        if (propertyNode != null) {
          return DldPermitInfo(
            propertySize: propertyNode['propertySize']?.toString(),
            plotSize: propertyNode['plotSize']?.toString(),
            permitNumber: result[0]['permitNumber']?.toString(),
          );
        }
      }
    } catch (e) {
      debugPrint("DLD parse error: $e");
    }
    return DldPermitInfo();
  }
}

// ================================================
// Main Property Model
// ================================================
class Property {
  final String id;
  final String title;
  final String description;
  final String image;
  final String price;
  final String location;
  final List<Media>? media;
  final int bedrooms;
  final int bathrooms;
  final String squareFeet;
  final double? propertySizeSqft; // ← NEW accurate size

  final String? phoneNumber;
  final String? whatsapp;
  final String? agent;
  final String? agentImage;
  final String? agencyLogo;
  final String? postedOn;

  final DldPermitInfo? dldPermitInfo;
  final String? permitResponse;

  bool saved = false;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.price,
    required this.location,
    this.media,
    required this.bedrooms,
    required this.bathrooms,
    required this.squareFeet,
    this.propertySizeSqft,
    this.phoneNumber,
    this.whatsapp,
    this.agent,
    this.agentImage,
    this.agencyLogo,
    this.postedOn,
    this.dldPermitInfo,
    this.permitResponse,
    this.saved = false,
  });

  /// Smart size display with correct priority
  String get displaySize {
    // 1. Accurate propertySizeSqft (double)
    if (propertySizeSqft != null && propertySizeSqft! > 0) {
      final size = propertySizeSqft!;
      final rounded = size.round();
      final formatted = rounded.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
      );
      return '$formatted sqft';

    }

    // 2. Legacy square_feet string
    if (squareFeet.isNotEmpty && squareFeet.trim() != '0' && squareFeet.trim() != 'null') {
      final clean = squareFeet.replaceAll(RegExp(r'[^0-9.]'), '');
      final size = num.tryParse(clean);
      if (size != null && size > 0) {
        return '${size.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} sqft';
      }
    }

    // 3. DLD propertySize
    if (dldPermitInfo?.propertySize != null) {
      final raw = dldPermitInfo!.propertySize!.trim();
      if (raw.isNotEmpty && raw != 'null' && raw != '0') {
        final clean = raw.replaceAll(RegExp(r'[^0-9.]'), '');
        final size = num.tryParse(clean);
        if (size != null && size > 0) {
          return '${size.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} sqft';
        }
      }
    }

    // 4. DLD plotSize (last resort)
    if (dldPermitInfo?.plotSize != null) {
      final raw = dldPermitInfo!.plotSize!.trim();
      if (raw.isNotEmpty && raw != 'null' && raw != '0') {
        final clean = raw.replaceAll(RegExp(r'[^0-9.]'), '');
        final size = num.tryParse(clean);
        if (size != null && size > 0) {
          return '${size.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} sqft (Plot)';
        }
      }
    }

    return '';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'image': image,
    'price': price,
    'location': location,
    'media': media?.map((m) => m.toJson()).toList(),
    'bedrooms': bedrooms,
    'bathrooms': bathrooms,
    'square_feet': squareFeet,
    'propertySizeSqft': propertySizeSqft,
    'phone_number': phoneNumber,
    'whatsapp': whatsapp,
    'agent': agent,
    'agent_image': agentImage,
    'agency_logo': agencyLogo,
    'posted_on': postedOn,
    'saved': saved,
    'permit_response': permitResponse,
  };

  factory Property.fromProjectDetail(projectDetail.Data data) {
    return Property(
      id: data.id?.toString() ?? '',
      title: data.title ?? '',
      description: data.description ?? '',
      image: getFullImageUrl(data.media?.isNotEmpty == true ? data.media!.first.originalUrl : null),
      price: data.price ?? '',
      location: data.location ?? '',
      media: data.media?.map((m) => Media(originalUrl: m.originalUrl)).toList(),
      bedrooms: data.bedrooms ?? 0,
      bathrooms: data.bathrooms ?? 0,
      squareFeet: data.squareFeet ?? '',
      propertySizeSqft: Property._parseDouble(data.propertySizeSqft),
      phoneNumber: data.phoneNumber ?? '',
      whatsapp: data.whatsapp ?? '',
      saved: data.saved ?? false,
    );
  }

  factory Property.fromProductModel(productModel.Data data) {
    return Property(
      id: data.id?.toString() ?? '',
      title: data.title ?? '',
      description: data.description ?? '',
      image: getFullImageUrl(data.media?.isNotEmpty == true ? data.media!.first.originalUrl : null),
      price: data.price ?? '',
      location: data.location ?? '',
      media: data.media?.map((m) => Media(originalUrl: m.originalUrl)).toList(),
      bedrooms: data.bedrooms ?? 0,
      bathrooms: data.bathrooms ?? 0,
      squareFeet: data.squareFeet ?? '',

      // FIX → ProductModel does NOT have propertySizeSqft, so we read from JSON fallback
      propertySizeSqft: Property._parseDouble(
          (data as dynamic).propertySizeSqft
      ),

      phoneNumber: data.phoneNumber ?? '',
      whatsapp: data.whatsapp ?? '',
    );
  }

  factory Property.fromSearchModel(search.Data data) {
    return Property(
      id: data.id?.toString() ?? '',
      title: data.title ?? '',
      description: '',
      image: getFullImageUrl(data.image),
      price: data.price ?? '',
      location: data.location ?? data.address ?? '',
      media: const [],
      bedrooms: data.bedrooms ?? 0,
      bathrooms: data.bathrooms ?? 0,
      squareFeet: data.squareFeet ?? '',

      // FIX → SearchModel does NOT have propertySizeSqft, so using dynamic lookup
      propertySizeSqft: Property._parseDouble(
          (data as dynamic).propertySizeSqft
      ),

      phoneNumber: data.phone ?? '',
      whatsapp: data.whatsapp ?? '',
    );
  }


  factory Property.fromJson(Map<String, dynamic> json) {
    String? rawImage;
    final mediaField = json['media'];

    if (mediaField is List && mediaField.isNotEmpty) {
      rawImage = mediaField[0]['original_url']?.toString();
    }
    rawImage ??= json['image']?.toString();
    final fullImageUrl = getFullImageUrl(rawImage);

    int parseInt(dynamic val) => val is int ? val : int.tryParse(val?.toString() ?? '') ?? 0;

    bool parseSaved(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      if (v is num) return v != 0;
      final s = v.toString().trim();
      return s == '1' || s.toLowerCase() == 'true';
    }

    DldPermitInfo? dldInfo;
    final rawPermit = json['permit_response'];
    if (rawPermit is String && rawPermit.trim().isNotEmpty && rawPermit != 'null') {
      dldInfo = DldPermitInfo.fromPermitResponse(rawPermit);
    }

    return Property(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      image: fullImageUrl,
      price: json['price']?.toString() ?? '',
      location: json['location']?.toString() ?? json['address']?.toString() ?? '',
      media: mediaField is List ? mediaField.map((m) => Media.fromJson(m)).toList() : [],
      bedrooms: parseInt(json['bedrooms']),
      bathrooms: parseInt(json['bathrooms']),
      squareFeet: json['square_feet']?.toString() ?? '',
      propertySizeSqft: _parseDouble(json['propertySizeSqft']),
      phoneNumber: json['phone_number']?.toString() ?? json['phone']?.toString(),
      whatsapp: json['whatsapp']?.toString(),
      agent: json['agent_name']?.toString() ?? json['agent']?.toString(),
      agentImage: json['agent_image']?.toString(),
      agencyLogo: json['agency_logo']?.toString(),
      postedOn: json['posted_on']?.toString() ?? json['created_at']?.toString(),
      saved: parseSaved(json['saved']),
      dldPermitInfo: dldInfo,
      permitResponse: rawPermit is String ? rawPermit : null,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') return null;
      return double.tryParse(trimmed);
    }
    return null;
  }
} // ← Property class properly closed

// ================================================
// Media Class
// ================================================
class Media {
  String? originalUrl;

  Media({this.originalUrl});

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(originalUrl: json['original_url']?.toString());
  }

  Map<String, dynamic> toJson() => {'original_url': originalUrl};
}

// ================================================
// Project Detail Model + Data (now correctly outside Property)
// ================================================
class ProjectDetailModel {
  Data? data;

  ProjectDetailModel({this.data});

  factory ProjectDetailModel.fromJson(Map<String, dynamic> json) {
    return ProjectDetailModel(data: json['data'] != null ? Data.fromJson(json['data']) : null);
  }

  Map<String, dynamic> toJson() => {'data': data?.toJson()};
}

class Data {
  int? id;
  String? title;
  String? price;
  String? phoneNumber;
  String? whatsapp;
  String? description;
  String? paymentPeriod;
  int? bedrooms;
  int? bathrooms;
  String? propertyType;
  String? agent;
  int? agentId;
  String? agentImage;
  String? deliveryDate;
  int? paymentPlan;
  String? governmentFee;
  String? downPayment;
  String? duringConstruction;
  String? onHandover;
  String? projectAnnouncement;
  String? constructionStarted;
  String? expectedCompletion;
  List<Media>? media;
  String? location;
  String? squareFeet;
  double? propertySizeSqft; // ← NEW field
  bool? saved;
  String? reference;

  Data({
    this.id,
    this.title,
    this.price,
    this.phoneNumber,
    this.whatsapp,
    this.description,
    this.paymentPeriod,
    this.bedrooms,
    this.bathrooms,
    this.propertyType,
    this.agent,
    this.agentId,
    this.agentImage,
    this.deliveryDate,
    this.paymentPlan,
    this.governmentFee,
    this.downPayment,
    this.duringConstruction,
    this.onHandover,
    this.projectAnnouncement,
    this.constructionStarted,
    this.expectedCompletion,
    this.media,
    this.location,
    this.squareFeet,
    this.propertySizeSqft,
    this.saved,
    this.reference,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    final pp = json['payment_plan'];
    return Data(
      id: json['id'],
      title: json['title'],
      price: json['price'],
      phoneNumber: json['phone_number'],
      whatsapp: json['whatsapp'],
      description: json['description'],
      paymentPeriod: json['payment_period'],
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      propertyType: json['property_type'],
      agent: json['agent'],
      agentId: json['agent_id'],
      agentImage: json['agent_image'],
      deliveryDate: json['delivery_date'],
      paymentPlan: pp is int ? pp : (pp != null ? int.tryParse(pp.toString()) : null),
      governmentFee: json['government_fee']?.toString(),
      downPayment: json['down_payment']?.toString(),
      duringConstruction: json['during_construction']?.toString(),
      onHandover: json['on_handover']?.toString(),
      projectAnnouncement: json['project_announcement'],
      constructionStarted: json['construction_started'],
      expectedCompletion: json['expected_completion'],
      location: json['location'],
      squareFeet: json['square_feet'],
      propertySizeSqft: Property._parseDouble(json['propertySizeSqft']),
      saved: json['saved'],
      reference: json['reference'],
      media: json['media'] is List ? (json['media'] as List).map((v) => Media.fromJson(v)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'title': title,
      'price': price,
      'phone_number': phoneNumber,
      'whatsapp': whatsapp,
      'description': description,
      'payment_period': paymentPeriod,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'property_type': propertyType,
      'agent': agent,
      'agent_id': agentId,
      'agent_image': agentImage,
      'delivery_date': deliveryDate,
      'payment_plan': paymentPlan,
      'government_fee': governmentFee,
      'down_payment': downPayment,
      'during_construction': duringConstruction,
      'on_handover': onHandover,
      'project_announcement': projectAnnouncement,
      'construction_started': constructionStarted,
      'expected_completion': expectedCompletion,
      'location': location,
      'square_feet': squareFeet,
      'propertySizeSqft': propertySizeSqft,
      'saved': saved,
      'reference': reference,
    };
    if (media != null) map['media'] = media!.map((v) => v.toJson()).toList();
    return map;
  }
}