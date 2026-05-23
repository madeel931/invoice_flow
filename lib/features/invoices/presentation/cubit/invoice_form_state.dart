import 'package:equatable/equatable.dart';
import '../../domain/entities/invoice.dart';

enum InvoiceFormStatus { initial, loading, ready, saving, success, error }

class InvoiceFormState extends Equatable {
  final InvoiceFormStatus status;
  final Invoice? draftInvoice;
  final String? errorMessage;

  const InvoiceFormState({
    this.status = InvoiceFormStatus.initial,
    this.draftInvoice,
    this.errorMessage,
  });

  InvoiceFormState copyWith({
    InvoiceFormStatus? status,
    Invoice? draftInvoice,
    String? errorMessage,
  }) {
    return InvoiceFormState(
      status: status ?? this.status,
      draftInvoice: draftInvoice ?? this.draftInvoice,
      errorMessage: errorMessage, // Intentionally nullable to clear errors
    );
  }

  @override
  List<Object?> get props => [status, draftInvoice, errorMessage];
}
