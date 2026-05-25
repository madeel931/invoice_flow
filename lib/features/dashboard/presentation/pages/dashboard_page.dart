import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../config/routes/route_constants.dart';
import '../../../../core/widgets/global_card.dart';
import '../../../../core/presentation/widgets/premium_drawer.dart';
import '../../../../core/utils/app_directories.dart';
import '../../../../core/utils/formatters.dart';
import '../../../invoices/domain/services/invoice_calculator.dart';
import '../../../invoices/domain/entities/invoice_status.dart';
import '../../../invoices/presentation/cubit/invoice_list_cubit.dart';
import '../../../invoices/presentation/cubit/invoice_list_state.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../../settings/presentation/cubit/settings_state.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../widgets/metric_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<InvoiceListCubit, InvoiceListState>(
      listenWhen: (previous, current) {
        // Trigger dashboard reload if the invoice list changes (e.g. status update, add, delete)
        return previous.allInvoices != current.allInvoices;
      },
      listener: (context, state) {
        context.read<DashboardCubit>().loadDashboard();
      },
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.partiallyPaid:
        return Colors.blue;
      case InvoiceStatus.unpaid:
        return Colors.orange;
      case InvoiceStatus.overdue:
        return Colors.red;
      case InvoiceStatus.draft:
        return Colors.grey;
      case InvoiceStatus.cancelled:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const PremiumDrawer(),
      appBar: AppBar(
        // REPLACE HAMBURGER WITH LOGO
        leading: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            final hasLogo = state.profile?.logoPath != null;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  backgroundImage: hasLogo
                      ? FileImage(File(AppDirectories.constructImagePath(
                          state.profile!.logoPath!)))
                      : null,
                  child: !hasLogo
                      ? Icon(Icons.storefront_rounded,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer)
                      : null,
                ),
              ),
            );
          },
        ),
        title: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            final name = state.profile?.businessName ?? 'Dashboard';
            return Text(name,
                style: const TextStyle(fontWeight: FontWeight.bold));
          },
        ),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        bloc: GetIt.instance<SettingsCubit>(),
        builder: (context, settingsState) {
          final currency = settingsState.profile?.currencyCode ?? 'AED';

          return BlocBuilder<DashboardCubit, DashboardState>(
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

              return RefreshIndicator(
                onRefresh: () => context.read<DashboardCubit>().loadDashboard(),
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // 1. HERO METRICS
                    MetricCard(
                      title: 'Total Revenue',
                      amount: AppFormatters.formatCurrencyCompact(
                          metrics.totalRevenue, currency),
                      icon: Icons.account_balance_wallet_rounded,
                      gradientColors: const [
                        Color(0xFF2563EB),
                        Color(0xFF1D4ED8)
                      ],
                    ),
                    const SizedBox(height: 16),
                    MetricCard(
                      title: 'Outstanding Balance',
                      amount: AppFormatters.formatCurrencyCompact(
                          metrics.outstandingBalance, currency),
                      icon: Icons.hourglass_empty_rounded,
                      gradientColors: const [
                        Color(0xFFF59E0B),
                        Color(0xFFD97706)
                      ],
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
                                color: Colors.grey)),
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

                    // 3. RECENT INVOICE CARD
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent Invoice',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.invoicesList),
                          child: const Text('View All'),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (state.recentInvoice == null)
                      GlobalCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Text('No invoices generated yet.',
                                style: TextStyle(color: Colors.grey[600])),
                          ),
                        ),
                      )
                    else
                      GlobalCard(
                        padding: EdgeInsets.zero,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: const Icon(Icons.receipt_long_rounded),
                          ),
                          title: Text(state.recentInvoice!.customerName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              '${state.recentInvoice!.invoiceNumber} • ${DateFormat('MMM dd').format(state.recentInvoice!.issueDate)}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  AppFormatters.formatCurrency(
                                      InvoiceCalculator.calculate(state.recentInvoice!).grandTotal, 
                                      state.recentInvoice!.currencyCode?.trim().isNotEmpty == true 
                                          ? state.recentInvoice!.currencyCode! 
                                          : currency),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                state.recentInvoice!.status == InvoiceStatus.partiallyPaid 
                                    ? 'PARTIALLY PAID' 
                                    : state.recentInvoice!.status.name.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(state.recentInvoice!.status),
                                ),
                              ),
                            ],
                          ),
                          onTap: () => context
                              .push('${AppRoutes.invoiceDetail}/${state.recentInvoice!.id}')
                              .then((_) {
                            if (context.mounted) {
                              context.read<DashboardCubit>().loadDashboard();
                            }
                          }),
                        ),
                      ),
                    const SizedBox(height: 48), // Padding for FAB
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.invoiceForm).then((_) {
          if (context.mounted) {
            context.read<DashboardCubit>().loadDashboard();
            context.read<InvoiceListCubit>().loadInvoices();
          }
        }),
        icon: const Icon(Icons.add),
        label: const Text('New Invoice'),
      ),
    );
  }
}

// Keep your _StatBox widget exactly as it was
class _StatBox extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _StatBox(
      {required this.title, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlobalCard(
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
