class AgencyDetailmodel {
  int? id;
  String? userName;
  String? name;
  String? description;
  String? website;
  String? email;
  String? phone;
  String? address;
  String? location;
  String? statusId;
  String? ded;
  String? rera;

  AgencyDetailmodel(
      {this.id,
        this.userName,
        this.name,
        this.description,
        this.website,
        this.email,
        this.phone,
        this.address,
        this.location,
        this.statusId,
        this.ded,
        this.rera});

  AgencyDetailmodel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userName = json['user_name'];
    name = json['name'];
    description = json['description'];
    website = json['website'];
    email = json['email'];
    phone = json['phone'];
    address = json['address'];
    location = json['location'];
    statusId = json['status_id'];
    ded = json['ded'];
    rera = json['rera'];
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
    data['address'] = this.address;
    data['location'] = this.location;
    data['status_id'] = this.statusId;
    data['ded'] = this.ded;
    data['rera'] = this.rera;
    return data;
  }
}