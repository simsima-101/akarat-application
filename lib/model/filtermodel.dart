class FilterResponseModel {
  bool? success;
  String? message;
  FilterModel? data;

  FilterResponseModel({this.success, this.message, this.data});

  FilterResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new FilterModel.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class FilterModel {
  List<Data>? data;
  Links? links;
  Meta? meta;

  FilterModel({this.data, this.links, this.meta});

  FilterModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null
        ? List<Data>.from(json['data'].map((v) => Data.fromJson(v)))
        : [];
    links = json['links'] != null ? new Links.fromJson(json['links']) : null;
    meta = json['meta'] != null ? new Meta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.links != null) {
      data['links'] = this.links!.toJson();
    }
    if (this.meta != null) {
      data['meta'] = this.meta!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  String? title;
  String? price;
  String? address;
  String? location;
  String? phoneNumber;
  String? whatsapp;
  String? email;
  String? paymentPeriod;
  int? bedrooms;
  int? bathrooms;
  String? squareFeet;
  List<Media>? media;
  bool? saved;

  String? agentName;
  String? agentImage;


  Data(
      {this.id,
        this.title,
        this.price,
        this.address,
        this.location,
        this.phoneNumber,
        this.whatsapp,
        this.email,
        this.paymentPeriod,
        this.bedrooms,
        this.bathrooms,
        this.squareFeet,
        this.media,
        this.saved,
        this.agentName,
        this.agentImage,


      });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    price = json['price'];
    address = json['address'];
    location = json['location'];
    phoneNumber = json['phone_number'];
    whatsapp = json['whatsapp'];
    paymentPeriod = json['payment_period'];
    bedrooms = json['bedrooms'];
    bathrooms = json['bathrooms'];
    squareFeet = json['square_feet'];
    saved = json['saved'];
    agentName = json['agent_name'];       // ✅ map from JSON
    agentImage = json['agent_image'];

    media = json['media'] != null
        ? List<Media>.from(json['media'].map((v) => Media.fromJson(v)))
        : [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['price'] = this.price;
    data['address'] = this.address;
    data['location'] = this.location;
    data['phone_number'] = this.phoneNumber;
    data['whatsapp'] = this.whatsapp;
    data['payment_period'] = this.paymentPeriod;
    data['bedrooms'] = this.bedrooms;
    data['bathrooms'] = this.bathrooms;
    data['square_feet'] = this.squareFeet;
    data['agent_name'] = this.agentName;         // ✅ include in JSON
    data['agent_image'] = this.agentImage;
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

class Links {
  String? first;
  String? last;
  String? prev;
  String? next;

  Links({this.first, this.last, this.prev, this.next});

  Links.fromJson(Map<String, dynamic> json) {
    first = json['first'];
    last = json['last'];
    prev = json['prev'];
    next = json['next'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['first'] = this.first;
    data['last'] = this.last;
    data['prev'] = this.prev;
    data['next'] = this.next;
    return data;
  }
}

class Meta {
  int? currentPage;
  int? from;
  int? lastPage;
  List<MetaLinks>? links;
  String? path;
  int? perPage;
  int? to;
  int? total;

  Meta(
      {this.currentPage,
        this.from,
        this.lastPage,
        this.links,
        this.path,
        this.perPage,
        this.to,
        this.total});

  Meta.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    from = json['from'];
    lastPage = json['last_page'];
    links = json['links'] != null
        ? List<MetaLinks>.from(json['links'].map((v) => MetaLinks.fromJson(v)))
        : [];
    path = json['path'];
    perPage = json['per_page'];
    to = json['to'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['current_page'] = this.currentPage;
    data['from'] = this.from;
    data['last_page'] = this.lastPage;
    if (this.links != null) {
      data['links'] = this.links!.map((v) => v.toJson()).toList();
    }
    data['path'] = this.path;
    data['per_page'] = this.perPage;
    data['to'] = this.to;
    data['total'] = this.total;
    return data;
  }
}

class MetaLinks {
  String? url;
  String? label;
  bool? active;

  MetaLinks({this.url, this.label, this.active});

  MetaLinks.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    label = json['label']?.toString();
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['label'] = this.label;
    data['active'] = this.active;
    return data;
  }


}

class FilterParams {
  final String? location;
  final String purpose;
  final String propertyType;
  final String bedroom;
  final String bathroom;
  final String minPrice;
  final String maxPrice;
  final String paymentPeriod;

  FilterParams({
    this.location,
    required this.purpose,
    required this.propertyType,
    required this.bedroom,
    required this.bathroom,
    required this.minPrice,
    required this.maxPrice,
    required this.paymentPeriod,
  });

  Map<String, String> toQueryMap() {
    return {
      if (location != null && location!.isNotEmpty) 'location': location!,
      if (purpose.isNotEmpty) 'purpose': purpose,
      if (propertyType.isNotEmpty) 'property_type': propertyType,
      if (bedroom.isNotEmpty) 'bedrooms': bedroom,
      if (bathroom.isNotEmpty) 'bathrooms': bathroom,
      if (minPrice.isNotEmpty) 'min_price': minPrice,
      if (maxPrice.isNotEmpty) 'max_price': maxPrice,
      if (paymentPeriod.isNotEmpty) 'payment_period': paymentPeriod,
    };
  }
}




