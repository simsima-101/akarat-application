class Nationality {
  List<String>? nationalities;

  Nationality({this.nationalities});

  Nationality.fromJson(Map<String, dynamic> json) {
    nationalities = json['nationalities'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nationalities'] = this.nationalities;
    return data;
  }
}