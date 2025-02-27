import 'package:flutter/cupertino.dart';

class ProductModel {
  final int id;
  final String title;
  final String media;
  final String propertyType;
  final String location;
  final double price;
  final String description;
  final int bathrooms;
  final int bedrooms;
  final double squareFeet;
  final List<String> amenities;
  final String postedOn;
  final double? latitude;
  final double? longitude;
  final String googleMapUrl;
  final RegulatoryInfo regulatoryInfo;
  final Agent agent;
  final List<ProductModel> recommendedProperties;

  ProductModel({
    required this.id,
    required this.title,
    required this.media,
    required this.propertyType,
    required this.location,
    required this.price,
    required this.description,
    required this.bathrooms,
    required this.bedrooms,
    required this.squareFeet,
    required this.amenities,
    required this.postedOn,
    this.latitude,
    this.longitude,
    required this.googleMapUrl,
    required this.regulatoryInfo,
    required this.agent,
    required this.recommendedProperties,
  });

  factory ProductModel.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) {
      debugPrint("API fromJson: Received null/empty JSON");
      return ProductModel(
        id: 0,
        title: 'na',
        media: 'https://example.com/default_image.jpg',
        propertyType: 'na',
        location: 'na',
        price: 0.0,
        description: 'na',
        bathrooms: 0,
        bedrooms: 0,
        squareFeet: 0.0,
        amenities: [],
        postedOn: 'na',
        latitude: null,
        longitude: null,
        googleMapUrl: '',
        regulatoryInfo: RegulatoryInfo.fromJson({}),
        agent: Agent.fromJson({}),
        recommendedProperties: [],
      );
    }

    debugPrint("API fromJson: ${json.toString()}");
    debugPrint("JSON Keys: ${json.keys}");

    return ProductModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'na',
      media: json['media'] ?? 'https://example.com/default_image.jpg',
      propertyType: json['property_type'] ?? 'na',
      location: json['location'] ?? 'na',
      price: (json['price'] ?? 0.0).toDouble(),
      description: json['description'] ?? 'na',
      bathrooms: json['bathrooms'] ?? 0,
      bedrooms: json['bedrooms'] ?? 0,
      squareFeet: double.tryParse(json['square_feet']?.toString() ?? '0.0') ?? 0.0,
      amenities: (json['amenities'] as List<dynamic>?)?.map((item) => item.toString()).toList() ?? [],
      postedOn: json['posted_on'] ?? 'na',
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      googleMapUrl: json['google_map_url'] ?? '',
      regulatoryInfo: RegulatoryInfo.fromJson(json['regulatory_info'] ?? {}),
      agent: Agent.fromJson(json['agent'] ?? {}),
      recommendedProperties: (json['recommended_properties'] as List?)
          ?.map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class RegulatoryInfo {
  final String reference;
  final String listed;
  final String brokerLicense;
  final String zoneName;
  final String dldPermitNumber;
  final String agentLicense;

  RegulatoryInfo({
    required this.reference,
    required this.listed,
    required this.brokerLicense,
    required this.zoneName,
    required this.dldPermitNumber,
    required this.agentLicense,
  });

  factory RegulatoryInfo.fromJson(Map<String, dynamic>? json) {
    return RegulatoryInfo(
      reference: json?['reference'] ?? 'na',
      listed: json?['listed'] ?? 'na',
      brokerLicense: json?['broker_license'] ?? 'na',
      zoneName: json?['zone_name'] ?? 'na',
      dldPermitNumber: json?['dld_permit_number'] ?? 'na',
      agentLicense: json?['agent_license'] ?? 'na',
    );
  }
}

class Agent {
  final String name;
  final String img;
  final int rating;
  final String whatsapp;
  final String email;
  final String phone;

  Agent({
    required this.name,
    required this.img,
    required this.rating,
    required this.whatsapp,
    required this.email,
    required this.phone,
  });

  factory Agent.fromJson(Map<String, dynamic>? json) {
    return Agent(
      name: json?['name'] ?? 'Unknown',
      img: json?['img'] ?? 'na',
      rating: json?['rating'] ?? 0,
      whatsapp: json?['whatsapp'] ?? '',
      email: json?['email'] ?? '',
      phone: json?['phone'] != null ? json!['phone'].toString() : '',
    );
  }
}
