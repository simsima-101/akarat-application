class Language {
  List<String>? languages;

  Language({this.languages});

  Language.fromJson(Map<String, dynamic> json) {
    languages = json['languages'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['languages'] = languages;
    return data;
  }
}