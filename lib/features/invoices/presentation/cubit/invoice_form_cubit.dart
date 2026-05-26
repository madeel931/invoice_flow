import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_item.dart';
import '../../domain/entities/invoice_status.dart';
import '../../domain/usecases/get_next_invoice_number_usecase.dart';
import '../../domain/usecases/save_invoice_usecase.dart';
import '../../domain/services/invoice_calculator.dart';
import 'package:get_it/get_it.dart';
import '../../domain/usecases/get_invoices_usecase.dart';
import 'invoice_form_state.dart';

class InvoiceFormCubit extends Cubit<InvoiceFormState> {
  final GetNextInvoiceNumberUseCase getNextInvoiceNumber;
  final SaveInvoiceUseCase saveInvoiceUseCase;

  InvoiceFormCubit({
    required this.getNextInvoiceNumber,
    required this.saveInvoiceUseCase,
  }) : super(const InvoiceFormState());

  Future<void> initForm({String? defaultCurrencyCode, String? existingInvoiceId}) async {
    emit(state.copyWith(status: InvoiceFormStatus.loading));

    if (existingInvoiceId != null) {
      final getInvoices = GetIt.instance<GetInvoicesUseCase>();
      final result = await getInvoices(NoParams());
      
      result.fold(
        (failure) => emit(state.copyWith(
            status: InvoiceFormStatus.error, errorMessage: failure.message)),
        (invoices) {
          try {
            final existingInvoice = invoices.firstWhere(
                (i) => i.id?.toString() == existingInvoiceId);
            
            final resolvedCurrencyCode =
                existingInvoice.currencyCode?.trim().isNotEmpty == true
                    ? existingInvoice.currencyCode
                    : defaultCurrencyCode;

            final updatedInvoice = existingInvoice.copyWith(currencyCode: resolvedCurrencyCode);

            emit(state.copyWith(
                status: InvoiceFormStatus.ready, draftInvoice: updatedInvoice));
          } catch (_) {
            emit(state.copyWith(
                status: InvoiceFormStatus.error, errorMessage: "Invoice not found"));
          }
        },
      );
      return;
    }

    final numberResult = await getNextInvoiceNumber(NoParams());

    numberResult.fold(
      (failure) => emit(state.copyWith(
          status: InvoiceFormStatus.error, errorMessage: failure.message)),
      (nextNumber) {
        final now = DateTime.now();
        final newInvoice = Invoice(
          invoiceNumber: nextNumber,
          customerId: 0,
          customerName: 'Walk-in Customer', // FIX: Default to Walk-in
          issueDate: now,
          dueDate: now,
          items: const [],
          currencyCode: defaultCurrencyCode?.trim().isNotEmpty == true 
              ? defaultCurrencyCode!.trim().toUpperCase() 
              : 'USD',
        );

        emit(state.copyWith(
            status: InvoiceFormStatus.ready, draftInvoice: newInvoice));
      },
    );
  }

  void updateCustomer(Customer customer) {
    if (state.draftInvoice == null) return;
    final updated = state.draftInvoice!.copyWith(
      customerId: customer.id ?? 0,
      customerName: customer.name,
    );
    emit(state.copyWith(draftInvoice: updated));
  }

  void addLineItem(InvoiceItem item) {
    if (state.draftInvoice == null) return;
    final currentItems = List<InvoiceItem>.from(state.draftInvoice!.items);
    currentItems.add(item);
    emit(state.copyWith(
        draftInvoice: state.draftInvoice!.copyWith(items: currentItems)));
  }

  void updateLineItem(int index, InvoiceItem updatedItem) {
    if (state.draftInvoice == null) return;
    final currentItems = List<InvoiceItem>.from(state.draftInvoice!.items);
    if (index >= 0 && index < currentItems.length) {
      currentItems[index] = updatedItem;
      emit(state.copyWith(
          draftInvoice: state.draftInvoice!.copyWith(items: currentItems)));
    }
  }

  void removeLineItem(int index) {
    if (state.draftInvoice == null) return;
    final currentItems = List<InvoiceItem>.from(state.draftInvoice!.items);
    if (index >= 0 && index < currentItems.length) {
      currentItems.removeAt(index);
      emit(state.copyWith(
          draftInvoice: state.draftInvoice!.copyWith(items: currentItems)));
    }
  }

  void updateDiscount(double discountAmount) {
    if (state.draftInvoice == null) return;
    emit(state.copyWith(
        draftInvoice:
            state.draftInvoice!.copyWith(discountAmount: discountAmount)));
  }

  void updateDiscountType(String discountType) {
    if (state.draftInvoice == null) return;
    emit(state.copyWith(
        draftInvoice:
            state.draftInvoice!.copyWith(discountType: discountType)));
  }

  void updatePaidAmount(double paidAmount) {
    if (state.draftInvoice == null) return;
    emit(state.copyWith(
        draftInvoice: state.draftInvoice!.copyWith(paidAmount: paidAmount)));
  }

  void updateDates({DateTime? issueDate, DateTime? dueDate}) {
    if (state.draftInvoice == null) return;
    final updated = state.draftInvoice!.copyWith(
      issueDate: issueDate ?? state.draftInvoice!.issueDate,
      dueDate: dueDate ?? state.draftInvoice!.dueDate,
    );
    emit(state.copyWith(draftInvoice: updated));
  }

  void updateNotes(String notes) {
    if (state.draftInvoice == null) return;
    emit(state.copyWith(
        draftInvoice: state.draftInvoice!.copyWith(notes: notes)));
  }

  Future<void> saveDraft() async {
    if (state.draftInvoice == null) return;

    emit(state.copyWith(status: InvoiceFormStatus.saving));

    final finalInvoice = state.draftInvoice!.copyWith(status: InvoiceStatus.draft);
    final result = await saveInvoiceUseCase(SaveInvoiceParams(invoice: finalInvoice));

    result.fold(
      (failure) => emit(state.copyWith(
          status: InvoiceFormStatus.error, errorMessage: failure.message)),
      (savedInvoice) => emit(state.copyWith(
          status: InvoiceFormStatus.success, draftInvoice: savedInvoice)),
    );
  }

  Future<void> saveIssuedInvoice() async {
    if (state.draftInvoice == null) return;

    if (state.draftInvoice!.status == InvoiceStatus.cancelled) {
      emit(state.copyWith(
          status: InvoiceFormStatus.error, errorMessage: "Cannot issue a cancelled invoice."));
      return;
    }

    emit(state.copyWith(status: InvoiceFormStatus.saving));

    const normalizedStatus = InvoiceStatus.unpaid;

    final calc = InvoiceCalculator.calculate(state.draftInvoice!);
    final resolvedStatus = InvoiceCalculator.resolveStatus(
      currentStatus: normalizedStatus,
      dueDate: state.draftInvoice!.dueDate,
      grandTotal: calc.grandTotal,
      paidAmount: calc.paidAmount,
      balanceDue: calc.balanceDue,
    );

    final finalInvoice = state.draftInvoice!.copyWith(status: resolvedStatus);
    final result = await saveInvoiceUseCase(SaveInvoiceParams(invoice: finalInvoice));

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: InvoiceFormStatus.error, errorMessage: failure.message));
      },
      (savedInvoice) {
        emit(state.copyWith(
          status: InvoiceFormStatus.success, draftInvoice: savedInvoice));
      },
    );
  }
}
