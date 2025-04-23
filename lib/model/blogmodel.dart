class BlogResponseModel {
  bool? success;
  String? message;
  BlogPaginatedData? data;

  BlogResponseModel({this.success, this.message, this.data});

  factory BlogResponseModel.fromJson(Map<String, dynamic> json) {
    return BlogResponseModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? BlogPaginatedData.fromJson(json['data']) : null,
    );
  }
}

class BlogPaginatedData {
  List<BlogModel>? data;
  Links? links;
  Meta? meta;

  BlogPaginatedData({this.data, this.links, this.meta});

  factory BlogPaginatedData.fromJson(Map<String, dynamic> json) {
    return BlogPaginatedData(
      data: (json['data'] as List?)?.map((e) => BlogModel.fromJson(e)).toList(),
      links: json['links'] != null ? Links.fromJson(json['links']) : null,
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
    );
  }
}


class Data {
  List<Data>? data;
  Links? links;
  Meta? meta;

  Data({this.data, this.links, this.meta});

  Data.fromJson(Map<String, dynamic> json) {
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

class BlogModel {
  int? id;
  String? publishedDate;
  String? image;
  String? readingTime;
  Translations? translations;

  BlogModel(
      {this.id,
        this.publishedDate,
        this.image,
        this.readingTime,
        this.translations});

  BlogModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    publishedDate = json['published_date'];
    image = json['image'];
    readingTime = json['reading_time'];
    translations = json['translations'] != null
        ? new Translations.fromJson(json['translations'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['published_date'] = this.publishedDate;
    data['image'] = this.image;
    data['reading_time'] = this.readingTime;
    if (this.translations != null) {
      data['translations'] = this.translations!.toJson();
    }
    return data;
  }
}

class Translations {
  En? en;
  En? ar;

  Translations({this.en, this.ar});

  Translations.fromJson(Map<String, dynamic> json) {
    en = json['en'] != null ? new En.fromJson(json['en']) : null;
    ar = json['ar'] != null ? new En.fromJson(json['ar']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.en != null) {
      data['en'] = this.en!.toJson();
    }
    if (this.ar != null) {
      data['ar'] = this.ar!.toJson();
    }
    return data;
  }
}

class En {
  String? title;

  En({this.title});

  En.fromJson(Map<String, dynamic> json) {
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
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
    label = json['label'];
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