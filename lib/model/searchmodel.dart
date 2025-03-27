class SearchModel {
  bool? success;
  String? message;
  List<Data>? data;

  SearchModel({this.success, this.message, this.data});

  SearchModel.fromJson(Map<String, dynamic> json) {
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
  int? featured;
  String? price;
  String? address;
  int? bedrooms;
  int? bathrooms;
  String? squareFeet;
  String? location;
  int? locationId;
  Null? verified;
  String? projectType;
  String? image;
  Null? phone;
  Null? whatsapp;

  Data(
      {this.id,
        this.title,
        this.featured,
        this.price,
        this.address,
        this.bedrooms,
        this.bathrooms,
        this.squareFeet,
        this.location,
        this.locationId,
        this.verified,
        this.projectType,
        this.image,
        this.phone,
        this.whatsapp});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    featured = json['featured'];
    price = json['price'];
    address = json['address'];
    bedrooms = json['bedrooms'];
    bathrooms = json['bathrooms'];
    squareFeet = json['square_feet'];
    location = json['location'];
    locationId = json['location_id'];
    verified = json['verified'];
    projectType = json['project_type'];
    image = json['image'];
    phone = json['phone'];
    whatsapp = json['whatsapp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['featured'] = this.featured;
    data['price'] = this.price;
    data['address'] = this.address;
    data['bedrooms'] = this.bedrooms;
    data['bathrooms'] = this.bathrooms;
    data['square_feet'] = this.squareFeet;
    data['location'] = this.location;
    data['location_id'] = this.locationId;
    data['verified'] = this.verified;
    data['project_type'] = this.projectType;
    data['image'] = this.image;
    data['phone'] = this.phone;
    data['whatsapp'] = this.whatsapp;
    return data;
  }
}