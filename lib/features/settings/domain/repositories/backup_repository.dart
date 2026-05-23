import 'package:dartz/dartz.dart' show Either, Unit;
import '../../../../core/errors/failures.dart';

abstract class BackupRepository {
  /// Creates a backup and returns the temporary file path of the backup.
  Future<Either<Failure, String>> createBackup();

  /// Takes a selected file path and restores it as the active database.
  Future<Either<Failure, Unit>> restoreBackup(String backupFilePath);
}
