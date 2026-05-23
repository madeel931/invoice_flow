import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/onboarding_repository.dart';

class CompleteOnboardingUseCase
    implements UseCase<Unit, CompleteOnboardingParams> {
  final OnboardingRepository repository;

  CompleteOnboardingUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(CompleteOnboardingParams params) async {
    // Domain validation before hitting the repository
    if (params.businessName.trim().isEmpty) {
      return const Left(ValidationFailure('Business name cannot be empty.'));
    }
    if (params.currencyCode.isEmpty) {
      return const Left(ValidationFailure('Please select a base currency.'));
    }

    return await repository.completeSetup(
      businessName: params.businessName.trim(),
      currencyCode: params.currencyCode,
    );
  }
}

class CompleteOnboardingParams extends Equatable {
  final String businessName;
  final String currencyCode;

  const CompleteOnboardingParams({
    required this.businessName,
    required this.currencyCode,
  });

  @override
  List<Object> get props => [businessName, currencyCode];
}
