import 'package:equatable/equatable.dart';

class ApiaryInsights extends Equatable {
  final int totalBeehives;
  final int activeTreatments;
  final double avgHealthScore;
  final int lowStockItems;
  final DateTime lastUpdated;
  final List<HealthDataPoint> healthHistory;

  const ApiaryInsights({
    required this.totalBeehives,
    required this.activeTreatments,
    required this.avgHealthScore,
    required this.lowStockItems,
    required this.lastUpdated,
    required this.healthHistory,
  });

  factory ApiaryInsights.fromJson(Map<String, dynamic> json, List<dynamic> historyJson) {
    return ApiaryInsights(
      totalBeehives: json['total_beehives'] ?? 0,
      activeTreatments: json['active_treatments'] ?? 0,
      avgHealthScore: (json['avg_health_score'] as num?)?.toDouble() ?? 0.0,
      lowStockItems: json['low_stock_items'] ?? 0,
      lastUpdated: json['last_updated'] != null 
          ? DateTime.parse(json['last_updated']) 
          : DateTime.now(),
      healthHistory: historyJson.map((e) => HealthDataPoint.fromJson(e)).toList(),
    );
  }

  @override
  List<Object?> get props => [totalBeehives, activeTreatments, avgHealthScore, lowStockItems, healthHistory];
}

class HealthDataPoint extends Equatable {
  final DateTime date;
  final double score;

  const HealthDataPoint({required this.date, required this.score});

  factory HealthDataPoint.fromJson(Map<String, dynamic> json) {
    return HealthDataPoint(
      date: DateTime.parse(json['date']),
      score: (json['avg_score'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [date, score];
}
