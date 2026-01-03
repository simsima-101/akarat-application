// lib/features/agency/data/models/agent_properties_model.dart

import 'package:Akarat/src/features/property/data/models/property_model.dart';
// This import gives us:
// - The correct Property class (used by PropertyCard)
// - The correct Media class
// - The getFullImageUrl function

class AgencyPropertiesResponseModel {
  bool? success;
  String? message;
  AgentProperties? data;

  AgencyPropertiesResponseModel({this.success, this.message, this.data});

  AgencyPropertiesResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? AgentProperties.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class AgentProperties {
  List<Data>? data;
  Links? links;
  Meta? meta;

  AgentProperties({this.data, this.links, this.meta});

  AgentProperties.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    links = json['links'] != null ? Links.fromJson(json['links']) : null;
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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
  String? paymentPeriod;
  String? address;
  String? location;
  String? phoneNumber;
  String? whatsapp;
  List<Media>? media; // ← Uses the shared Media from property_model.dart
  String? agentName;
  String? agentImage;
  String? agencyLogo;
  String? postedOn;
  String? image;
  bool? saved;

  int? bedrooms;
  int? bathrooms;

  dynamic propertySizeSqft;
  String? squareFeet;

  Data({
    this.id,
    this.title,
    this.price,
    this.paymentPeriod,
    this.address,
    this.location,
    this.phoneNumber,
    this.whatsapp,
    this.media,
    this.agentName,
    this.agentImage,
    this.agencyLogo,
    this.postedOn,
    this.image,
    this.saved,
    this.bedrooms,
    this.bathrooms,
    this.propertySizeSqft,
    this.squareFeet,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['id'],
      title: json['title']?.toString(),
      price: json['price']?.toString(),
      paymentPeriod: json['payment_period']?.toString(),
      address: json['address']?.toString(),
      location: json['location']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      whatsapp: json['whatsapp']?.toString(),
      agentName: json['agent']?.toString(),
      agentImage: json['agent_image']?.toString(),
      agencyLogo: json['agency_logo']?.toString(),
      postedOn: json['posted_on']?.toString(),
      image: json['image']?.toString(),
      saved: json['saved'],

      bedrooms: int.tryParse(json['bedrooms']?.toString() ?? '') ?? 0,
      bathrooms: int.tryParse(json['bathrooms']?.toString() ?? '') ?? 0,

      propertySizeSqft: json['propertySizeSqft'],
      squareFeet: json['square_feet']?.toString(),

      media: json['media'] != null
          ? (json['media'] as List<dynamic>)
          .map((v) => Media.fromJson(v as Map<String, dynamic>))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['price'] = price;
    data['payment_period'] = paymentPeriod;
    data['address'] = address;
    data['location'] = location;
    data['phone_number'] = phoneNumber;
    data['whatsapp'] = whatsapp;
    data['agent'] = agentName;
    data['agent_image'] = agentImage;
    data['agency_logo'] = agencyLogo;
    data['posted_on'] = postedOn;
    data['image'] = image;
    data['saved'] = saved;
    data['bedrooms'] = bedrooms;
    data['bathrooms'] = bathrooms;
    data['propertySizeSqft'] = propertySizeSqft;
    data['square_feet'] = squareFeet;

    if (media != null) {
      data['media'] = media!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Links {
  String? first;
  String? last;
  String? prev;
  String? next;

  Links({this.first, this.last, this.prev, this.next});

  factory Links.fromJson(Map<String, dynamic> json) {
    return Links(
      first: json['first'],
      last: json['last'],
      prev: json['prev'],
      next: json['next'],
    );
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
  List<MetaPaginationLink>? links;
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

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      currentPage: json['current_page'],
      from: json['from'],
      lastPage: json['last_page'],
      links: (json['links'] as List?)
          ?.map((e) => MetaPaginationLink.fromJson(e))
          .toList(),
      path: json['path'],
      perPage: json['per_page'],
      to: json['to'],
      total: json['total'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
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

class MetaPaginationLink {
  String? url;
  String? label;
  bool? active;

  MetaPaginationLink({this.url, this.label, this.active});

  factory MetaPaginationLink.fromJson(Map<String, dynamic> json) {
    return MetaPaginationLink(
      url: json['url'],
      label: json['label']?.toString(),
      active: json['active'],
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'label': label,
    'active': active,
  };
}

/// ===============================================================
/// EXTENSION: Convert Data → Property (for PropertyCard reuse)
/// ===============================================================

extension DataToProperty on Data {
  Property toProperty() {
    return Property(
      id: id?.toString() ?? '',
      title: title ?? 'No title',
      description: '', // Required field — no description in agent API
      image: media?.isNotEmpty == true
          ? getFullImageUrl(media!.first.originalUrl)
          : getFullImageUrl(image),
      price: price ?? 'Price on request',
      location: location ?? address ?? 'Location not available',
      media: media ?? [],
      bedrooms: bedrooms ?? 0,
      bathrooms: bathrooms ?? 0,
      squareFeet: squareFeet ?? '',
      propertySizeSqft: _parseDouble(propertySizeSqft),
      phoneNumber: phoneNumber,
      whatsapp: whatsapp,
      agent: agentName,
      agentImage: agentImage,
      agencyLogo: agencyLogo,
      postedOn: postedOn,
      saved: saved ?? false,
    );
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') return null;
      return double.tryParse(trimmed);
    }
    return null;
  }
}