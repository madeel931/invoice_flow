import 'package:dartz/dartz.dart' show Either, Unit;
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/backup_repository.dart';

class RestoreBackupUseCase implements UseCase<Unit, RestoreBackupParams> {
  final BackupRepository repository;

  RestoreBackupUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(RestoreBackupParams params) async {
    return await repository.restoreBackup(params.filePath);
  }
}

class RestoreBackupParams extends Equatable {
  final String filePath;

  const RestoreBackupParams({required this.filePath});

  @override
  List<Object> get props => [filePath];
}
