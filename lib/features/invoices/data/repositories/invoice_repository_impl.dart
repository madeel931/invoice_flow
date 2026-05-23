import 'package:dartz/dartz.dart' show Either, Left, Right, Unit, unit;
import 'package:isar/isar.dart';

import '../../../../core/data/local/collections/invoice_collection.dart';
import '../../../../core/data/local/local_database_service.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_item.dart';
import '../../domain/repositories/invoice_repository.dart';

// Mappers
extension on InvoiceCollection {
  Invoice toEntity() {
    return Invoice(
      id: id,
      invoiceNumber: invoiceNumber,
      customerId: customerId,
      customerName: customerName,
      issueDate: issueDate,
      dueDate: dueDate,
      status: status,
      discountAmount: discountAmount,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      items: items
          .map((i) => InvoiceItem(
                description: i.description,
                quantity: i.quantity,
                unitPrice: i.unitPrice,
                taxRate: i.taxRate,
              ))
          .toList(),
    );
  }
}

extension on Invoice {
  InvoiceCollection toCollection() {
    final collection = InvoiceCollection()
      ..invoiceNumber = invoiceNumber
      ..customerId = customerId
      ..customerName = customerName
      ..issueDate = issueDate
      ..dueDate = dueDate
      ..status = status
      ..discountAmount = discountAmount
      ..notes = notes
      ..createdAt = createdAt ?? DateTime.now()
      ..updatedAt = DateTime.now()
      ..items = items
          .map((i) => InvoiceItemCollection()
            ..description = i.description
            ..quantity = i.quantity
            ..unitPrice = i.unitPrice
            ..taxRate = i.taxRate)
          .toList();

    if (id != null) {
      collection.id = id!;
    }
    return collection;
  }
}

class InvoiceRepositoryImpl implements InvoiceRepository {
  final LocalDatabaseService localDb;

  InvoiceRepositoryImpl({required this.localDb});

  @override
  Future<Either<Failure, List<Invoice>>> getInvoices() async {
    try {
      final isar = localDb.db;
      // Sort by creation date descending (newest first)
      final collections =
          await isar.invoiceCollections.where().sortByCreatedAtDesc().findAll();
      return Right(collections.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(DatabaseFailure('Failed to fetch invoices: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> generateNextInvoiceNumber() async {
    try {
      final isar = localDb.db;
      final count = await isar.invoiceCollections.count();

      // Basic formatting: INV-001, INV-002, etc.
      // In a real scenario, this prefix could be customizable in settings.
      final nextNumber = count + 1;
      final formattedNumber = 'INV-${nextNumber.toString().padLeft(3, '0')}';

      return Right(formattedNumber);
    } catch (e) {
      return Left(DatabaseFailure('Failed to generate invoice number: $e'));
    }
  }

  @override
  Future<Either<Failure, Invoice>> saveInvoice(Invoice invoice) async {
    try {
      final isar = localDb.db;
      final collection = invoice.toCollection();

      await isar.writeTxn(() async {
        await isar.invoiceCollections.put(collection);
      });

      return Right(collection.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to save invoice: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteInvoice(int id) async {
    try {
      final isar = localDb.db;
      await isar.writeTxn(() async {
        await isar.invoiceCollections.delete(id);
      });
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete invoice: $e'));
    }
  }
}
