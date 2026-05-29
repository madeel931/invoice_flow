import 'package:dartz/dartz.dart' show Either, Left, Right;
import 'package:isar/isar.dart';

import '../../../../core/data/local/collections/invoice_collection.dart';
import '../../../../core/data/local/collections/business_profile_collection.dart';
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
      discountType: discountType,
      discountAmount: discountAmount,
      paidAmount: paidAmount,
      notes: notes,
      currencyCode: currencyCode,
      currencySymbol: currencySymbol,
      createdAt: createdAt,
      updatedAt: updatedAt,
      items: items
          .map((i) => InvoiceItem(
                description: i.description,
                quantity: i.quantity,
                unitPrice: i.unitPrice,
                taxRate: i.taxRate,
                unitType: i.unitType,
              ))
          .toList(),
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

        final profile = await isar.businessProfileCollections.where().findFirst();
        final defaultCurrency = profile?.currencyCode ?? 'USD';

        double totalRevenue = 0.0;
        double outstandingBalance = 0.0;

        int paidCount = 0;
        int unpaidCount = 0;
        int overdueCount = 0;
        int draftCount = 0;

        final Map<String, double> revenues = {};
        final Map<String, double> outstandings = {};

        // Single pass aggregation - O(n) Time Complexity
        for (final inv in invoices) {
          if (inv.effectiveStatus == InvoiceStatus.draft) {
            draftCount++;
            // Skip heavy InvoiceCalculator math for drafts, they aren't revenue yet.
            continue; 
          }
          if (inv.effectiveStatus == InvoiceStatus.cancelled) {
            // Cancelled invoices hold no financial weight.
            continue; 
          }

          final calc = InvoiceCalculator.calculate(inv);
          final balanceDue = calc.balanceDue;
          final paidAmount = calc.paidAmount;

          // Historical invoices created before currency persistence use default currency fallback.
          final code = (inv.currencyCode == null || inv.currencyCode!.trim().isEmpty)
              ? defaultCurrency.trim().toUpperCase()
              : inv.currencyCode!.trim().toUpperCase();

          switch (inv.effectiveStatus) {
            case InvoiceStatus.paid:
              // A fully paid invoice guarantees revenue is equal to the grand total.
              totalRevenue += calc.grandTotal;
              paidCount++;
              revenues[code] = (revenues[code] ?? 0.0) + calc.grandTotal;
              break;
            case InvoiceStatus.partiallyPaid:
              // For partials, revenue is only what was paid, the rest is outstanding.
              totalRevenue += paidAmount;
              outstandingBalance += balanceDue;
              unpaidCount++; // Treat partially paid as unpaid in basic metrics for now
              revenues[code] = (revenues[code] ?? 0.0) + paidAmount;
              outstandings[code] = (outstandings[code] ?? 0.0) + balanceDue;
              break;
            case InvoiceStatus.unpaid:
              outstandingBalance += balanceDue;
              unpaidCount++;
              outstandings[code] = (outstandings[code] ?? 0.0) + balanceDue;
              break;
            case InvoiceStatus.overdue:
              totalRevenue += paidAmount;
              outstandingBalance += balanceDue;
              overdueCount++;
              revenues[code] = (revenues[code] ?? 0.0) + paidAmount;
              outstandings[code] = (outstandings[code] ?? 0.0) + balanceDue;
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
          revenues: revenues,
          outstandings: outstandings,
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
