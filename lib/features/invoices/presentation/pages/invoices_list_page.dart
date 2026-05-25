import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart';

import '../../../../config/routes/route_constants.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../domain/entities/invoice.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';

import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/utils/formatters.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../domain/entities/invoice_status.dart';
import '../../domain/services/invoice_calculator.dart';
import '../cubit/invoice_list_cubit.dart';
import '../cubit/invoice_list_state.dart';
import '../../../settings/presentation/cubit/settings_state.dart';

class InvoicesListPage extends StatelessWidget {
  final Customer? filterCustomer;

  const InvoicesListPage({super.key, this.filterCustomer});

  @override
  Widget build(BuildContext context) {
    return _InvoicesListView(filterCustomer: filterCustomer);
  }
}

class _InvoicesListView extends StatefulWidget {
  final Customer? filterCustomer;
  const _InvoicesListView({this.filterCustomer});

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
      case InvoiceStatus.partiallyPaid:
        return Theme.of(context).colorScheme.primary;
      case InvoiceStatus.unpaid:
        return AppColors.warning;
      case InvoiceStatus.overdue:
        return AppColors.error;
      case InvoiceStatus.draft:
        return Colors.grey;
      case InvoiceStatus.cancelled:
        return Colors.grey.shade600;
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDestructive 
              ? FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error)
              : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  Future<void> _handleInvoiceAction(Invoice inv, String action) async {
    if (action == 'view_pdf') {
      context.push('${AppRoutes.invoiceDetail}/${inv.id}');
      return;
    }
    
    if (action == 'delete_draft') {
      // Drafts can be safely deleted as they are not finalized financial records.
      final confirm = await _showConfirmDialog(
        title: 'Delete Draft?',
        message: 'This draft invoice will be permanently deleted. This action cannot be undone.',
        confirmText: 'Delete',
        isDestructive: true,
      );
      if (confirm == true && mounted) {
        if (inv.id != null) {
          await context.read<InvoiceListCubit>().delete(inv.id!);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draft deleted successfully.')));
          }
        }
      }
      return;
    }

    if (action == 'cancel_invoice') {
      final confirm = await _showConfirmDialog(
        title: 'Cancel Invoice?',
        message: 'This invoice will be marked as cancelled but kept for your records.',
        confirmText: 'Cancel Invoice',
        cancelText: 'Keep Invoice',
        isDestructive: true,
      );
      if (confirm == true && mounted) {
        await context.read<InvoiceListCubit>().updateStatus(inv, InvoiceStatus.cancelled);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice cancelled.')));
        }
      }
      return;
    }

    if (action == 'delete_cancelled') {
      // Allow permanent deletion ONLY for cancelled invoices. Keep strict audit trail for active ones.
      final confirm = await _showConfirmDialog(
        title: 'Delete Cancelled Invoice?',
        message: 'This will permanently delete this cancelled invoice record. This action cannot be undone.',
        confirmText: 'Delete Permanently',
        isDestructive: true,
      );
      if (confirm == true && mounted) {
        if (inv.id != null) {
          await context.read<InvoiceListCubit>().delete(inv.id!);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cancelled invoice deleted.')));
          }
        }
      }
      return;
    }

    final newStatus = InvoiceStatus.values.firstWhere((e) => e.name == action, orElse: () => inv.status);
    if (newStatus != inv.status) {
      context.read<InvoiceListCubit>().updateStatus(inv, newStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeBrightness = Theme.of(context).brightness;

    return BlocBuilder<SettingsCubit, SettingsState>(
      bloc: GetIt.instance<SettingsCubit>(),
      builder: (context, settingsState) {
        final profileCurrency = settingsState.profile?.currencyCode ?? 'AED';

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.filterCustomer != null
                ? 'Invoices - ${widget.filterCustomer!.name}'
                : 'Invoices'),
            bottom: PreferredSize(
              preferredSize:
                  const Size.fromHeight(120), // Expanded to fit search + chips
              child: Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.sm),
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
                    padding: const EdgeInsets.only(
                        bottom: AppSpacing.sm,
                        left: AppSpacing.md,
                        right: AppSpacing.md),
                    child: Row(
                      children: [null, ...InvoiceStatus.values].map((status) {
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: ChoiceChip(
                            label: Text(status == null 
                                ? 'ALL' 
                                : status == InvoiceStatus.partiallyPaid 
                                    ? 'PARTIAL' 
                                    : status.name.toUpperCase()),
                            selected: context.select((InvoiceListCubit c) =>
                                    c.state.filterStatus) ==
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
          body: KeyedSubtree(
            key: ValueKey('invoice_list_body_$themeBrightness'),
            child: BlocBuilder<InvoiceListCubit, InvoiceListState>(
              builder: (context, state) {
              // Apply UI-level customer filtering
              List<Invoice> displayInvoices = state.filteredInvoices;
              if (widget.filterCustomer != null) {
                displayInvoices = displayInvoices
                    .where((inv) => inv.customerId == widget.filterCustomer!.id)
                    .toList();
              }

              if (state.status == InvoiceListStatus.loading) {
                return const LoadingWidget();
              }

              if (state.status == InvoiceListStatus.error) {
                return EmptyStateWidget(
                  icon: Icons.error_outline,
                  message: state.errorMessage ?? 'Failed to load invoices',
                );
              }

              if (displayInvoices.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.receipt_long_outlined,
                  message: widget.filterCustomer != null
                      ? 'No invoices for this customer yet.'
                      : 'You haven\'t created any invoices yet.',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: displayInvoices.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final inv = displayInvoices[index];
                  final statusColor = _getStatusColor(context, inv.status);
                  final theme = Theme.of(context);
                  final colorScheme = theme.colorScheme;
                  final textTheme = theme.textTheme;
                  final calc = InvoiceCalculator.calculate(inv);
                  final currencyCode = inv.currencyCode?.trim().isNotEmpty == true
                      ? inv.currencyCode!
                      : profileCurrency;

                  return Card(
                    key: ValueKey(
                        '${inv.id}_${theme.brightness}_${inv.status.name}_${inv.updatedAt?.millisecondsSinceEpoch}'),
                    color: colorScheme.surface,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      onTap: () =>
                          context.push('${AppRoutes.invoiceDetail}/${inv.id}'),
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
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    )),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(
                                        AppSizes.radiusXl),
                                  ),
                                  child: Text(
                                    inv.status == InvoiceStatus.partiallyPaid 
                                        ? 'PARTIALLY PAID' 
                                        : inv.status.name.toUpperCase(),
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
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                )),
                            const SizedBox(height: 2),
                            Text(
                                'Issue Date: ${DateFormat('MMM dd, yyyy').format(inv.issueDate)}',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                )),
                            const SizedBox(height: AppSpacing.md),
                            const Divider(height: 1),
                            const SizedBox(height: AppSpacing.md),
                            // Bottom row: Total amount large + chevron/action
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          AppFormatters.formatCurrency(calc.grandTotal, currencyCode),
                                          style: textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.onSurface),
                                        ),
                                      ),
                                      if (calc.paidAmount > 0 && calc.balanceDue > 0) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Paid: ${AppFormatters.formatCurrency(calc.paidAmount, currencyCode)} • Due: ${AppFormatters.formatCurrency(calc.balanceDue, currencyCode)}',
                                          style: textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
                                  onSelected: (value) => _handleInvoiceAction(inv, value),
                                  itemBuilder: (context) {
                                    final items = <PopupMenuEntry<String>>[];
                                    
                                    items.add(const PopupMenuItem(
                                        value: 'view_pdf',
                                        child: Row(children: [
                                          Icon(Icons.picture_as_pdf_rounded, size: 20),
                                          SizedBox(width: 8),
                                          Text('View PDF')
                                        ])));
                                        
                                    items.add(const PopupMenuDivider());

                                    if (inv.status == InvoiceStatus.draft) {
                                      items.add(PopupMenuItem(
                                        value: 'delete_draft',
                                        child: Text('Delete Draft', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                                      ));
                                    } else if (inv.status == InvoiceStatus.cancelled) {
                                      items.add(PopupMenuItem(
                                        value: 'delete_cancelled',
                                        child: Text('Delete Permanently', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                                      ));
                                    } else {
                                      if (inv.status != InvoiceStatus.paid) {
                                        items.add(const PopupMenuItem(
                                            value: 'paid',
                                            child: Text('Mark as Paid')));
                                      }
                                      if (inv.status != InvoiceStatus.unpaid) {
                                        items.add(const PopupMenuItem(
                                            value: 'unpaid',
                                            child: Text('Mark as Unpaid')));
                                      }
                                      items.add(const PopupMenuDivider());
                                      items.add(PopupMenuItem(
                                          value: 'cancel_invoice',
                                          child: Text('Cancel Invoice', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                                      ));
                                    }
                                    
                                    return items;
                                  },
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
          ),
        );
      },
    );
  }
}
