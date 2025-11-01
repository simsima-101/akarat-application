class BlogDetailModel {
  Data? data;

  BlogDetailModel({this.data});

  BlogDetailModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  String? publishedDate;
  String? image;
  String? thumbnail;
  String? readingTime;
  Translations? translations;

  Data(
      {this.id,
        this.publishedDate,
        this.image,
        this.thumbnail,
        this.readingTime,
        this.translations});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    publishedDate = json['published_date'];
    image = json['image'];
    thumbnail = json['thumbnail'];
    readingTime = json['reading_time'];
    translations = json['translations'] != null
        ? Translations.fromJson(json['translations'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['published_date'] = publishedDate;
    data['image'] = image;
    data['thumbnail'] = thumbnail;
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

  Translations.fromJson(Map<String, dynamic> json) {
    en = json['en'] != null ? En.fromJson(json['en']) : null;
    ar = json['ar'] != null ? En.fromJson(json['ar']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (en != null) {
      data['en'] = en!.toJson();
    }
    if (ar != null) {
      data['ar'] = ar!.toJson();
    }
    return data;
  }
}

class En {
  String? title;
  String? description;

  En({this.title, this.description});

  En.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['description'] = description;
    return data;
  }
}