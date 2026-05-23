import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../settings/domain/usecases/get_business_profile_usecase.dart';
import '../../domain/usecases/get_dashboard_metrics_usecase.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final GetDashboardMetricsUseCase getMetrics;
  final GetBusinessProfileUseCase getProfile;

  DashboardCubit({
    required this.getMetrics,
    required this.getProfile,
  }) : super(const DashboardState());

  Future<void> loadDashboard() async {
    emit(state.copyWith(status: DashboardStatus.loading));

    // Concurrently fetch both required data sets to halve loading time
    final results = await Future.wait([
      getMetrics(NoParams()),
      getProfile(NoParams()),
    ]);

    final metricsResult = results[0] as dynamic; // Handled by Dartz Either
    final profileResult = results[1] as dynamic;

    // Check for errors in either request
    if (metricsResult.isLeft()) {
      final failure = metricsResult.fold((l) => l, (r) => null);
      emit(state.copyWith(
          status: DashboardStatus.error, errorMessage: failure.message));
      return;
    }

    if (profileResult.isLeft()) {
      final failure = profileResult.fold((l) => l, (r) => null);
      emit(state.copyWith(
          status: DashboardStatus.error, errorMessage: failure.message));
      return;
    }

    // Both succeeded
    final metrics = metricsResult.fold((l) => null, (r) => r);
    final profile = profileResult.fold((l) => null, (r) => r);

    emit(state.copyWith(
      status: DashboardStatus.loaded,
      metrics: metrics,
      profile: profile,
    ));
  }
}
