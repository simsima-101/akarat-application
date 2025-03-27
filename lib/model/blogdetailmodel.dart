class BlogDetailModel {
  Data? data;

  BlogDetailModel({this.data});

  BlogDetailModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
        ? new Translations.fromJson(json['translations'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['published_date'] = this.publishedDate;
    data['image'] = this.image;
    data['thumbnail'] = this.thumbnail;
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
  String? description;

  En({this.title, this.description});

  En.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['description'] = this.description;
    return data;
  }
}