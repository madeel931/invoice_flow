import 'package:dartz/dartz.dart' show Either;

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../invoices/domain/entities/invoice.dart';
import '../repositories/analytics_repository.dart';

class GetRecentInvoiceUseCase implements UseCase<Invoice?, NoParams> {
  final AnalyticsRepository repository;

  GetRecentInvoiceUseCase(this.repository);

  @override
  Future<Either<Failure, Invoice?>> call(NoParams params) async {
    return await repository.getRecentInvoice();
  }
}
