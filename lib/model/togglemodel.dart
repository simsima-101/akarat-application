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
        ? Property.fromJson(json['property'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    data['saved'] = saved;
    if (property != null) {
      data['property'] = property!.toJson();
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['purpose'] = purpose;
    data['address'] = address;
    data['bedrooms'] = bedrooms;
    data['bathrooms'] = bathrooms;
    data['square_feet'] = squareFeet;
    data['created_at'] = createdAt;
    data['price'] = price;
    data['payment_period'] = paymentPeriod;
    data['image'] = image;
    return data;
  }
}