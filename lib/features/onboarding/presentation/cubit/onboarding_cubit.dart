import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/complete_onboarding_usecase.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final CompleteOnboardingUseCase completeOnboarding;

  OnboardingCubit({required this.completeOnboarding})
      : super(OnboardingInitial());

  Future<void> submitSetup({
    required String businessName,
    required String currencyCode,
  }) async {
    emit(OnboardingLoading());

    final params = CompleteOnboardingParams(
      businessName: businessName,
      currencyCode: currencyCode,
    );

    final result = await completeOnboarding(params);

    result.fold(
      (failure) => emit(OnboardingFailure(failure.message)),
      (_) => emit(OnboardingSuccess()),
    );
  }
}
