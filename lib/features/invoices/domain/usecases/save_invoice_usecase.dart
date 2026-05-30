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
    if (inv.invoiceNumber.trim().isEmpty || inv.invoiceNumber.trim().length > 40) {
      return const Left(ValidationFailure('err_invoice_number_required'));
    }

    final existingInvoiceResult = await repository.getInvoiceByNumber(inv.invoiceNumber);
    if (existingInvoiceResult.isRight()) {
      final existingInvoice = existingInvoiceResult.getOrElse(() => null);
      if (existingInvoice != null && existingInvoice.id != inv.id) {
        return const Left(ValidationFailure('err_invoice_number_exists'));
      }
    }

    if (inv.items.isEmpty) {
      return const Left(
          ValidationFailure('err_no_items'));
    }

    for (final item in inv.items) {
      if (item.description.trim().isEmpty || item.description.trim().length > 120) {
        return const Left(ValidationFailure('err_item_desc_invalid'));
      }
      if (item.quantity <= 0 || item.quantity > 999999) {
        return const Left(ValidationFailure('err_item_qty_invalid'));
      }
      if (item.unitPrice < 0 || item.unitPrice > 999999999) {
        return const Left(ValidationFailure('err_item_price_invalid'));
      }
      if (item.taxRate < 0 || item.taxRate > 100) {
        return const Left(ValidationFailure('err_item_tax_invalid'));
      }
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
          ValidationFailure('err_due_date_invalid'));
    }

    if (inv.discountAmount < 0) {
      return const Left(ValidationFailure('err_discount_negative'));
    }

    final calc = InvoiceCalculator.calculate(inv);
    if (inv.discountType == 'amount' && inv.discountAmount > calc.subtotal) {
      return const Left(
          ValidationFailure('err_discount_exceeds_subtotal'));
    }
    if (inv.discountType == 'percentage' && inv.discountAmount > 100) {
      return const Left(
          ValidationFailure('err_discount_exceeds_100'));
    }

    if (inv.paidAmount < 0) {
      return const Left(ValidationFailure('err_paid_amount_negative'));
    }
    if (inv.paidAmount > calc.grandTotal) {
      return const Left(ValidationFailure('err_paid_amount_exceeds_total'));
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
