class AgencyAgentsModel {
  bool? success;
  String? message;
  List<Data>? data;

  AgencyAgentsModel({this.success, this.message, this.data});

  AgencyAgentsModel.fromJson(Map<String, dynamic> json) {
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
  String? name;
  String? email;
  String? phone;
  String? whatsapp;
  String? languages;
  int? sale;
  int? rent;
  String? image;
  String? bio;
  int? propertiesCount;


  Data(
      {this.id,
        this.name,
        this.email,
        this.phone,
        this.whatsapp,
        this.languages,
        this.sale,
        this.rent,
        this.image,
        this.bio,
        this.propertiesCount, });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    whatsapp = json['whatsapp'];
    languages = json['languages'];
    sale = json['sale'];
    rent = json['rent'];
    image = json['image'];
    bio = json['bio']; // 👈 new
    propertiesCount = json['properties_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['whatsapp'] = this.whatsapp;
    data['languages'] = this.languages;
    data['sale'] = this.sale;
    data['rent'] = this.rent;
    data['image'] = this.image;
    data['bio'] = bio; // ✅ add this if needed
    data['properties_count'] = propertiesCount;
    return data;
  }
}