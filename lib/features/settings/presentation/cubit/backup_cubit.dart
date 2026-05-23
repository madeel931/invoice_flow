import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/create_backup_usecase.dart';
import '../../domain/usecases/restore_backup_usecase.dart';
import 'backup_state.dart';

class BackupCubit extends Cubit<BackupState> {
  final CreateBackupUseCase createBackup;
  final RestoreBackupUseCase restoreBackup;

  BackupCubit({
    required this.createBackup,
    required this.restoreBackup,
  }) : super(const BackupState());

  Future<void> exportData() async {
    emit(const BackupState(status: BackupStatus.processing));

    final result = await createBackup(NoParams());

    result.fold(
      (failure) => emit(BackupState(
          status: BackupStatus.error, errorMessage: failure.message)),
      (filePath) => emit(
          BackupState(status: BackupStatus.success, backupFilePath: filePath)),
    );
  }

  Future<void> importData(String filePath) async {
    emit(const BackupState(status: BackupStatus.processing));

    final result = await restoreBackup(RestoreBackupParams(filePath: filePath));

    result.fold(
      (failure) => emit(BackupState(
          status: BackupStatus.error, errorMessage: failure.message)),
      (_) => emit(const BackupState(status: BackupStatus.restoreSuccess)),
    );
  }
}
