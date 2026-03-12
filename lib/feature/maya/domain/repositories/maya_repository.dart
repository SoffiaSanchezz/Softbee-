import 'package:either_dart/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat_message.dart';

abstract class MayaRepository {
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String prompt,
    String? sessionId,
    String agentId = 'general',
    String provider = 'gemini',
    Map<String, dynamic>? context,
  });
}
