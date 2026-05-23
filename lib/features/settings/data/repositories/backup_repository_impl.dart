import 'dart:io';
import 'package:dartz/dartz.dart' show Either, Left, Right, Unit, unit;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../../../core/data/local/local_database_service.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/backup_repository.dart';

class BackupRepositoryImpl implements BackupRepository {
  final LocalDatabaseService localDb;

  BackupRepositoryImpl({required this.localDb});

  @override
  Future<Either<Failure, String>> createBackup() async {
    try {
      final isar = localDb.db;

      final tempDir = await getTemporaryDirectory();
      final dateStr = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final backupPath =
          p.join(tempDir.path, 'InvoiceFlow_Backup_$dateStr.isar');

      await isar.copyToFile(backupPath);

      return Right(backupPath);
    } catch (e) {
      return Left(DatabaseFailure('Failed to create backup: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> restoreBackup(String backupFilePath) async {
    try {
      final backupFile = File(backupFilePath);

      if (!await backupFile.exists()) {
        return const Left(ValidationFailure('Backup file not found.'));
      }

      // 1. STRICT VALIDATION: Prevent app crashes from wrong file types
      if (!backupFile.path.toLowerCase().endsWith('.isar')) {
        return const Left(ValidationFailure(
            'Invalid format. Please select a valid .isar database file.'));
      }

      final appDir = await getApplicationDocumentsDirectory();
      final targetDbPath = p.join(appDir.path, 'invoice_flow_pro_db.isar');

      // 2. SAFETY BACKUP: Copy current DB to a recovery file just in case the imported file is corrupt
      final recoveryPath = p.join(appDir.path, 'recovery_db.isar');
      final currentDbFile = File(targetDbPath);
      if (await currentDbFile.exists()) {
        await currentDbFile.copy(recoveryPath);
      }

      // 3. RELEASE FILE LOCK: Close the active database connection completely
      await localDb.close();

      // 4. OVERWRITE: Replace the database physical file
      await backupFile.copy(targetDbPath);

      // We explicitly DO NOT call localDb.init() here. Re-initializing Isar in the same
      // active Dart isolate causes memory crashes. We will force a safe app restart in the UI.
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Failed to restore backup: $e'));
    }
  }
}
