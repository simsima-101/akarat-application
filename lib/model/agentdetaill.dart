class AgentDetail {
  int? id;
  int? userId;
  String? name;
  String? email;
  String? languages;
  String? expertise;
  String? agency;
  String? about;
  String? address;
  String? experience;
  String? brokerRegisterationNumber;
  String? serviceAreas;
  int? sale;
  int? rent;
  String? image;

  AgentDetail(
      {this.id,
        this.userId,
        this.name,
        this.email,
        this.languages,
        this.expertise,
        this.agency,
        this.about,
        this.address,
        this.experience,
        this.brokerRegisterationNumber,
        this.serviceAreas,
        this.sale,
        this.rent,
        this.image});

  AgentDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    name = json['name'];
    email = json['email'];
    languages = json['languages'];
    expertise = json['expertise'];
    agency = json['agency'];
    about = json['about'];
    address = json['address'];
    experience = json['experience'];
    brokerRegisterationNumber = json['broker_registeration_number'];
    serviceAreas = json['service_areas'];
    sale = json['sale'];
    rent = json['rent'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['languages'] = this.languages;
    data['expertise'] = this.expertise;
    data['agency'] = this.agency;
    data['about'] = this.about;
    data['address'] = this.address;
    data['experience'] = this.experience;
    data['broker_registeration_number'] = this.brokerRegisterationNumber;
    data['service_areas'] = this.serviceAreas;
    data['sale'] = this.sale;
    data['rent'] = this.rent;
    data['image'] = this.image;
    return data;
  }
}