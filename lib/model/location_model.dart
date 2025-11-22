class LocationModel {
  final int? id;
  final String? slug;
  final String? country;
  final String? location;
  final int? emirateId;

  LocationModel(
      {this.id, this.slug, this.country, this.location, this.emirateId});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'country': country,
      'location': location,
      'emirate_id': emirateId,
    };
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'],
      slug: json['slug'],
      country: json['country'],
      location: json['location'],
      emirateId: json['emirate_id'],
    );
  }
}
