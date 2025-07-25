// Full model class for paginated agency properties response

class AgencyPropertiesResponseModel {
  bool? success;
  String? message;
  AgencyPropertiesData? data;

  AgencyPropertiesResponseModel({this.success, this.message, this.data});

  AgencyPropertiesResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? AgencyPropertiesData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data?.toJson(),
  };
}

class AgencyPropertiesData {
  List<Property>? data;
  Links? links;
  Meta? meta;

  AgencyPropertiesData({this.data, this.links, this.meta});

  AgencyPropertiesData.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Property>[];
      json['data'].forEach((v) => data!.add(Property.fromJson(v)));
    }
    links = json['links'] != null ? Links.fromJson(json['links']) : null;
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() => {
    'data': data?.map((v) => v.toJson()).toList(),
    'links': links?.toJson(),
    'meta': meta?.toJson(),
  };
}

class Property {
  int? id;
  String? title;
  String? price;
  String? paymentPeriod;
  String? address;
  String? location;
  String? phoneNumber;
  String? whatsapp;
  String? agentImage;
  String? agentName;
  String? postedOn;
  String? agencyLogo;
  String? bedrooms;
  String? bathrooms;
  String? squareFeet;
  List<Media>? media;

  Property({
    this.id,
    this.title,
    this.price,
    this.paymentPeriod,
    this.address,
    this.location,
    this.phoneNumber,
    this.whatsapp,
    this.media,
    this.agentImage,
    this.postedOn,
    this.agencyLogo,
    this.agentName,
    this.bathrooms,
    this.bedrooms,
    this.squareFeet,
  });

  Property.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title']?.toString();
    price = json['price']?.toString();
    paymentPeriod = json['payment_period']?.toString();
    address = json['address']?.toString();
    location = json['location']?.toString();
    phoneNumber = json['phone_number']?.toString();
    whatsapp = json['whatsapp']?.toString();
    agentName = json['agent']?.toString();
    postedOn = json['posted_on']?.toString();
    agencyLogo = json['agency_logo']?.toString();
    agentImage = json['agent_image']?.toString();
    bathrooms = json['bathrooms']?.toString();
    bedrooms = json['bedrooms']?.toString();
    squareFeet = json['square_feet']?.toString(); // 🔧 was wrong key before!

    if (json['media'] != null) {
      media = <Media>[];
      json['media'].forEach((v) => media!.add(Media.fromJson(v)));
    }
  }


  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'price': price,
    'payment_period': paymentPeriod,
    'address': address,
    'location': location,
    'phone_number': phoneNumber,
    'whatsapp': whatsapp,
    'agent': agentName,
    'posted_on': postedOn,
    'agent_image': agentImage,
    'agency_logo': agencyLogo,
    'bedrooms': bedrooms,
    'bathrooms': bathrooms,
    '': squareFeet,

    'media': media?.map((v) => v.toJson()).toList(),
  };
}

class Media {
  String? originalUrl;

  Media({this.originalUrl});

  Media.fromJson(Map<String, dynamic> json) {
    originalUrl = json['original_url'];
  }

  Map<String, dynamic> toJson() => {
    'original_url': originalUrl,
  };
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

  Map<String, dynamic> toJson() => {
    'first': first,
    'last': last,
    'prev': prev,
    'next': next,
  };
}

class Meta {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;

  Meta({this.currentPage, this.lastPage, this.perPage, this.total});

  Meta.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    perPage = json['per_page'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'last_page': lastPage,
    'per_page': perPage,
    'total': total,
  };
}
