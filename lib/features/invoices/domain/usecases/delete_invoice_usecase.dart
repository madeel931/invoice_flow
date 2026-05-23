import 'package:dartz/dartz.dart' show Either, Unit;
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/invoice_repository.dart';

class DeleteInvoiceUseCase implements UseCase<Unit, DeleteInvoiceParams> {
  final InvoiceRepository repository;

  DeleteInvoiceUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(DeleteInvoiceParams params) async {
    return await repository.deleteInvoice(params.id);
  }
}

class DeleteInvoiceParams extends Equatable {
  final int id;

  const DeleteInvoiceParams({required this.id});

  @override
  List<Object> get props => [id];
}
