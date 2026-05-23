import 'package:dartz/dartz.dart' show Either, Left;
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/invoice.dart';
import '../repositories/invoice_repository.dart';

class SaveInvoiceUseCase implements UseCase<Invoice, SaveInvoiceParams> {
  final InvoiceRepository repository;

  SaveInvoiceUseCase(this.repository);

  @override
  Future<Either<Failure, Invoice>> call(SaveInvoiceParams params) async {
    final inv = params.invoice;

    // Strict Domain Validation
    if (inv.items.isEmpty) {
      return const Left(
          ValidationFailure('An invoice must have at least one line item.'));
    }

    if (inv.dueDate.isBefore(inv.issueDate)) {
      return const Left(
          ValidationFailure('Due date cannot be before the issue date.'));
    }

    if (inv.discountAmount < 0) {
      return const Left(ValidationFailure('Discount cannot be negative.'));
    }

    if (inv.discountAmount > (inv.subtotal + inv.totalTax)) {
      return const Left(
          ValidationFailure('Discount cannot exceed the invoice total.'));
    }

    return await repository.saveInvoice(inv);
  }
}

class SaveInvoiceParams extends Equatable {
  final Invoice invoice;

  const SaveInvoiceParams({required this.invoice});

  @override
  List<Object> get props => [invoice];
}
