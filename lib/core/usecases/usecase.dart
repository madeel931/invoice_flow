import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../errors/failures.dart';

/// Type = The expected return type (e.g., Invoice Entity)
/// Params = The required parameters to execute the use case
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use this when a use case doesn't require any parameters
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
