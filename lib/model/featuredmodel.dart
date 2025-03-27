
class FeaturedModel {
  bool? success;
  String? message;
  List<Data>? data;

  FeaturedModel({this.success, this.message, this.data});

  FeaturedModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
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
  String? location;
  String? description;
  String? paymentPeriod;
  int? bedrooms;
  int? bathrooms;
  String? squareFeet;
  String? purpose;
  String? propertyType;
  List<Media>? media;

  Data(
      {this.id,
        this.title,
        this.price,
        this.address,
        this.phoneNumber,
        this.whatsapp,
        this.location,
        this.description,
        this.paymentPeriod,
        this.bedrooms,
        this.bathrooms,
        this.squareFeet,
        this.purpose,
        this.propertyType,
        this.media});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    price = json['price'];
    address = json['address'];
    phoneNumber = json['phone_number'];
    whatsapp = json['whatsapp'];
    location = json['location'];
    description = json['description'];
    paymentPeriod = json['payment_period'];
    bedrooms = json['bedrooms'];
    bathrooms = json['bathrooms'];
    squareFeet = json['square_feet'];
    purpose = json['purpose'];
    propertyType = json['property_type'];
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
    data['phone_number'] = this.phoneNumber;
    data['whatsapp'] = this.whatsapp;
    data['location'] = this.location;
    data['description'] = this.description;
    data['payment_period'] = this.paymentPeriod;
    data['bedrooms'] = this.bedrooms;
    data['bathrooms'] = this.bathrooms;
    data['square_feet'] = this.squareFeet;
    data['purpose'] = this.purpose;
    data['property_type'] = this.propertyType;
    if (this.media != null) {
      data['media'] = this.media!.map((v) => v.toJson()).toList();
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