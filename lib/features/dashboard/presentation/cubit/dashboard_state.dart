import 'package:equatable/equatable.dart';
import '../../../settings/domain/entities/business_profile.dart';
import '../../domain/entities/dashboard_metrics.dart';

enum DashboardStatus { initial, loading, loaded, error }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final DashboardMetrics? metrics;
  final BusinessProfile? profile;
  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.metrics,
    this.profile,
    this.errorMessage,
  });

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardMetrics? metrics,
    BusinessProfile? profile,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      metrics: metrics ?? this.metrics,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, metrics, profile, errorMessage];
}
