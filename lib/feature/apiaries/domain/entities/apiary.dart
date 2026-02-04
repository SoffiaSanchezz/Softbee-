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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'location': location,
      'beehives_count': beehivesCount,
      'treatments': treatments,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Apiary copyWith({
    String? id,
    String? userId,
    String? name,
    String? location,
    int? beehivesCount,
    bool? treatments,
    DateTime? createdAt,
  }) {
    return Apiary(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      location: location ?? this.location,
      beehivesCount: beehivesCount ?? this.beehivesCount,
      treatments: treatments ?? this.treatments,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

