class Apiary {
  final String id;
  final String userId;
  final String name;
  final String? location;
  final int beehivesCount;
  final bool treatments;
  final DateTime? createdAt;

  Apiary({
    required this.id,
    required this.userId,
    required this.name,
    this.location,
    required this.beehivesCount,
    required this.treatments,
    this.createdAt,
  });

  factory Apiary.fromJson(Map<String, dynamic> json) {
    return Apiary(
      id: json['id'].toString(),
      userId: json['user_id'],
      name: json['name'],
      location: json['location'],
      beehivesCount: json['beehives_count'] ?? 0,
      treatments: json['treatments'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}
