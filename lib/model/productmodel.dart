class ProductModel {
  Data? data;

  ProductModel({this.data});

  ProductModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
        media!.add(new Media.fromJson(v));
      });
    }
    if (json['qr'] != null) {
      qr = <Qr>[];
      json['qr'].forEach((v) {
        qr!.add(new Qr.fromJson(v));
      });
    }
    if (json['floor'] != null) {
      floor = <Floor>[];
      json['floor'].forEach((v) {
        floor!.add(new Floor.fromJson(v));
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
        recommendedProperties!.add(new RecommendedProperties.fromJson(v));
      });
    }
    regulatoryInfo = json['regulatory_info'] != null
        ? new RegulatoryInfo.fromJson(json['regulatory_info'])
        : null;
    if (json['amenities'] != null) {
      amenities = <Amenities>[];
      json['amenities'].forEach((v) {
        amenities!.add(new Amenities.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['price'] = this.price;
    data['address'] = this.address;
    data['phone_number'] = this.phoneNumber;
    data['whatsapp'] = this.whatsapp;
    data['email'] = this.email;
    data['location'] = this.location;
    data['description'] = this.description;
    data['payment_period'] = this.paymentPeriod;
    data['bedrooms'] = this.bedrooms;
    data['bathrooms'] = this.bathrooms;
    data['square_feet'] = this.squareFeet;
    data['purpose'] = this.purpose;
    data['property_type'] = this.propertyType;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['posted_on'] = this.postedOn;
    data['delivery_date'] = this.deliveryDate;
    data['project'] = this.project;
    data['developer'] = this.developer;
    if (this.media != null) {
      data['media'] = this.media!.map((v) => v.toJson()).toList();
    }
    if (this.qr != null) {
      data['qr'] = this.qr!.map((v) => v.toJson()).toList();
    }
    if (this.floor != null) {
      data['floor'] = this.floor!.map((v) => v.toJson()).toList();
    }
    data['google_map_url'] = this.googleMapUrl;
    data['furnished_status'] = this.furnishedStatus;
    data['agent'] = this.agent;
    data['agent_id'] = this.agentId;
    data['agency_id'] = this.agencyId;
    data['closed_deals'] = this.closedDeals;
    data['zone_name'] = this.zoneName;
    data['reference'] = this.reference;
    data['qr_link'] = this.qrLink;
    data['agent_image'] = this.agentImage;
    if (this.recommendedProperties != null) {
      data['recommended_properties'] =
          this.recommendedProperties!.map((v) => v.toJson()).toList();
    }
    if (this.regulatoryInfo != null) {
      data['regulatory_info'] = this.regulatoryInfo!.toJson();
    }
    if (this.amenities != null) {
      data['amenities'] = this.amenities!.map((v) => v.toJson()).toList();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['original_url'] = this.originalUrl;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['qr_url'] = this.qrUrl;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['floor_url'] = this.floorUrl;
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
        media!.add(new Media.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['price'] = this.price;
    data['address'] = this.address;
    data['location'] = this.location;
    data['phone_number'] = this.phoneNumber;
    data['whatsapp'] = this.whatsapp;
    data['payment_period'] = this.paymentPeriod;
    data['bedrooms'] = this.bedrooms;
    data['bathrooms'] = this.bathrooms;
    data['square_feet'] = this.squareFeet;
    if (this.media != null) {
      data['media'] = this.media!.map((v) => v.toJson()).toList();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ded'] = this.ded;
    data['dld_permit_number'] = this.dldPermitNumber;
    data['rera'] = this.rera;
    data['brn'] = this.brn;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['icon'] = this.icon;
    return data;
  }
}