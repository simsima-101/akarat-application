// lib/src/features/property/data/models/featuredmodel.dart

import 'dart:convert';
import 'package:flutter/material.dart';

// Import the unified classes from property_model.dart
import 'property_model.dart';

class FeaturedResponseModel {
  bool? status;
  String? message;
  FeaturedModel? data;

  FeaturedResponseModel({this.status, this.message, this.data});

  factory FeaturedResponseModel.fromJson(Map<String, dynamic> json) {
    return FeaturedResponseModel(
      status: json['success'] ?? json['status'],
      message: json['message'],
      data: json['data'] != null ? FeaturedModel.fromJson(json['data']) : null,
    );
  }
}

class FeaturedModel {
  List<Data>? data;
  Links? links;
  Meta? meta;
  int? totalProperties;

  FeaturedModel({this.data, this.links, this.meta, this.totalProperties});

  factory FeaturedModel.fromJson(Map<String, dynamic> json) {
    return FeaturedModel(
      data: json['data'] != null
          ? (json['data'] as List).map((v) => Data.fromJson(v)).toList()
          : null,
      links: json['links'] != null ? Links.fromJson(json['links']) : null,
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
      totalProperties: json['total_properties'] ?? json['total_featured_properties'],
    );
  }
}

// Main Property Data — uses unified Media and DldPermitInfo
class Data {
  final int? id;
  final String? title;
  final String? price;
  final String? address;
  final String? location;
  final String? phoneNumber;
  final String? whatsapp;
  final String? paymentPeriod;
  final int? bedrooms;
  final int? bathrooms;
  final String? squareFeet;
  final List<Media>? media;        // ← Now uses unified Media
  final bool? saved;
  final String? agentImage;
  final String? agentName;
  final String? agencyLogo;
  final String? postedOn;

  final dynamic propertySizeSqft;
  final DldPermitInfo? dldPermitInfo; // ← Now uses unified DldPermitInfo

  Data({
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
    this.media,
    this.saved,
    this.agentImage,
    this.agentName,
    this.agencyLogo,
    this.postedOn,
    this.propertySizeSqft,
    this.dldPermitInfo,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    DldPermitInfo? dldInfo;

    final sqft = json['propertySizeSqft'];
    if (sqft != null && sqft.toString().trim().isNotEmpty && sqft.toString() != 'null') {
      dldInfo = DldPermitInfo(propertySize: sqft.toString());
    } else {
      final permitResponse = json['permit_response']?.toString();
      if (permitResponse != null && permitResponse.isNotEmpty && permitResponse != 'null') {
        dldInfo = DldPermitInfo.fromPermitResponse(permitResponse);
      }
    }

    return Data(
      id: json['id'] as int?,
      title: json['title']?.toString(),
      price: json['price']?.toString(),
      address: json['address']?.toString(),
      location: json['location']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      whatsapp: json['whatsapp']?.toString(),
      paymentPeriod: json['payment_period']?.toString(),
      bedrooms: json['bedrooms'] is int ? json['bedrooms'] : int.tryParse(json['bedrooms']?.toString() ?? ''),
      bathrooms: json['bathrooms'] is int ? json['bathrooms'] : int.tryParse(json['bathrooms']?.toString() ?? ''),
      squareFeet: json['square_feet']?.toString(),
      media: json['media'] != null
          ? (json['media'] as List).map((v) => Media.fromJson(v)).toList()
          : null,
      saved: json['saved'] == true || json['saved'] == 1 || json['saved']?.toString() == 'true',
      agentName: json['agent_name']?.toString() ?? json['agent']?.toString(),
      agentImage: json['agent_image']?.toString() ?? json['agentImage']?.toString(),
      agencyLogo: json['agency_logo']?.toString() ?? json['agencyLogo']?.toString(),
      postedOn: json['posted_on']?.toString() ?? json['postedOn']?.toString(),
      propertySizeSqft: json['propertySizeSqft'],
      dldPermitInfo: dldInfo,
    );
  }

  String get displaySize {
    if (propertySizeSqft != null) {
      final raw = propertySizeSqft.toString().trim();
      if (raw.isNotEmpty && raw != 'null' && raw != '0') {
        final clean = raw.replaceAll(RegExp(r'[^0-9.]'), '');
        final size = num.tryParse(clean);
        if (size != null && size > 0) {
          final formatted = size.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (m) => '${m[1]},',
          );
          return '$formatted sqft';
        }
      }
    }

    if (dldPermitInfo?.propertySize != null) {
      final raw = dldPermitInfo!.propertySize!.trim();
      if (raw.isNotEmpty && raw != 'null' && raw != '0') {
        final clean = raw.replaceAll(RegExp(r'[^0-9.]'), '');
        final size = num.tryParse(clean);
        if (size != null && size > 0) {
          final formatted = size.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (m) => '${m[1]},',
          );
          return '$formatted sqft';
        }
      }
    }

    if (squareFeet != null && squareFeet!.trim().isNotEmpty && squareFeet != "0") {
      final clean = squareFeet!.replaceAll(RegExp(r'[^0-9.]'), '');
      final size = num.tryParse(clean);
      if (size != null && size > 0) {
        final formatted = size.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (m) => '${m[1]},',
        );
        return '$formatted sqft';
      }
    }

    return '';
  }
}

// Links and Meta remain unchanged
class Links {
  final String? first, last, prev, next;
  Links({this.first, this.last, this.prev, this.next});
  factory Links.fromJson(Map<String, dynamic> json) => Links(
    first: json['first'],
    last: json['last'],
    prev: json['prev'],
    next: json['next'],
  );
}

class Meta {
  final int? currentPage, lastPage, total;
  Meta({this.currentPage, this.lastPage, this.total});
  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    currentPage: json['current_page'],
    lastPage: json['last_page'],
    total: json['total'],
  );
}