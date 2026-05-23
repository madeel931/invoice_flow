import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../config/routes/route_constants.dart';
import '../../../../core/presentation/widgets/surface_card.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../widgets/metric_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<DashboardCubit>()..loadDashboard(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  /// Formats the raw double into a beautiful localized currency string
  String _formatCurrency(double amount, String currencyCode) {
    final format = NumberFormat.simpleCurrency(name: currencyCode);
    return format.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            final name = state.profile?.businessName ?? 'Dashboard';
            return Text(name,
                style: const TextStyle(fontWeight: FontWeight.bold));
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.push(AppRoutes.settings).then((_) {
              // Refresh in case they changed their currency in settings
              if (context.mounted)
                context.read<DashboardCubit>().loadDashboard();
            }),
          ),
        ],
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state.status == DashboardStatus.loading ||
              state.status == DashboardStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == DashboardStatus.error) {
            return Center(
                child: Text(state.errorMessage ?? 'An error occurred'));
          }

          final metrics = state.metrics!;
          final currency = state.profile?.currencyCode ?? 'USD';

          return RefreshIndicator(
            onRefresh: () => context.read<DashboardCubit>().loadDashboard(),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // 1. HERO METRICS
                MetricCard(
                  title: 'Total Revenue',
                  amount: _formatCurrency(metrics.totalRevenue, currency),
                  icon: Icons.account_balance_wallet_rounded,
                  gradientColors: const [
                    Color(0xFF2563EB),
                    Color(0xFF1D4ED8)
                  ], // Primary Fintech Blue
                ),
                const SizedBox(height: 16),
                MetricCard(
                  title: 'Outstanding Balance',
                  amount: _formatCurrency(metrics.outstandingBalance, currency),
                  icon: Icons.hourglass_empty_rounded,
                  gradientColors: const [
                    Color(0xFFF59E0B),
                    Color(0xFFD97706)
                  ], // Warning Amber
                ),
                const SizedBox(height: 24),

                // 2. INVOICE LIFECYCLE SUMMARY
                Text('Invoice Summary',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: _StatBox(
                            title: 'Drafts',
                            count: metrics.draftInvoicesCount,
                            color: Colors.grey)), // Added Drafts
                    const SizedBox(width: 12),
                    Expanded(
                        child: _StatBox(
                            title: 'Unpaid',
                            count: metrics.unpaidInvoicesCount,
                            color: Colors.orange)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _StatBox(
                            title: 'Overdue',
                            count: metrics.overdueInvoicesCount,
                            color: Colors.red)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _StatBox(
                            title: 'Paid',
                            count: metrics.paidInvoicesCount,
                            color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. QUICK ACTIONS
                Text('Quick Actions',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.receipt_long_rounded,
                        title: 'Invoices',
                        onTap: () =>
                            context.push(AppRoutes.invoicesList).then((_) {
                          if (context.mounted)
                            context.read<DashboardCubit>().loadDashboard();
                        }),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.people_rounded,
                        title: 'Customers',
                        onTap: () => context.push(AppRoutes.customers),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.inventory_2_rounded,
                        title: 'Products',
                        onTap: () => context.push(AppRoutes.products),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.invoiceForm).then((_) {
          // Instantly refresh metrics when returning from creating an invoice!
          if (context.mounted) context.read<DashboardCubit>().loadDashboard();
        }),
        icon: const Icon(Icons.add),
        label: const Text('New Invoice'),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _StatBox(
      {required this.title, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(count.toString(),
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickActionCard(
      {required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
