import 'package:flutter/cupertino.dart';

class AgentDetail {
  final int id;
  final int user_id;
  final String name;
  final String email;
  final String language;
  final String expertise;
  final String agency;
  final String about;
  final String address;
  final String experience;
  final String brn;
  final String service_area;
  final int sale;
  final int rent;
  final String image;

  AgentDetail({
    required this.id,
    required this.user_id,
    required this.name,
    required this.email,
    required this.language,
    required this.expertise,
    required this.agency,
    required this.about,
    required this.address,
    required this.experience,
    required this.brn,
    required this.service_area,
    required this.sale,
    required this.rent,
    required this.image,
  });

  factory AgentDetail.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) {
      debugPrint("API fromJson: Received null/empty JSON");
      return AgentDetail(
        id: 0,
        user_id: 0,
        name: 'na',
        email: 'na',
        language: 'na',
        expertise: 'na',
        address: 'na',
        experience: 'na',
        brn: 'na',
        service_area: 'na',
        sale: 0,
        rent: 0,
        image: 'https://example.com/default_image.jpg',
        agency: 'na',
        about: '',
      );
    }

    debugPrint("API fromJson: ${json.toString()}");
    debugPrint("JSON Keys: ${json.keys}");

    return AgentDetail(
      id: json['id'] ?? 0,
      user_id: json['user_id'] ?? 0,
      name: json['name'] ?? 'na',
      image: json['image'] ?? 'https://example.com/default_image.jpg',
      email: json['email'] ?? 'na',
      language: json['languages'] ?? 'na',
      expertise: json['expertise'] ?? 'na',
      brn: json['broker_registeration_number'] ?? 'na',
      service_area: json['service_area'] ?? 'na',
      agency: json['agency'] ?? 'na',
      about: json['about'] ?? 'na',
      address: json['address'] ?? 'na',
      experience: json['experience'] ?? 'na',
      sale: json['sale'] ?? 0,
      rent: json['rent'] ?? 0,
    );
  }
}

