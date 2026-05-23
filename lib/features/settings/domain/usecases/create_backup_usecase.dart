import 'package:dartz/dartz.dart' show Either;
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/backup_repository.dart';

class CreateBackupUseCase implements UseCase<String, NoParams> {
  final BackupRepository repository;

  CreateBackupUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return await repository.createBackup();
  }
}
