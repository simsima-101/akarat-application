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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_name'] = this.userName;
    data['name'] = this.name;
    data['description'] = this.description;
    data['website'] = this.website;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['whatsapp'] = this.whatsapp;
    data['address'] = this.address;
    data['location'] = this.location;
    data['status_id'] = this.statusId;
    data['ded'] = this.ded;
    data['rera'] = this.rera;
    data['image'] = this.image;
    data['properties_count'] = this.propertiesCount;
    return data;
  }
}