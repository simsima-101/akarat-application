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
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
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
  String? verified;
  String? projectType;
  String? image;
  String? phone;
  String? whatsapp;

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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['featured'] = featured;
    data['price'] = price;
    data['address'] = address;
    data['bedrooms'] = bedrooms;
    data['bathrooms'] = bathrooms;
    data['square_feet'] = squareFeet;
    data['location'] = location;
    data['location_id'] = locationId;
    data['verified'] = verified;
    data['project_type'] = projectType;
    data['image'] = image;
    data['phone'] = phone;
    data['whatsapp'] = whatsapp;
    return data;
  }
}