class Language {
  List<String>? languages;

  Language({this.languages});

  Language.fromJson(Map<String, dynamic> json) {
    languages = json['languages'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['languages'] = this.languages;
    return data;
  }
}