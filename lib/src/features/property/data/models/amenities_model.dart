class Amenities {
  final int? id;
  final String title; // single title from backend
  final String? icon;

  Amenities({
    this.id,
    required this.title,
    this.icon,
  });

  /// Parse JSON from API
  factory Amenities.fromJson(Map<String, dynamic> json) {
    return Amenities(
      id: json['id'] as int?,
      title: (json['title'] as String?)?.trim() ?? '',
      icon: (json['icon'] as String?)?.trim(),
    );
  }

  /// Get title (for backward compatibility, just return title)
  String getTitle(String lang) {
    return title;
  }

  @override
  String toString() {
    return 'Amenities(id: $id, title: "$title", icon: $icon)';
  }
}
