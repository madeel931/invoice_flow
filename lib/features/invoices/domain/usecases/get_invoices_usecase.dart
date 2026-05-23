import 'package:dartz/dartz.dart' show Either;
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/invoice.dart';
import '../repositories/invoice_repository.dart';

class GetInvoicesUseCase implements UseCase<List<Invoice>, NoParams> {
  final InvoiceRepository repository;

  GetInvoicesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Invoice>>> call(NoParams params) async {
    return await repository.getInvoices();
  }
}
