import 'package:dartz/dartz.dart' show Either, Left;
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/invoice.dart';
import '../services/invoice_calculator.dart';
import '../repositories/invoice_repository.dart';

/// Validates and saves an invoice to the local database.
/// Enforces domain-level business rules before persisting financial data.
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

    DateTime dateOnly(DateTime date) {
      return DateTime(date.year, date.month, date.day);
    }

    // Strip time components to compare calendar dates only. 
    // This allows invoices to be due on the exact same day they are issued.
    final dueOnly = dateOnly(inv.dueDate);
    final issueOnly = dateOnly(inv.issueDate);

    // Prevent illogical timelines (due dates cannot be in the past relative to issue date).
    if (dueOnly.isBefore(issueOnly)) {
      return const Left(
          ValidationFailure('Due date cannot be before issue date.'));
    }

    if (inv.discountAmount < 0) {
      return const Left(ValidationFailure('Discount cannot be negative.'));
    }

    final calc = InvoiceCalculator.calculate(inv);
    if (inv.discountType == 'amount' && inv.discountAmount > calc.subtotal) {
      return const Left(
          ValidationFailure('Discount cannot exceed the invoice subtotal.'));
    }
    if (inv.discountType == 'percentage' && inv.discountAmount > 100) {
      return const Left(
          ValidationFailure('Discount percentage cannot exceed 100%.'));
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
