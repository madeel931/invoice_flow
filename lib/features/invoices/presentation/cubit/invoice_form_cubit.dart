import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_item.dart';
import '../../domain/entities/invoice_status.dart';
import '../../domain/usecases/get_next_invoice_number_usecase.dart';
import '../../domain/usecases/save_invoice_usecase.dart';
import 'invoice_form_state.dart';

class InvoiceFormCubit extends Cubit<InvoiceFormState> {
  final GetNextInvoiceNumberUseCase getNextInvoiceNumber;
  final SaveInvoiceUseCase saveInvoiceUseCase;

  InvoiceFormCubit({
    required this.getNextInvoiceNumber,
    required this.saveInvoiceUseCase,
  }) : super(const InvoiceFormState());

  Future<void> initForm([Invoice? existingInvoice]) async {
    emit(state.copyWith(status: InvoiceFormStatus.loading));

    if (existingInvoice != null) {
      emit(state.copyWith(
          status: InvoiceFormStatus.ready, draftInvoice: existingInvoice));
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
          dueDate: now.add(const Duration(days: 14)),
          items: const [],
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

  Future<void> saveInvoice(InvoiceStatus statusToSave) async {
    if (state.draftInvoice == null) return;

    // FIX: Removed the customerId == 0 block. Walk-in customers are now allowed!
    emit(state.copyWith(status: InvoiceFormStatus.saving));

    final finalInvoice = state.draftInvoice!.copyWith(status: statusToSave);
    final result =
        await saveInvoiceUseCase(SaveInvoiceParams(invoice: finalInvoice));

    result.fold(
      (failure) => emit(state.copyWith(
          status: InvoiceFormStatus.error, errorMessage: failure.message)),
      (savedInvoice) => emit(state.copyWith(
          status: InvoiceFormStatus.success, draftInvoice: savedInvoice)),
    );
  }
}
