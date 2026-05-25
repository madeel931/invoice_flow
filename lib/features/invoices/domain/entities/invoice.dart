import 'package:equatable/equatable.dart';
import 'invoice_item.dart';
import 'invoice_status.dart';

class Invoice extends Equatable {
  final int? id;
  final String invoiceNumber; // e.g., INV-2026-001
  final int customerId; // Link to CRM for dashboard grouping
  final String
      customerName; // Snapshot of name in case customer is deleted later
  final DateTime issueDate;
  final DateTime dueDate;
  final List<InvoiceItem> items;
  final InvoiceStatus status;
  final String discountType; // 'amount' or 'percentage'
  final double discountAmount;
  final double paidAmount;
  final String? notes;
  final String? currencyCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Invoice({
    this.id,
    required this.invoiceNumber,
    required this.customerId,
    required this.customerName,
    required this.issueDate,
    required this.dueDate,
    this.items = const [],
    this.status = InvoiceStatus.draft,
    this.discountType = 'amount',
    this.discountAmount = 0.0,
    this.paidAmount = 0.0,
    this.notes,
    this.currencyCode,
    this.createdAt,
    this.updatedAt,
  });



  Invoice copyWith({
    int? id,
    String? invoiceNumber,
    int? customerId,
    String? customerName,
    DateTime? issueDate,
    DateTime? dueDate,
    List<InvoiceItem>? items,
    InvoiceStatus? status,
    String? discountType,
    double? discountAmount,
    double? paidAmount,
    String? notes,
    String? currencyCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      items: items ?? this.items,
      status: status ?? this.status,
      discountType: discountType ?? this.discountType,
      discountAmount: discountAmount ?? this.discountAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      notes: notes ?? this.notes,
      currencyCode: currencyCode ?? this.currencyCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        invoiceNumber,
        customerId,
        customerName,
        issueDate,
        dueDate,
        items,
        status,
        discountType,
        discountAmount,
        paidAmount,
        notes,
        currencyCode,
        createdAt,
        updatedAt
      ];
}
