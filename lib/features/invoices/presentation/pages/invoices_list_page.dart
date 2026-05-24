import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart';

import '../../../../config/routes/route_constants.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/global_card.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/utils/formatters.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../../settings/presentation/cubit/settings_state.dart';
import '../../domain/entities/invoice_status.dart';
import '../cubit/invoice_list_cubit.dart';
import '../cubit/invoice_list_state.dart';

class InvoicesListPage extends StatelessWidget {
  const InvoicesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _InvoicesListView();
  }
}

class _InvoicesListView extends StatefulWidget {
  const _InvoicesListView();

  @override
  State<_InvoicesListView> createState() => _InvoicesListViewState();
}

class _InvoicesListViewState extends State<_InvoicesListView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getStatusColor(BuildContext context, InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return AppColors.success;
      case InvoiceStatus.unpaid:
        return AppColors.warning;
      case InvoiceStatus.overdue:
        return AppColors.error;
      case InvoiceStatus.draft:
        return Theme.of(context).colorScheme.onSurfaceVariant;
      case InvoiceStatus.cancelled:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      bloc: GetIt.instance<SettingsCubit>(),
      builder: (context, settingsState) {
        final currencyCode = settingsState.profile?.currencyCode ?? 'AED';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Invoices'),
            bottom: PreferredSize(
              preferredSize:
                  const Size.fromHeight(120), // Expanded to fit search + chips
              child: Column(
                children: [
                  // Search Bar
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) =>
                          context.read<InvoiceListCubit>().search(val),
                      decoration: InputDecoration(
                        hintText: 'Search invoice # or customer...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  context.read<InvoiceListCubit>().search('');
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  // Status Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: AppSpacing.md, right: AppSpacing.md),
                    child: Row(
                      children: [null, ...InvoiceStatus.values].map((status) {
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: ChoiceChip(
                            label: Text(status?.name.toUpperCase() ?? 'ALL'),
                            selected: context.select(
                                    (InvoiceListCubit c) => c.state.filterStatus) ==
                                status,
                            onSelected: (_) => context
                                .read<InvoiceListCubit>()
                                .filterByStatus(status),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: BlocBuilder<InvoiceListCubit, InvoiceListState>(
            builder: (context, state) {
              if (state.status == InvoiceListStatus.loading) {
                return const LoadingWidget();
              }

              if (state.filteredInvoices.isEmpty) {
                return const EmptyStateWidget(
                  message: 'No invoices found.',
                  icon: Icons.receipt_long,
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: state.filteredInvoices.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final inv = state.filteredInvoices[index];
                  final statusColor = _getStatusColor(context, inv.status);

                  return GlobalCard(
                    padding: EdgeInsets.zero,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      onTap: () => context.push(AppRoutes.invoiceDetail, extra: inv),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top row: Invoice number + Status Pill
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(inv.invoiceNumber,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                                  ),
                                  child: Text(
                                    inv.status.name.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            // Middle section: Customer name & Date
                            Text(inv.customerName,
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            const SizedBox(height: 2),
                            Text(
                                'Issue Date: ${DateFormat('MMM dd, yyyy').format(inv.issueDate)}',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                            const SizedBox(height: AppSpacing.md),
                            const Divider(height: 1),
                            const SizedBox(height: AppSpacing.md),
                            // Bottom row: Total amount large + chevron/action
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppFormatters.formatCurrency(inv.totalAmount, currencyCode),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, 
                                      fontSize: 20, 
                                      color: Theme.of(context).colorScheme.onSurface),
                                ),
                                PopupMenuButton<String>(
                                  icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                  onSelected: (value) {
                                    if (value == 'view_pdf') {
                                      context.push(AppRoutes.invoiceDetail, extra: inv);
                                    } else {
                                      final newStatus = InvoiceStatus.values
                                          .firstWhere((e) => e.name == value);
                                      context
                                          .read<InvoiceListCubit>()
                                          .updateStatus(inv, newStatus);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                        value: 'view_pdf',
                                        child: Row(children: [
                                          Icon(Icons.picture_as_pdf_rounded, size: 20),
                                          SizedBox(width: 8),
                                          Text('View PDF')
                                        ])),
                                    const PopupMenuDivider(),
                                    const PopupMenuItem(
                                        value: 'paid', child: Text('Mark as Paid')),
                                    const PopupMenuItem(
                                        value: 'unpaid', child: Text('Mark as Unpaid')),
                                    const PopupMenuItem(
                                        value: 'overdue', child: Text('Mark as Overdue')),
                                    const PopupMenuItem(
                                        value: 'cancelled',
                                        child: Text('Cancel Invoice')),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
