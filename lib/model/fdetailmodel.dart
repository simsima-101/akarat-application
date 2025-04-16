class Featured_DetailModel {
  bool? success;
  String? message;
  Data? data;

  Featured_DetailModel({this.success, this.message, this.data});

  Featured_DetailModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
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
  String? agent;
  int? agentId;
  String? agentImage;
  List<Media>? media;
  List<Qr>? qr;
  List<Floor>? floor;
  RegulatoryInfo? regulatoryInfo;

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
        this.agent,
        this.agentId,
        this.agentImage,
        this.media,
        this.qr,
        this.floor,
        this.regulatoryInfo});

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
    agent = json['agent'];
    agentId = json['agent_id'];
    agentImage = json['agent_image'];
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
    regulatoryInfo = json['regulatory_info'] != null
        ? new RegulatoryInfo.fromJson(json['regulatory_info'])
        : null;
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
    data['agent'] = this.agent;
    data['agent_id'] = this.agentId;
    data['agent_image'] = this.agentImage;
    if (this.media != null) {
      data['media'] = this.media!.map((v) => v.toJson()).toList();
    }
    if (this.qr != null) {
      data['qr'] = this.qr!.map((v) => v.toJson()).toList();
    }
    if (this.floor != null) {
      data['floor'] = this.floor!.map((v) => v.toJson()).toList();
    }
    if (this.regulatoryInfo != null) {
      data['regulatory_info'] = this.regulatoryInfo!.toJson();
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