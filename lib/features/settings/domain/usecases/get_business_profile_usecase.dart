import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/business_profile.dart';
import '../repositories/settings_repository.dart';

class GetBusinessProfileUseCase implements UseCase<BusinessProfile, NoParams> {
  final SettingsRepository repository;

  GetBusinessProfileUseCase(this.repository);

  @override
  Future<Either<Failure, BusinessProfile>> call(NoParams params) async {
    return await repository.getBusinessProfile();
  }
}
