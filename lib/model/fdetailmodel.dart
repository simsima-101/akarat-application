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
    // Support both:
    // 1) data: { property: {...}, recommended_properties: [...] }
    // 2) data: { id, title, ..., recommended_properties: [...] }
    if (json['property'] != null) {
      property = Property.fromJson(json['property']);
    } else {
      // flat data object is the property itself
      property = Property.fromJson(json);
    }

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
    if (property != null) {
      data['property'] = property!.toJson();
    }
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

  // NEW fields (outer JSON)
  String? project;
  String? developer;
  String? deliveryDate;
  String? zoneName;
  String? reference;

  // ✅ NEW: permit_info for QR
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
    this.permitInfo,
  });

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
    address = json['address'];
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

    paymentPeriod = json['payment_period'];
    bedrooms = json['bedrooms'];
    bathrooms = json['bathrooms'];
    squareFeet = json['square_feet']?.toString();
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

    if (json['amenities'] != null) {
      amenities = <Amenities>[];
      for (var v in json['amenities']) {
        amenities!.add(Amenities.fromJson(v));
      }
    }

    // ✅ NEW: map `permit_info` from backend
    permitInfo = json['permit_info'] != null
        ? PermitInfo.fromJson(json['permit_info'])
        : null;
  }

  /// Helper: true if we have a base64 QR in permit_info
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

  /// Can be:
  /// - Map<String, dynamic>  (like in /properties)
  /// - String                (JSON string)
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

/// ✅ Simple PermitInfo: only qr + url (from permit_info)
class PermitInfo {
  final String? qr;   // base64 PNG string
  final String? url;  // DLD validation link

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
    icon = json['icon']?.toString();
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
  List<Media>? media;

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
    this.media,
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
    squareFeet = json['square_feet']?.toString();

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
    if (media != null) {
      data['media'] = media!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
