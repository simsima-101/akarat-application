class AgencyDetailmodel {
  int? id;
  String? userName;
  String? name;
  String? description;
  String? website;
  String? email;
  String? phone;
  String? whatsapp;
  String? address;
  String? location;
  String? statusId;
  String? ded;
  String? rera;
  String? image;
  int? propertiesCount;

  AgencyDetailmodel(
      {this.id,
        this.userName,
        this.name,
        this.description,
        this.website,
        this.email,
        this.phone,
        this.whatsapp,
        this.address,
        this.location,
        this.statusId,
        this.ded,
        this.rera,
        this.image,
        this.propertiesCount});

  AgencyDetailmodel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userName = json['user_name'];
    name = json['name'];
    description = json['description'];
    website = json['website'];
    email = json['email'];
    phone = json['phone'];
    whatsapp = json['whatsapp'];
    address = json['address'];
    location = json['location'];
    statusId = json['status_id'];
    ded = json['ded'];
    rera = json['rera'];
    image = json['image'];
    propertiesCount = json['properties_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_name'] = userName;
    data['name'] = name;
    data['description'] = description;
    data['website'] = website;
    data['email'] = email;
    data['phone'] = phone;
    data['whatsapp'] = whatsapp;
    data['address'] = address;
    data['location'] = location;
    data['status_id'] = statusId;
    data['ded'] = ded;
    data['rera'] = rera;
    data['image'] = image;
    data['properties_count'] = propertiesCount;
    return data;
  }
}