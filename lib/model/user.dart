// lib/models/user.dart
class User {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String? image;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.image,
  });

  factory User.fromJson(Map<String, dynamic> m) {
    return User(
      id: int.tryParse('${m['id']}') ?? 0,
      email: (m['email'] ?? '').toString(),
      firstName: (m['first_name'] ?? m['firstName'] ?? '').toString(),
      lastName:  (m['last_name']  ?? m['lastName']  ?? '').toString(),
      image: (m['image'] ?? m['avatar'] ?? '').toString().trim().isEmpty
          ? null
          : (m['image'] ?? m['avatar']).toString(),
    );
  }
}
