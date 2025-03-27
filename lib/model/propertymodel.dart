class ProjectDetailModel {
  Data? data;

  ProjectDetailModel({this.data});

  ProjectDetailModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  String? title;
  int? price;
  String? phoneNumber;
  String? whatsapp;
  String? description;
  String? paymentPeriod;
  int? bedrooms;
  int? bathrooms;
  String? propertyType;
  String? agent;
  int? agentId;
  String? agentImage;
  String? deliveryDate;
  int? paymentPlan;
  int? governmentFee;
  int? downPayment;
  int? duringConstruction;
  int? onHandover;
  String? projectAnnouncement;
  String? constructionStarted;
  String? expectedCompletion;
  List<Media>? media;

  Data(
      {this.id,
        this.title,
        this.price,
        this.phoneNumber,
        this.whatsapp,
        this.description,
        this.paymentPeriod,
        this.bedrooms,
        this.bathrooms,
        this.propertyType,
        this.agent,
        this.agentId,
        this.agentImage,
        this.deliveryDate,
        this.paymentPlan,
        this.governmentFee,
        this.downPayment,
        this.duringConstruction,
        this.onHandover,
        this.projectAnnouncement,
        this.constructionStarted,
        this.expectedCompletion,
        this.media});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    price = json['price'];
    phoneNumber = json['phone_number'];
    whatsapp = json['whatsapp'];
    description = json['description'];
    paymentPeriod = json['payment_period'];
    bedrooms = json['bedrooms'];
    bathrooms = json['bathrooms'];
    propertyType = json['property_type'];
    agent = json['agent'];
    agentId = json['agent_id'];
    agentImage = json['agent_image'];
    deliveryDate = json['delivery_date'];
    paymentPlan = json['payment_plan'];
    governmentFee = json['government_fee'];
    downPayment = json['down_payment'];
    duringConstruction = json['during_construction'];
    onHandover = json['on_handover'];
    projectAnnouncement = json['project_announcement'];
    constructionStarted = json['construction_started'];
    expectedCompletion = json['expected_completion'];
    if (json['media'] != null) {
      media = <Media>[];
      json['media'].forEach((v) {
        media!.add(new Media.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['price'] = this.price;
    data['phone_number'] = this.phoneNumber;
    data['whatsapp'] = this.whatsapp;
    data['description'] = this.description;
    data['payment_period'] = this.paymentPeriod;
    data['bedrooms'] = this.bedrooms;
    data['bathrooms'] = this.bathrooms;
    data['property_type'] = this.propertyType;
    data['agent'] = this.agent;
    data['agent_id'] = this.agentId;
    data['agent_image'] = this.agentImage;
    data['delivery_date'] = this.deliveryDate;
    data['payment_plan'] = this.paymentPlan;
    data['government_fee'] = this.governmentFee;
    data['down_payment'] = this.downPayment;
    data['during_construction'] = this.duringConstruction;
    data['on_handover'] = this.onHandover;
    data['project_announcement'] = this.projectAnnouncement;
    data['construction_started'] = this.constructionStarted;
    data['expected_completion'] = this.expectedCompletion;
    if (this.media != null) {
      data['media'] = this.media!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Media {
  String? originalUrl;

  Media({this.originalUrl});

  Media.fromJson(Map<String, dynamic> json) {
    originalUrl = json['original_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['original_url'] = this.originalUrl;
    return data;
  }
}