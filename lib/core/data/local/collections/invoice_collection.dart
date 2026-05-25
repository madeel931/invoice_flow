import 'package:isar/isar.dart';
import '../../../../features/invoices/domain/entities/invoice_status.dart';

part 'invoice_collection.g.dart';

@embedded
class InvoiceItemCollection {
  late String description;
  late double quantity;
  late double unitPrice;
  late double taxRate;
  String? unitType;
}

@collection
class InvoiceCollection {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String invoiceNumber;

  @Index(type: IndexType.value)
  late int customerId; // Fast lookup for "Get all invoices for Customer X"

  late String customerName;

  late DateTime issueDate;

  @Index(type: IndexType.value)
  late DateTime dueDate; // Indexed to easily query "Overdue" invoices

  // Natively embed the list of items inside this document
  late List<InvoiceItemCollection> items;

  @enumerated
  late InvoiceStatus status;

  late String discountType; // 'amount' or 'percentage'
  late double discountAmount;
  late double paidAmount;

  String? notes;
  String? currencyCode;

  DateTime? createdAt;
  DateTime? updatedAt;
}
