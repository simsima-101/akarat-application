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

class BlogPaginatedData {
  List<BlogModel>? data;
  Links? links;
  Meta? meta;

  BlogPaginatedData({this.data, this.links, this.meta});

  factory BlogPaginatedData.fromJson(Map<String, dynamic> json) {
    return BlogPaginatedData(
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => BlogModel.fromJson(e))
          .toList(),
      links: json['links'] != null ? Links.fromJson(json['links']) : null,
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
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
  final int? id;
  final String? publishedDate;
  final String? image;
  final String? readingTime;
  final Translations? translations;

  BlogModel({
    this.id,
    this.publishedDate,
    this.image,
    this.readingTime,
    this.translations,
  });

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    return BlogModel(
      id: json['id'],
      publishedDate: json['published_date'],
      image: json['image'],
      readingTime: json['reading_time'],
      translations: json['translations'] != null
          ? Translations.fromJson(json['translations'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['published_date'] = publishedDate;
    data['image'] = image;
    data['reading_time'] = readingTime;
    if (translations != null) {
      data['translations'] = translations!.toJson();
    }
    return data;
  }
}

class Translations {
  En? en;
  En? ar;

  Translations({this.en, this.ar});

  factory Translations.fromJson(Map<String, dynamic> json) {
    return Translations(
      en: json['en'] != null ? En.fromJson(json['en']) : null,
      ar: json['ar'] != null ? En.fromJson(json['ar']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (en != null) data['en'] = en!.toJson();
    if (ar != null) data['ar'] = ar!.toJson();
    return data;
  }
}

class En {
  String? title;

  En({this.title});

  factory En.fromJson(Map<String, dynamic> json) {
    return En(title: json['title']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['title'] = title;
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

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      currentPage: json['current_page'],
      from: json['from'],
      lastPage: json['last_page'],
      links: json['links'] != null
          ? (json['links'] as List<dynamic>)
          .map((e) => MetaLinks.fromJson(e))
          .toList()
          : null,
      path: json['path'],
      perPage: json['per_page'],
      to: json['to'],
      total: json['total'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['current_page'] = currentPage;
    data['from'] = from;
    data['last_page'] = lastPage;
    if (links != null) {
      data['links'] = links!.map((e) => e.toJson()).toList();
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

  factory MetaLinks.fromJson(Map<String, dynamic> json) {
    return MetaLinks(
      url: json['url'],
      label: json['label'],
      active: json['active'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['url'] = url;
    data['label'] = label;
    data['active'] = active;
    return data;
  }
}
