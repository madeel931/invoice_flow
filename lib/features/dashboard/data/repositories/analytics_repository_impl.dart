import 'package:dartz/dartz.dart' show Either, Left, Right;
import 'package:isar/isar.dart';

import '../../../../core/data/local/collections/invoice_collection.dart';
import '../../../../core/data/local/local_database_service.dart';
import '../../../../core/errors/failures.dart';
import '../../../invoices/domain/entities/invoice_item.dart';
import '../../../invoices/domain/entities/invoice.dart';
import '../../../invoices/domain/entities/invoice_status.dart';
import '../../domain/entities/dashboard_metrics.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../../../invoices/domain/services/invoice_calculator.dart';

// We reuse the mapping logic from Phase 12 locally to convert the DB models
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
      items: items
          .map((i) => InvoiceItem(
                description: i.description,
                quantity: i.quantity,
                unitPrice: i.unitPrice,
                taxRate: i.taxRate,
                unitType: i.unitType,
              ))
          .toList(),
      discountType: discountType,
      paidAmount: paidAmount,
    );
  }
}

/// Concrete implementation of [AnalyticsRepository] using Isar local database.
/// Aggregates financial totals (revenue, outstanding) and computes dashboard metrics.
class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final LocalDatabaseService localDb;

  AnalyticsRepositoryImpl({required this.localDb});

  @override
  Future<Either<Failure, DashboardMetrics>> getDashboardMetrics() async {
    try {
      final isar = localDb.db;

      // Fetch all invoices. Isar handles this incredibly fast locally.
      final collections = await isar.invoiceCollections.where().findAll();

      // Convert to rich domain entities to access the dynamic totalAmount math
      final invoices = collections.map((c) => c.toEntity()).toList();

      double totalRevenue = 0.0;
      double outstandingBalance = 0.0;

      int paidCount = 0;
      int unpaidCount = 0;
      int overdueCount = 0;
      int draftCount = 0;

      // Single pass aggregation - O(n) Time Complexity
      for (final inv in invoices) {
        if (inv.status == InvoiceStatus.draft) {
          draftCount++;
          // Skip heavy InvoiceCalculator math for drafts, they aren't revenue yet.
          continue; 
        }
        if (inv.status == InvoiceStatus.cancelled) {
          // Cancelled invoices hold no financial weight.
          continue; 
        }

        final calc = InvoiceCalculator.calculate(inv);
        final balanceDue = calc.balanceDue;
        final paidAmount = calc.paidAmount;

        switch (inv.status) {
          case InvoiceStatus.paid:
            // A fully paid invoice guarantees revenue is equal to the grand total.
            totalRevenue += calc.grandTotal;
            paidCount++;
            break;
          case InvoiceStatus.partiallyPaid:
            // For partials, revenue is only what was paid, the rest is outstanding.
            totalRevenue += paidAmount;
            outstandingBalance += balanceDue;
            unpaidCount++; // Treat partially paid as unpaid in basic metrics for now
            break;
          case InvoiceStatus.unpaid:
            outstandingBalance += balanceDue;
            unpaidCount++;
            break;
          case InvoiceStatus.overdue:
            totalRevenue += paidAmount;
            outstandingBalance += balanceDue;
            overdueCount++;
            break;
          case InvoiceStatus.draft:
          case InvoiceStatus.cancelled:
            break; // Handled earlier, required for exhaustive switch
        }
      }

      final metrics = DashboardMetrics(
        totalRevenue: totalRevenue,
        outstandingBalance: outstandingBalance,
        totalInvoices: invoices.length,
        paidInvoicesCount: paidCount,
        unpaidInvoicesCount: unpaidCount,
        overdueInvoicesCount: overdueCount,
        draftInvoicesCount: draftCount,
      );

      return Right(metrics);
    } catch (e) {
      return Left(DatabaseFailure('Failed to aggregate dashboard metrics: $e'));
    }
  }

  /// Retrieves the most recently issued invoice for quick display on the dashboard.
  /// Uses a direct Isar `.findFirst()` query for extremely fast O(1) performance.
  @override
  Future<Either<Failure, Invoice?>> getRecentInvoice() async {
    try {
      final isar = localDb.db;
      final collection = await isar.invoiceCollections
          .where()
          .filter()
          .not().statusEqualTo(InvoiceStatus.draft)
          .and()
          .not().statusEqualTo(InvoiceStatus.cancelled)
          .sortByCreatedAtDesc()
          .findFirst();
      
      return Right(collection?.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to fetch recent invoice: $e'));
    }
  }
}
