import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_status.dart';
import '../../domain/usecases/get_invoices_usecase.dart';
import '../../domain/usecases/delete_invoice_usecase.dart';
import '../../domain/usecases/get_next_invoice_number_usecase.dart';
import '../../domain/usecases/save_invoice_usecase.dart';
import 'invoice_list_state.dart';

class InvoiceListCubit extends Cubit<InvoiceListState> {
  final GetInvoicesUseCase getInvoices;
  final DeleteInvoiceUseCase deleteInvoice;
  final GetNextInvoiceNumberUseCase getNextNumber;
  final SaveInvoiceUseCase saveInvoice;

  InvoiceListCubit({
    required this.getInvoices,
    required this.deleteInvoice,
    required this.getNextNumber,
    required this.saveInvoice,
  }) : super(const InvoiceListState());

  Future<void> loadInvoices() async {
    emit(state.copyWith(status: InvoiceListStatus.loading));
    final result = await getInvoices(NoParams());
    result.fold(
      (f) => emit(state.copyWith(
          status: InvoiceListStatus.error, errorMessage: f.message)),
      (invoices) => emit(state.copyWith(
        status: InvoiceListStatus.loaded,
        allInvoices: invoices,
        filteredInvoices:
            _applyFilter(invoices, state.filterStatus, state.searchQuery),
      )),
    );
  }

  void filterByStatus(InvoiceStatus? status) {
    emit(state.copyWith(
      filterStatus: status,
      filteredInvoices:
          _applyFilter(state.allInvoices, status, state.searchQuery),
    ));
  }

  void search(String query) {
    emit(state.copyWith(
      searchQuery: query,
      filteredInvoices:
          _applyFilter(state.allInvoices, state.filterStatus, query),
    ));
  }

  List<Invoice> _applyFilter(
      List<Invoice> list, InvoiceStatus? status, String query) {
    var filtered = list;

    // 1. Apply Status Filter
    if (status != null) {
      filtered = filtered.where((i) => i.status == status).toList();
    }

    // 2. Apply Text Search (Invoice Number or Customer Name)
    if (query.trim().isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      filtered = filtered
          .where((i) =>
              i.invoiceNumber.toLowerCase().contains(lowerQuery) ||
              i.customerName.toLowerCase().contains(lowerQuery))
          .toList();
    }

    return filtered;
  }

  // ADDED: Instantly update invoice status
  Future<void> updateStatus(Invoice invoice, InvoiceStatus newStatus) async {
    final updatedInvoice = invoice.copyWith(status: newStatus);
    final result =
        await saveInvoice(SaveInvoiceParams(invoice: updatedInvoice));

    result.fold(
      (f) => emit(state.copyWith(
          status: InvoiceListStatus.error, errorMessage: f.message)),
      (_) => loadInvoices(), // Refresh the list from memory after saving
    );
  }

  Future<void> duplicateInvoice(Invoice invoice) async {
    final numberResult = await getNextNumber(NoParams());
    numberResult.fold(
      (f) => emit(state.copyWith(errorMessage: f.message)),
      (newNumber) async {
        final duplicated = invoice.copyWith(
          id: null,
          invoiceNumber: newNumber,
          issueDate: DateTime.now(),
          dueDate: DateTime.now().add(const Duration(days: 14)),
          status: InvoiceStatus.draft,
          createdAt: DateTime.now(),
        );

        await saveInvoice(SaveInvoiceParams(invoice: duplicated));
        await loadInvoices();
      },
    );
  }

  Future<void> delete(int id) async {
    await deleteInvoice(DeleteInvoiceParams(id: id));
    await loadInvoices();
  }
}
