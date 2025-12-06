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
    List<Media>? media;
    String? agentName;
    String? agentImage;
    String? agencyLogo;
    String? postedOn;
    String? image;
    bool? saved;

    int? bedrooms;
    int? bathrooms;

    // ADD THESE TWO LINES - NEW FIELDS
    dynamic propertySizeSqft;   // Can be String, int, or null from API
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
      this.propertySizeSqft,    // NEW
      this.squareFeet,
    });

    Data.fromJson(Map<String, dynamic> json) {
      id = json['id'];
      title = json['title']?.toString();
      price = json['price']?.toString();
      paymentPeriod = json['payment_period']?.toString();
      address = json['address']?.toString();
      location = json['location']?.toString();
      phoneNumber = json['phone_number']?.toString();
      whatsapp = json['whatsapp']?.toString();
      agentName = json['agent']?.toString();
      agentImage = json['agent_image']?.toString();
      agencyLogo = json['agency_logo']?.toString();
      postedOn = json['posted_on']?.toString();
      saved = json['saved'];

      // Parse bedrooms & bathrooms as int
      bedrooms = int.tryParse(json['bedrooms']?.toString() ?? '');
      bathrooms = int.tryParse(json['bathrooms']?.toString() ?? '');

      // NEW: Support both propertySizeSqft and square_feet
      propertySizeSqft = json['propertySizeSqft'];  // Can be String, int, or null
      squareFeet = json['square_feet']?.toString();

      // Media
      if (json['media'] != null) {
        media = <Media>[];
        json['media'].forEach((v) {
          media!.add(Media.fromJson(v));
        });
      }
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
      data['saved'] = saved;
      data['bedrooms'] = bedrooms;
      data['bathrooms'] = bathrooms;

      // NEW: Include both fields
      data['propertySizeSqft'] = propertySizeSqft;
      data['square_feet'] = squareFeet;

      if (media != null) {
        data['media'] = media!.map((v) => v.toJson()).toList();
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['original_url'] = originalUrl;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['first'] = first;
    data['last'] = last;
    data['prev'] = prev;
    data['next'] = next;
    return data;
  }
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
    links = (json['links'] as List?)
        ?.map((e) => MetaPaginationLink.fromJson(e))
        .toList();
    path = json['path'];
    perPage = json['per_page'];
    to = json['to'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    data['from'] = from;
    data['last_page'] = lastPage;
    data['links'] = links!.map((v) => v.toJson()).toList();
    data['path'] = path;
    data['per_page'] = perPage;
    data['to'] = to;
    data['total'] = total;
    return data;
  }
}

class MetaPaginationLink {
  String? url;
  String? label;
  bool? active;

  MetaPaginationLink({this.url, this.label, this.active});

  MetaPaginationLink.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    label = json['label']?.toString();
    active = json['active'];
  }


  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'label': label,
      'active': active,
    };
  }
}