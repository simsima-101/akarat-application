class PaginatedAgentsModel {
  final bool? success;
  final String? message;
  final AgentPaginationData? data;

  PaginatedAgentsModel({this.success, this.message, this.data});

  factory PaginatedAgentsModel.fromJson(Map<String, dynamic> json) {
    return PaginatedAgentsModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? AgentPaginationData.fromJson(json['data']) : null,
    );
  }
}

class AgentPaginationData {
  final List<AgentsModel>? data;
  final PaginationLinks? links;
  final PaginationMeta? meta;

  AgentPaginationData({this.data, this.links, this.meta});

  factory AgentPaginationData.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] is List
        ? json['data'] as List<dynamic>
        : json['data']?['data'] as List<dynamic>?;

    return AgentPaginationData(
      data: dataList?.map((e) => AgentsModel.fromJson(e)).toList(),
      links: json['links'] != null
          ? PaginationLinks.fromJson(json['links'])
          : json['data']?['links'] != null
          ? PaginationLinks.fromJson(json['data']['links'])
          : null,
      meta: json['meta'] != null
          ? PaginationMeta.fromJson(json['meta'])
          : json['data']?['meta'] != null
          ? PaginationMeta.fromJson(json['data']['meta'])
          : null,
    );
  }
}

class AgentsModel {
  final int id;
  final String name;
  final String email;
  final String languages;
  final String expertise;
  final String agency;
  final int sale;
  final int rent;
  final String image;
  final String? bio;
  final String? phoneNumber;  // this maps to "phone_number"
  final String? whatsapp;     // this maps to "whatsapp"
  final String? agencyLogo;
  final int propertiesCount;


  AgentsModel({
    required this.id,
    required this.name,
    required this.email,
    required this.languages,
    required this.expertise,
    required this.agency,
    required this.sale,
    required this.rent,
    required this.image,
    this.bio,
    this.phoneNumber,   // ✅ add here
    this.whatsapp,      // ✅ add here
    this.agencyLogo,
    required this.propertiesCount,
  });

  factory AgentsModel.fromJson(Map<String, dynamic> json) {
    return AgentsModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'N/A',
      email: json['email'] ?? 'N/A',
      languages: json['languages'] ?? 'N/A',
      expertise: json['expertise'] ?? 'N/A',
      agency: json['agency'] ?? 'N/A',
      sale: json['sale'] ?? 0,
      rent: json['rent'] ?? 0,
      agencyLogo: json['agency_logo'] ?? '',
      propertiesCount: json['properties_count'] ?? 0,
      image: json['image'] ?? '',


    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'languages': languages,
      'expertise': expertise,
      'agency': agency,
      'sale': sale,
      'rent': rent,
      'image': image,
      'agency_logo' : agencyLogo,
      'properties_count': propertiesCount,
    };

  }
}


class PaginationLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  PaginationLinks({this.first, this.last, this.prev, this.next});

  factory PaginationLinks.fromJson(Map<String, dynamic> json) {
    return PaginationLinks(
      first: json['first'],
      last: json['last'],
      prev: json['prev'],
      next: json['next'],
    );
  }
}

class PaginationMeta {
  final int? currentPage;
  final int? from;
  final int? lastPage;
  final List<MetaLink>? links;
  final String? path;
  final int? perPage;
  final int? to;
  final int? total;

  PaginationMeta({
    this.currentPage,
    this.from,
    this.lastPage,
    this.links,
    this.path,
    this.perPage,
    this.to,
    this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'],
      from: json['from'],
      lastPage: json['last_page'],
      links: (json['links'] as List<dynamic>?)
          ?.map((e) => MetaLink.fromJson(e))
          .toList(),
      path: json['path'],
      perPage: json['per_page'],
      to: json['to'],
      total: json['total'],
    );
  }
}

class MetaLink {
  final String? url;
  final String? label;
  final bool? active;

  MetaLink({this.url, this.label, this.active});

  factory MetaLink.fromJson(Map<String, dynamic> json) {
    return MetaLink(
      url: json['url'],
      label: json['label'],
      active: json['active'],
    );
  }
}
