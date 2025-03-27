class ToggleModel {
  bool? success;
  String? message;
  bool? saved;
  Property? property;

  ToggleModel({this.success, this.message, this.saved, this.property});

  ToggleModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    saved = json['saved'];
    property = json['property'] != null
        ? new Property.fromJson(json['property'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    data['saved'] = this.saved;
    if (this.property != null) {
      data['property'] = this.property!.toJson();
    }
    return data;
  }
}

class Property {
  int? id;
  String? title;
  String? purpose;
  String? address;
  int? bedrooms;
  int? bathrooms;
  String? squareFeet;
  String? createdAt;
  String? price;
  String? paymentPeriod;
  String? image;

  Property(
      {this.id,
        this.title,
        this.purpose,
        this.address,
        this.bedrooms,
        this.bathrooms,
        this.squareFeet,
        this.createdAt,
        this.price,
        this.paymentPeriod,
        this.image});

  Property.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    purpose = json['purpose'];
    address = json['address'];
    bedrooms = json['bedrooms'];
    bathrooms = json['bathrooms'];
    squareFeet = json['square_feet'];
    createdAt = json['created_at'];
    price = json['price'];
    paymentPeriod = json['payment_period'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['purpose'] = this.purpose;
    data['address'] = this.address;
    data['bedrooms'] = this.bedrooms;
    data['bathrooms'] = this.bathrooms;
    data['square_feet'] = this.squareFeet;
    data['created_at'] = this.createdAt;
    data['price'] = this.price;
    data['payment_period'] = this.paymentPeriod;
    data['image'] = this.image;
    return data;
  }
}