class User {
  final String id;
  final String email;
  final String username;
  final bool isVerified;
  final bool isActive;

  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.isVerified,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      isVerified: json['is_verified'] ?? false,
      isActive: json['is_active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'is_verified': isVerified,
      'is_active': isActive,
    };
  }
}