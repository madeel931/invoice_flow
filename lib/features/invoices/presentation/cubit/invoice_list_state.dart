import 'package:equatable/equatable.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_status.dart';

enum InvoiceListStatus { initial, loading, loaded, error }

class InvoiceListState extends Equatable {
  final InvoiceListStatus status;
  final List<Invoice> allInvoices;
  final List<Invoice> filteredInvoices;
  final InvoiceStatus? filterStatus;
  final String searchQuery; // ADDED: For text search
  final String? errorMessage;

  const InvoiceListState({
    this.status = InvoiceListStatus.initial,
    this.allInvoices = const [],
    this.filteredInvoices = const [],
    this.filterStatus,
    this.searchQuery = '',
    this.errorMessage,
  });

  InvoiceListState copyWith({
    InvoiceListStatus? status,
    List<Invoice>? allInvoices,
    List<Invoice>? filteredInvoices,
    InvoiceStatus? filterStatus,
    String? searchQuery,
    String? errorMessage,
  }) {
    return InvoiceListState(
      status: status ?? this.status,
      allInvoices: allInvoices ?? this.allInvoices,
      filteredInvoices: filteredInvoices ?? this.filteredInvoices,
      filterStatus: filterStatus, // Allows null to clear filter
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allInvoices,
        filteredInvoices,
        filterStatus,
        searchQuery,
        errorMessage
      ];
}
