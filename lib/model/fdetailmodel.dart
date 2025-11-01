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
    property = json['property'] != null
        ? Property.fromJson(json['property'])
        : null;
    if (json['recommended'] != null) {
      recommended = <Recommended>[];
      json['recommended'].forEach((v) {
        recommended!.add(Recommended.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (property != null) {
      data['property'] = property!.toJson();
    }
    if (recommended != null) {
      data['recommended'] = recommended!.map((v) => v.toJson()).toList();
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
  String? qrLink;
  String? agentImage;
  String? postedOn;
  List<Media>? media;
  List<Qr>? qr;
  List<Floor>? floor;
  RegulatoryInfo? regulatoryInfo;
  List<Amenities>? amenities;

  Property(
      {this.id,
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
        this.qrLink,
        this.agentImage,
        this.postedOn,
        this.media,
        this.qr,
        this.floor,
        this.regulatoryInfo,
        this.amenities});

  Property.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    price = json['price'];
    address = json['address'];
    phoneNumber = json['phone_number'];
    whatsapp = json['whatsapp'];
    email = json['email'];
    location = json['location'];
    description = json['description'];
    paymentPeriod = json['payment_period'];
    bedrooms = json['bedrooms'];
    bathrooms = json['bathrooms'];
    squareFeet = json['square_feet'];
    purpose = json['purpose'];
    propertyType = json['property_type'];
    agent = json['agent'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    agentId = json['agent_id'];
    qrLink = json['qr_link'];
    agentImage = json['agent_image'];
    postedOn = json['posted_on'];
    if (json['media'] != null) {
      media = <Media>[];
      json['media'].forEach((v) {
        media!.add(Media.fromJson(v));
      });
    }
    if (json['qr'] != null) {
      qr = <Qr>[];
      json['qr'].forEach((v) {
        qr!.add(Qr.fromJson(v));
      });
    }
    if (json['floor'] != null) {
      floor = <Floor>[];
      json['floor'].forEach((v) {
        floor!.add(Floor.fromJson(v));
      });
    }
    regulatoryInfo = json['regulatory_info'] != null
        ? RegulatoryInfo.fromJson(json['regulatory_info'])
        : null;
    if (json['amenities'] != null) {
      amenities = <Amenities>[];
      json['amenities'].forEach((v) {
        amenities!.add(Amenities.fromJson(v));
      });
    }
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
    data['purpose'] = purpose;
    data['property_type'] = propertyType;
    data['agent'] = agent;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['agent_id'] = agentId;
    data['qr_link'] = qrLink;
    data['agent_image'] = agentImage;
    data['posted_on'] = postedOn;
    if (media != null) {
      data['media'] = media!.map((v) => v.toJson()).toList();
    }
    if (qr != null) {
      data['qr'] = qr!.map((v) => v.toJson()).toList();
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
    return data;
  }
}

class Media {
  String? originalUrl;

  Media({this.originalUrl});

  Media.fromJson(Map<String, dynamic> json) {
    originalUrl = json['original_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['original_url'] = originalUrl;
    return data;
  }
}

class Qr {
  String? qrUrl;

  Qr({this.qrUrl});

  Qr.fromJson(Map<String, dynamic> json) {
    qrUrl = json['qr_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['qr_url'] = qrUrl;
    return data;
  }
}
class Floor {
  String? floorUrl;

  Floor({this.floorUrl});

  Floor.fromJson(Map<String, dynamic> json) {
    floorUrl = json['floor_url'];
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

  RegulatoryInfo({this.ded, this.dldPermitNumber, this.rera, this.brn});

  RegulatoryInfo.fromJson(Map<String, dynamic> json) {
    ded = json['ded'];
    dldPermitNumber = json['dld_permit_number'];
    rera = json['rera'];
    brn = json['brn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ded'] = ded;
    data['dld_permit_number'] = dldPermitNumber;
    data['rera'] = rera;
    data['brn'] = brn;
    return data;
  }
}

class Amenities {
  String? title;
  String? icon;

  Amenities({this.title, this.icon});

  Amenities.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    icon = json['icon'];
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

  Recommended(
      {this.id,
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
        this.media});

  Recommended.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    price = json['price'];
    address = json['address'];
    location = json['location'];
    phoneNumber = json['phone_number'];
    whatsapp = json['whatsapp'];
    paymentPeriod = json['payment_period'];
    bedrooms = json['bedrooms'];
    bathrooms = json['bathrooms'];
    squareFeet = json['square_feet'];
    if (json['media'] != null) {
      media = <Media>[];
      json['media'].forEach((v) {
        media!.add(Media.fromJson(v));
      });
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