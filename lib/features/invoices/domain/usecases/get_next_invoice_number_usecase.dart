import 'package:dartz/dartz.dart' show Either;
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/invoice_repository.dart';

class GetNextInvoiceNumberUseCase implements UseCase<String, NoParams> {
  final InvoiceRepository repository;

  GetNextInvoiceNumberUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return await repository.generateNextInvoiceNumber();
  }
}
