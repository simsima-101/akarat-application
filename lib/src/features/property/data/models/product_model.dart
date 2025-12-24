class ProductModel {
  Data? data;

  ProductModel({this.data});

  ProductModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
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
  String? latitude;
  String? longitude;
  String? postedOn;
  String? deliveryDate;
  String? project;
  String? developer;
  List<Media>? media;
  List<Qr>? qr;
  List<Floor>? floor;
  String? googleMapUrl;
  String? furnishedStatus;
  String? agent;
  int? agentId;
  int? agencyId;
  int? closedDeals;
  String? zoneName;
  String? reference;
  String? qrLink;
  String? agentImage;
  List<RecommendedProperties>? recommendedProperties;
  RegulatoryInfo? regulatoryInfo;
  List<Amenities>? amenities;

  Data(
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
        this.latitude,
        this.longitude,
        this.postedOn,
        this.deliveryDate,
        this.project,
        this.developer,
        this.media,
        this.qr,
        this.floor,
        this.googleMapUrl,
        this.furnishedStatus,
        this.agent,
        this.agentId,
        this.agencyId,
        this.closedDeals,
        this.zoneName,
        this.reference,
        this.qrLink,
        this.agentImage,
        this.recommendedProperties,
        this.regulatoryInfo,
        this.amenities});

  Data.fromJson(Map<String, dynamic> json) {
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
    latitude = json['latitude'];
    longitude = json['longitude'];
    postedOn = json['posted_on'];
    deliveryDate = json['delivery_date'];
    project = json['project'];
    developer = json['developer'];
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
    googleMapUrl = json['google_map_url'];
    furnishedStatus = json['furnished_status'];
    agent = json['agent'];
    agentId = json['agent_id'];
    agencyId = json['agency_id'];
    closedDeals = json['closed_deals'];
    zoneName = json['zone_name'];
    reference = json['reference'];
    qrLink = json['qr_link'];
    agentImage = json['agent_image'];
    if (json['recommended_properties'] != null) {
      recommendedProperties = <RecommendedProperties>[];
      json['recommended_properties'].forEach((v) {
        recommendedProperties!.add(RecommendedProperties.fromJson(v));
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
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['posted_on'] = postedOn;
    data['delivery_date'] = deliveryDate;
    data['project'] = project;
    data['developer'] = developer;
    if (media != null) {
      data['media'] = media!.map((v) => v.toJson()).toList();
    }
    if (qr != null) {
      data['qr'] = qr!.map((v) => v.toJson()).toList();
    }
    if (floor != null) {
      data['floor'] = floor!.map((v) => v.toJson()).toList();
    }
    data['google_map_url'] = googleMapUrl;
    data['furnished_status'] = furnishedStatus;
    data['agent'] = agent;
    data['agent_id'] = agentId;
    data['agency_id'] = agencyId;
    data['closed_deals'] = closedDeals;
    data['zone_name'] = zoneName;
    data['reference'] = reference;
    data['qr_link'] = qrLink;
    data['agent_image'] = agentImage;
    if (recommendedProperties != null) {
      data['recommended_properties'] =
          recommendedProperties!.map((v) => v.toJson()).toList();
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
class RecommendedProperties {
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

  RecommendedProperties(
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

  RecommendedProperties.fromJson(Map<String, dynamic> json) {
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