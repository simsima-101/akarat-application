class PaginatedAgencyModel {
  bool? success;
  String? message;
  AgencyDataWrapper? data;

  PaginatedAgencyModel({this.success, this.message, this.data});

  PaginatedAgencyModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? AgencyDataWrapper.fromJson(json['data']) : null;
  }
}

class AgencyDataWrapper {
  List<Agency>? data;
  PaginationLinks? links;
  PaginationMeta? meta;

  AgencyDataWrapper({this.data, this.links, this.meta});

  AgencyDataWrapper.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Agency>[];
      json['data'].forEach((v) {
        data!.add(Agency.fromJson(v));
      });
    }
    links = json['links'] != null ? PaginationLinks.fromJson(json['links']) : null;
    meta = json['meta'] != null ? PaginationMeta.fromJson(json['meta']) : null;
  }
}

class Agency {
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
  String? agencyLogo;
  String? postedOn;
  String? agentName;
  String? agentImage;
  int? propertiesCount;

  Agency({
    this.id,
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
    this.postedOn,
    this.agencyLogo,
    this.agentImage,
    this.agentName,
    this.propertiesCount,
  });

  Agency.fromJson(Map<String, dynamic> json) {
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
    postedOn = json['posted_on'];
    agencyLogo = json['agency_logo'];
    agentImage = json['agent_image'];
    agentName = json['agent'];


  }
}

class PaginationLinks {
  String? first;
  String? last;
  String? prev;
  String? next;

  PaginationLinks({this.first, this.last, this.prev, this.next});

  PaginationLinks.fromJson(Map<String, dynamic> json) {
    first = json['first'];
    last = json['last'];
    prev = json['prev'];
    next = json['next'];
  }
}

class PaginationMeta {
  int? currentPage;
  int? from;
  int? lastPage;
  List<MetaLink>? links;
  String? path;
  int? perPage;
  int? to;
  int? total;

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

  PaginationMeta.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    from = json['from'];
    lastPage = json['last_page'];
    if (json['links'] != null) {
      links = <MetaLink>[];
      json['links'].forEach((v) {
        links!.add(MetaLink.fromJson(v));
      });
    }
    path = json['path'];
    perPage = json['per_page'];
    to = json['to'];
    total = json['total'];
  }
}

class MetaLink {
  String? url;
  String? label;
  bool? active;

  MetaLink({this.url, this.label, this.active});

  MetaLink.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    label = json['label']?.toString();
    active = json['active'];
  }
}