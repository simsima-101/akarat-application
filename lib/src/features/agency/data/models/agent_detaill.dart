

import '../../../property/data/models/property_model.dart';


class AgentDetail {
  int? id;
  int? userId;
  String? name;
  String? email;
  String? languages;
  String? expertise; // This will hold a comma-separated string of expertise names
  String? agency;
  String? about;
  String? address;
  String? experience;
  String? brokerRegisterationNumber;
  String? serviceAreas;
  int? sale;
  int? rent;
  String? image;
  String? phone;
  String? whatsapp;
  List<Property>? properties;

  AgentDetail({
    this.id,
    this.userId,
    this.name,
    this.email,
    this.languages,
    this.expertise,
    this.agency,
    this.about,
    this.address,
    this.experience,
    this.brokerRegisterationNumber,
    this.serviceAreas,
    this.sale,
    this.rent,
    this.image,
    this.phone,
    this.whatsapp,
    this.properties,
  });

  factory AgentDetail.fromJson(Map<String, dynamic> json) {
    // Handle the expertise field - it can be either a String or a List
    String? expertiseString;

    if (json['expertise'] is List) {
      // If expertise is a list, convert it to a comma-separated string
      final expertiseList = json['expertise'] as List;
      expertiseString = expertiseList
          .where((item) => item is Map && item['name'] != null)
          .map((item) => item['name'] as String)
          .where((name) => name.isNotEmpty)
          .join(', ');
    } else {
      // If expertise is already a string, use it directly
      expertiseString = json['expertise'] as String?;
    }

    return AgentDetail(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      email: json['email'],
      languages: json['languages'],
      expertise: expertiseString, // Use the processed string
      agency: json['agency'],
      about: json['about'],
      address: json['address'],
      experience: json['experience'],
      brokerRegisterationNumber: json['broker_registeration_number'],
      serviceAreas: json['service_areas'],
      sale: json['sale'],
      rent: json['rent'],
      image: json['image'],
      phone: json['phone'],
      whatsapp: json['whatsapp'],
      properties: (json['properties'] as List?)
          ?.map((p) => Property.fromJson(p))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'languages': languages,
      'expertise': expertise,
      'agency': agency,
      'about': about,
      'address': address,
      'experience': experience,
      'broker_registeration_number': brokerRegisterationNumber,
      'service_areas': serviceAreas,
      'sale': sale,
      'rent': rent,
      'image': image,
      'phone': phone,
      'whatsapp': whatsapp,
      'properties': properties?.map((p) => p.toJson()).toList(),
    };
  }
}