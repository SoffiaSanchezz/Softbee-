import 'package:equatable/equatable.dart';

class HiveAnswer extends Equatable {
  final String id;
  final String hiveQuestionId;
  final String answer;
  final int score;
  final String? answeredBy;
  final DateTime? answeredAt;

  const HiveAnswer({
    required this.id,
    required this.hiveQuestionId,
    required this.answer,
    this.score = 0,
    this.answeredBy,
    this.answeredAt,
  });

  factory HiveAnswer.fromJson(Map<String, dynamic> json) {
    return HiveAnswer(
      id: json['id']?.toString() ?? '',
      hiveQuestionId: json['hive_question_id']?.toString() ?? '',
      answer: json['answer']?.toString() ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      answeredBy: json['answered_by']?.toString(),
      answeredAt: json['answered_at'] != null
          ? DateTime.parse(json['answered_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'hive_question_id': hiveQuestionId,
      'answer': answer,
      'score': score,
      if (answeredBy != null) 'answered_by': answeredBy,
      if (answeredAt != null) 'answered_at': answeredAt!.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        hiveQuestionId,
        answer,
        score,
        answeredBy,
        answeredAt,
      ];
}
