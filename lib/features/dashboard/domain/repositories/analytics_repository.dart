import 'package:dartz/dartz.dart' show Either;
import '../../../../core/errors/failures.dart';
import '../entities/dashboard_metrics.dart';

abstract class AnalyticsRepository {
  /// Fetches and aggregates all invoice data into a single snapshot
  Future<Either<Failure, DashboardMetrics>> getDashboardMetrics();
}
