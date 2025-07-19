class FavoriteResponseModel {
  bool? success;
  String? message;
  FavoriteModel? data;

  FavoriteResponseModel({this.success, this.message, this.data});

  FavoriteResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new FavoriteModel.fromJson(json['data']) : null;
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

class FavoriteModel {
  List<Data>? data;
  Links? links;
  Meta? meta;

  FavoriteModel({this.data, this.links, this.meta});

  FavoriteModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
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
  String? purpose;
  String? address;
  int? bedrooms;
  int? bathrooms;
  String? squareFeet;
  String? whatsapp;
  String? phone;
  String? createdAt;
  String? price;
  String? paymentPeriod;
  String? image;

  List<Media>? media;


  Data(
      {this.id,
        this.title,
        this.purpose,
        this.address,
        this.bedrooms,
        this.bathrooms,
        this.whatsapp,
        this.phone,
        this.squareFeet,
        this.createdAt,
        this.price,
        this.paymentPeriod,
        this.image,
        this.media,
      });


  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    purpose = json['purpose'];
    address = json['address'];
    bedrooms = json['bedrooms'];
    bathrooms = json['bathrooms'];
    squareFeet = json['square_feet'];
    whatsapp = json['whatsapp'];
    phone = json['phone'];
    createdAt = json['created_at'];
    price = json['price'];
    paymentPeriod = json['payment_period'];
    image = json['image'];
    if (json['media'] != null) {
      media = (json['media'] as List)
          .map((item) => Media.fromJson(item))
          .toList();
    }

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['purpose'] = this.purpose;
    data['address'] = this.address;
    data['bedrooms'] = this.bedrooms;
    data['bathrooms'] = this.bathrooms;
    data['square_feet'] = this.squareFeet;
    data['created_at'] = this.createdAt;
    data['whatsapp'] = this.whatsapp;
    data['phone'] = this.phone;
    data['price'] = this.price;
    data['payment_period'] = this.paymentPeriod;
    data['image'] = this.image;
    if (media != null) {
      data['media'] = media!.map((item) => item.toJson()).toList();
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
    if (json['links'] != null) {
      links = <MetaLinks>[];
      json['links'].forEach((v) {
        links!.add(new MetaLinks.fromJson(v));
      });
    }
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


class Media {
  String? originalUrl;

  Media({this.originalUrl});

  Media.fromJson(Map<String, dynamic> json) {
    originalUrl = json['original_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['original_url'] = this.originalUrl;
    return data;
  }
}
