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
    propertiesCount = json['total_properties'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['whatsapp'] = whatsapp;
    data['languages'] = languages;
    data['sale'] = sale;
    data['rent'] = rent;
    data['image'] = image;
    data['bio'] = bio; // ✅ add this if needed
    data['total_properties'] = propertiesCount;
    return data;
  }
}