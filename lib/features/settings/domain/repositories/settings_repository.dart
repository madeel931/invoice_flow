import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/business_profile.dart';

abstract class SettingsRepository {
  /// Retrieves the current business profile.
  Future<Either<Failure, BusinessProfile>> getBusinessProfile();

  /// Updates the business profile and returns the updated entity.
  Future<Either<Failure, BusinessProfile>> updateBusinessProfile(
      BusinessProfile profile);
}
