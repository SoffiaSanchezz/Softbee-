import 'package:Softbee/core/error/failures.dart';
import 'package:either_dart/either.dart';
// import 'package:sotfbee/core/error/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {}