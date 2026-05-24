import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../settings/domain/usecases/get_business_profile_usecase.dart';
import '../../domain/usecases/get_dashboard_metrics_usecase.dart';
import '../../../invoices/domain/usecases/get_invoices_usecase.dart'; // ADDED
import '../../../invoices/domain/entities/invoice.dart'; // ADDED
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final GetDashboardMetricsUseCase getMetrics;
  final GetBusinessProfileUseCase getProfile;
  final GetInvoicesUseCase getInvoices; // ADDED

  DashboardCubit({
    required this.getMetrics,
    required this.getProfile,
    required this.getInvoices, // ADDED
  }) : super(const DashboardState());

  Future<void> loadDashboard() async {
    emit(state.copyWith(status: DashboardStatus.loading));

    // Fetch all 3 data sets concurrently
    final results = await Future.wait([
      getMetrics(NoParams()),
      getProfile(NoParams()),
      getInvoices(NoParams()),
    ]);

    final metricsResult = results[0] as dynamic;
    final profileResult = results[1] as dynamic;
    final invoicesResult = results[2] as dynamic;

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
    invoicesResult.fold((l) => null, (invoices) {
      if (invoices.isNotEmpty) {
        // Sort by issue date descending (newest first)
        final sortedList = List<Invoice>.from(invoices)
          ..sort((a, b) => b.issueDate.compareTo(a.issueDate));
        recent = sortedList.first;
      }
    });

    emit(state.copyWith(
      status: DashboardStatus.loaded,
      metrics: metrics,
      profile: profile,
      recentInvoice: recent,
    ));
  }
}
