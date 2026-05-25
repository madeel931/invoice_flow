import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../settings/domain/usecases/get_business_profile_usecase.dart';
import '../../domain/usecases/get_dashboard_metrics_usecase.dart';
import '../../domain/usecases/get_recent_invoice_usecase.dart'; // ADDED
import '../../../invoices/domain/entities/invoice.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final GetDashboardMetricsUseCase getMetrics;
  final GetBusinessProfileUseCase getProfile;
  final GetRecentInvoiceUseCase getRecentInvoice; // ADDED

  DashboardCubit({
    required this.getMetrics,
    required this.getProfile,
    required this.getRecentInvoice, // ADDED
  }) : super(const DashboardState());

  Future<void> loadDashboard() async {
    emit(state.copyWith(status: DashboardStatus.loading));

    // Fetch all 3 data sets concurrently
    final results = await Future.wait([
      getMetrics(NoParams()),
      getProfile(NoParams()),
      getRecentInvoice(NoParams()),
    ]);

    final metricsResult = results[0] as dynamic;
    final profileResult = results[1] as dynamic;
    final recentResult = results[2] as dynamic;

    if (metricsResult.isLeft() || profileResult.isLeft()) {
      emit(state.copyWith(
          status: DashboardStatus.error,
          errorMessage: 'Failed to load dashboard data.'));
      return;
    }

    final metrics = metricsResult.fold((l) => null, (r) => r);
    final profile = profileResult.fold((l) => null, (r) => r);

    // EXTRACT RECENT INVOICE
    Invoice? recent;
    recentResult.fold((l) => null, (r) {
      recent = r;
    });

    emit(state.copyWith(
      status: DashboardStatus.loaded,
      metrics: metrics,
      profile: profile,
      recentInvoice: recent,
    ));
  }
}
