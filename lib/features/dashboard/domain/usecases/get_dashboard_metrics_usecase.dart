import 'package:dartz/dartz.dart' show Either;
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/dashboard_metrics.dart';
import '../repositories/analytics_repository.dart';

class GetDashboardMetricsUseCase
    implements UseCase<DashboardMetrics, NoParams> {
  final AnalyticsRepository repository;

  GetDashboardMetricsUseCase(this.repository);

  @override
  Future<Either<Failure, DashboardMetrics>> call(NoParams params) async {
    return await repository.getDashboardMetrics();
  }
}
