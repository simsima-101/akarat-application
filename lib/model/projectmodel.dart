import 'dart:convert';

class ProjectResponseModel {
  bool? success;
  String? message;
  ProjectModel? data;

  ProjectResponseModel({this.success, this.message, this.data});

  ProjectResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? ProjectModel.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class ProjectModel {
  List<Data>? data;
  Links? links;
  Meta? meta;

  ProjectModel({this.data, this.links, this.meta});

  ProjectModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null && json['data'] is List) {
      data = List<Data>.from(json['data'].map((v) => Data.fromJson(v)));
    }
    links = json['links'] != null ? Links.fromJson(json['links']) : null;
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (links != null) {
      data['links'] = links!.toJson();
    }
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  String? title;
  String? price;
  String? address;
  String? phoneNumber;
  String? whatsapp;
  String? location;
  String? paymentPeriod;
  int? bedrooms;
  int? bathrooms;
  String? squareFeet;
  dynamic propertySizeSqft;     // Can be double, int, or string
  List<Media>? media;
  String? email;
  String? description;
  bool saved = false;
  String? agentImage;
  String? agentName;
  String? agencyLogo;
  String? postedOn;

  Data({
    this.id,
    this.title,
    this.price,
    this.address,
    this.phoneNumber,
    this.whatsapp,
    this.location,
    this.paymentPeriod,
    this.bedrooms,
    this.bathrooms,
    this.squareFeet,
    this.propertySizeSqft,
    this.media,
    this.email,
    this.description,
    this.saved = false,
    this.agentImage,
    this.agentName,
    this.agencyLogo,
    this.postedOn,
  });

  // THIS IS THE FIX – use factory constructor
  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['id'],
      title: json['title']?.toString(),
      price: json['price']?.toString(),
      address: json['address']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      whatsapp: json['whatsapp']?.toString(),
      location: json['location']?.toString(),
      paymentPeriod: json['payment_period']?.toString(),
      bedrooms: json['bedrooms'] is int
          ? json['bedrooms']
          : int.tryParse(json['bedrooms']?.toString() ?? ''),
      bathrooms: json['bathrooms'] is int
          ? json['bathrooms']
          : int.tryParse(json['bathrooms']?.toString() ?? ''),
      squareFeet: json['square_feet']?.toString(),
      propertySizeSqft: json['propertySizeSqft'],
      email: json['email']?.toString(),
      description: json['description']?.toString(),
      agentImage: json['agent_image']?.toString(),
      agentName: json['agent']?.toString(),
      agencyLogo: json['agency_logo']?.toString(),
      postedOn: json['posted_on']?.toString(),
      saved: json['saved'] == true || json['saved'] == 1,
      media: json['media'] != null && json['media'] is List
          ? (json['media'] as List)
          .map((v) => Media.fromJson(v as Map<String, dynamic>))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'title': title,
      'price': price,
      'address': address,
      'phone_number': phoneNumber,
      'whatsapp': whatsapp,
      'location': location,
      'payment_period': paymentPeriod,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'square_feet': squareFeet,
      'propertySizeSqft': propertySizeSqft,
      'email': email,
      'description': description,
      'saved': saved,
      'agent_image': agentImage,
      'agent': agentName,
      'agency_logo': agencyLogo,
      'posted_on': postedOn,
    };
    if (media != null) {
      data['media'] = media!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  // Optional: keep your displaySize getter
  String get displaySize {
    if (propertySizeSqft != null) {
      final raw = propertySizeSqft.toString().trim();
      if (raw.isNotEmpty && raw != 'null' && raw != '0') {
        final clean = raw.replaceAll(RegExp(r'[^0-9.]'), '');
        final size = num.tryParse(clean);
        if (size != null && size > 0) {
          return '${size.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} sqft';
        }
      }
    }
    final fallback = squareFeet?.trim();
    if (fallback != null && fallback.isNotEmpty && fallback != '0') {
      final clean = fallback.replaceAll(RegExp(r'[^0-9.]'), '');
      final size = num.tryParse(clean);
      if (size != null && size > 0) {
        return '${size.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} sqft';
      }
    }
    return 'N/A';
  }
}

class Media {
  String? originalUrl;

  Media({this.originalUrl});

  Media.fromJson(Map<String, dynamic> json) {
    originalUrl = json['original_url']?.toString();
  }

  Map<String, dynamic> toJson() => {'original_url': originalUrl};
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
  int? from;
  int? lastPage;
  List<MetaLinks>? links;
  String? path;
  int? perPage;
  int? to;
  int? total;

  Meta({
    this.currentPage,
    this.from,
    this.lastPage,
    this.links,
    this.path,
    this.perPage,
    this.to,
    this.total,
  });

  Meta.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    from = json['from'];
    lastPage = json['last_page'];
    path = json['path'];
    perPage = json['per_page'];
    to = json['to'];
    total = json['total'];

    if (json['links'] != null && json['links'] is List) {
      links = [];
      for (var v in json['links']) {
        links!.add(MetaLinks.fromJson(v));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final data = {
      'current_page': currentPage,
      'from': from,
      'last_page': lastPage,
      'path': path,
      'per_page': perPage,
      'to': to,
      'total': total,
    };
    if (links != null) {
      data['links'] = links!.map((v) => v.toJson()).toList();
    }
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

  Map<String, dynamic> toJson() => {
    'url': url,
    'label': label,
    'active': active,
  };
}