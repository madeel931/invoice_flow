import 'package:equatable/equatable.dart';

class DashboardMetrics extends Equatable {
  final double totalRevenue; // Paid invoices
  final double outstandingBalance; // Unpaid + Overdue invoices
  final int totalInvoices;
  final int paidInvoicesCount;
  final int unpaidInvoicesCount;
  final int overdueInvoicesCount;
  final int draftInvoicesCount;

  const DashboardMetrics({
    required this.totalRevenue,
    required this.outstandingBalance,
    required this.totalInvoices,
    required this.paidInvoicesCount,
    required this.unpaidInvoicesCount,
    required this.overdueInvoicesCount,
    required this.draftInvoicesCount,
  });

  // Helper to easily calculate collection rate
  double get collectionRate {
    if (totalRevenue + outstandingBalance == 0) return 0.0;
    return (totalRevenue / (totalRevenue + outstandingBalance)) * 100;
  }

  @override
  List<Object?> get props => [
        totalRevenue,
        outstandingBalance,
        totalInvoices,
        paidInvoicesCount,
        unpaidInvoicesCount,
        overdueInvoicesCount,
        draftInvoicesCount,
      ];
}
