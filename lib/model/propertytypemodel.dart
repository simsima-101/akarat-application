class PropertyTypeModel {
  bool? success;
  String? message;
  List<Data>? data;
  List<String>? availability;
  int? totalFeaturedProperties;

  PropertyTypeModel({this.success, this.message, this.data , this.totalFeaturedProperties});

  PropertyTypeModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    availability = json['availability'].cast<String>();
    totalFeaturedProperties = json['total_featured_properties'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['availability'] = this.availability;
    data['total_featured_properties'] = this.totalFeaturedProperties;
    return data;
  }
}

class Data {
  int? id;
  String? name;
  String? icon;
  String? purpose;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.id,
        this.name,
        this.icon,
        this.purpose,
        this.createdAt,
        this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    icon = json['icon'];
    purpose = json['purpose'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['icon'] = this.icon;
    data['purpose'] = this.purpose;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}