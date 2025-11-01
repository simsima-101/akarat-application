  class FeaturedResponseModel {
    bool? status;
    String? message;
    FeaturedModel? data;

    FeaturedResponseModel({this.status, this.message, this.data});

    FeaturedResponseModel.fromJson(Map<String, dynamic> json) {
      status = json['status'];
      message = json['message'];
      data = json['data'] != null ? FeaturedModel.fromJson(json['data']) : null;
    }

    Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = {};
      data['status'] = status;
      data['message'] = message;
      if (this.data != null) {
        data['data'] = this.data!.toJson();
      }
      return data;
    }
  }

  class FeaturedModel {
    List<Data>? data;
    Links? links;
    Meta? meta;
    int? totalProperties;

    FeaturedModel({this.data, this.links, this.meta, this.totalProperties});

    FeaturedModel.fromJson(Map<String, dynamic> json) {
      if (json['data'] != null) {
        data = <Data>[];
        json['data'].forEach((v) {
          data!.add(Data.fromJson(v));
        });
      }
      links = json['links'] != null ? Links.fromJson(json['links']) : null;
      meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
      // Note: adapt to your API field name if needed (total_properties or total_featured_properties)
      totalProperties = json['total_properties'] ?? json['total_featured_properties'];
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
      data['total_properties'] = totalProperties;
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
    String? paymentPeriod;
    int? bedrooms;
    int? bathrooms;
    String? squareFeet;
    List<Media>? media;
    bool? saved;
    String? agentImage;
    String? agentName;
    String? agencyLogo;
    String? postedOn;

    Data({
      this.id,
      this.title,
      this.price,
      this.address,
      this.location,
      this.phoneNumber,
      this.whatsapp,
      this.paymentPeriod,
      this.bedrooms,
      this.bathrooms,
      this.squareFeet,
      this.media,
      this.saved,
      this.agentImage,
      this.agentName,
      this.agencyLogo,
      this.postedOn
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
      agentImage = json['agent_image'];
      agentName = json['agent'];
      agencyLogo = json['agency_logo'];
      postedOn = json['posted_on'];



      if (json['media'] != null) {
        media = <Media>[];
        json['media'].forEach((v) {
          media!.add(Media.fromJson(v));
        });
      }
    }

    Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = {};
      data['id'] = id;
      data['title'] = title;
      data['price'] = price;
      data['address'] = address;
      data['location'] = location;
      data['phone_number'] = phoneNumber;
      data['whatsapp'] = whatsapp;
      data['payment_period'] = paymentPeriod;
      data['bedrooms'] = bedrooms;
      data['bathrooms'] = bathrooms;
      data['square_feet'] = squareFeet;
      data['saved'] = saved;
      data['agent_image'] = agentImage;
      data['agent'] = agentName;
      data['agency_logo'] = agencyLogo;
      data['posted_on'] = postedOn;

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
      final Map<String, dynamic> data = {};
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
      final Map<String, dynamic> data = {};
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
      if (json['links'] != null) {
        links = <MetaLinks>[];
        json['links'].forEach((v) {
          links!.add(MetaLinks.fromJson(v));
        });
      }
      path = json['path'];
      perPage = json['per_page'];
      to = json['to'];
      total = json['total'];
    }

    Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = {};
      data['current_page'] = currentPage;
      data['from'] = from;
      data['last_page'] = lastPage;
      if (links != null) {
        data['links'] = links!.map((v) => v.toJson()).toList();
      }
      data['path'] = path;
      data['per_page'] = perPage;
      data['to'] = to;
      data['total'] = total;
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
      final Map<String, dynamic> data = {};
      data['url'] = url;
      data['label'] = label;
      data['active'] = active;
      return data;
    }
  }