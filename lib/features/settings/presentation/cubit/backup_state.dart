import 'package:equatable/equatable.dart';

enum BackupStatus { initial, processing, success, restoreSuccess, error }

class BackupState extends Equatable {
  final BackupStatus status;
  final String? backupFilePath;
  final String? errorMessage;

  const BackupState({
    this.status = BackupStatus.initial,
    this.backupFilePath,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, backupFilePath, errorMessage];
}
