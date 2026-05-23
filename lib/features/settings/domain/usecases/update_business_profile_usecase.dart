import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/business_profile.dart';
import '../repositories/settings_repository.dart';

class UpdateBusinessProfileUseCase
    implements UseCase<BusinessProfile, UpdateBusinessProfileParams> {
  final SettingsRepository repository;

  UpdateBusinessProfileUseCase(this.repository);

  @override
  Future<Either<Failure, BusinessProfile>> call(
      UpdateBusinessProfileParams params) async {
    // Perform domain-level validation (e.g., prevent empty business names)
    if (params.profile.businessName.trim().isEmpty) {
      return const Left(ValidationFailure('Business name cannot be empty.'));
    }

    // We could add deeper validation here in the future (e.g., RegEx for Tax IDs)

    return await repository.updateBusinessProfile(params.profile);
  }
}

class UpdateBusinessProfileParams extends Equatable {
  final BusinessProfile profile;

  const UpdateBusinessProfileParams({required this.profile});

  @override
  List<Object> get props => [profile];
}
