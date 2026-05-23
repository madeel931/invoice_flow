import 'package:equatable/equatable.dart';
import '../../domain/entities/business_profile.dart';

enum SettingsStatus { initial, loading, loaded, saving, success, error }

class SettingsState extends Equatable {
  final SettingsStatus status;
  final BusinessProfile? profile;
  final String? errorMessage;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.profile,
    this.errorMessage,
  });

  SettingsState copyWith({
    SettingsStatus? status,
    BusinessProfile? profile,
    String? errorMessage,
  }) {
    return SettingsState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage, // Intentionally nullable to clear errors
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage];
}
