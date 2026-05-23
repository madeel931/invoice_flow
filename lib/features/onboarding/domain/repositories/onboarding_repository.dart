import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class OnboardingRepository {
  Future<Either<Failure, Unit>> completeSetup({
    required String businessName,
    required String currencyCode,
  });
}
