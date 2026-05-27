import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart';

import '../../../../config/routes/route_constants.dart';
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
import '../../../../l10n/app_localizations.dart';

class InvoicesListPage extends StatelessWidget {
  final String? filterCustomerId;

  const InvoicesListPage({super.key, this.filterCustomerId});

  @override
  Widget build(BuildContext context) {
    return _InvoicesListView(filterCustomerId: filterCustomerId);
  }
}

class _InvoicesListView extends StatefulWidget {
  final String? filterCustomerId;
  const _InvoicesListView({this.filterCustomerId});

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

  String _getLocalizedStatusName(BuildContext context, InvoiceStatus status) {
    final loc = AppLocalizations.of(context);
    switch (status) {
      case InvoiceStatus.draft: return loc?.statusDraft.toUpperCase() ?? 'DRAFT';
      case InvoiceStatus.unpaid: return loc?.statusUnpaid.toUpperCase() ?? 'UNPAID';
      case InvoiceStatus.partiallyPaid: return loc?.statusPartiallyPaid.toUpperCase() ?? 'PARTIALLY PAID';
      case InvoiceStatus.paid: return loc?.statusPaid.toUpperCase() ?? 'PAID';
      case InvoiceStatus.overdue: return loc?.statusOverdue.toUpperCase() ?? 'OVERDUE';
      case InvoiceStatus.cancelled: return loc?.statusCancelled.toUpperCase() ?? 'CANCELLED';
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

    if (action == 'edit_draft') {
      final listCubit = context.read<InvoiceListCubit>();
      context.push('${AppRoutes.invoiceForm}?id=${inv.id}').then((_) {
        if (mounted) {
          listCubit.loadInvoices();
        }
      });
      return;
    }
    
    if (action == 'delete_draft') {
      // Drafts can be safely deleted as they are not finalized financial records.
      final confirm = await _showConfirmDialog(
        title: AppLocalizations.of(context)?.dialogDeleteDraftTitle ?? 'Delete Draft?',
        message: AppLocalizations.of(context)?.dialogDeleteDraftMessage ?? 'This draft invoice will be permanently deleted. This action cannot be undone.',
        confirmText: AppLocalizations.of(context)?.dialogDeleteDraftConfirm ?? 'Delete',
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
        title: AppLocalizations.of(context)?.dialogCancelInvoiceTitle ?? 'Cancel Invoice?',
        message: AppLocalizations.of(context)?.dialogCancelInvoiceMessage ?? 'This invoice will be marked as cancelled but kept for your records.',
        confirmText: AppLocalizations.of(context)?.dialogCancelInvoiceConfirm ?? 'Cancel Invoice',
        cancelText: AppLocalizations.of(context)?.dialogCancelInvoiceCancel ?? 'Keep Invoice',
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
        title: AppLocalizations.of(context)?.dialogDeleteCancelledTitle ?? 'Delete Cancelled Invoice?',
        message: AppLocalizations.of(context)?.dialogDeleteCancelledMessage ?? 'This will permanently delete this cancelled invoice record. This action cannot be undone.',
        confirmText: AppLocalizations.of(context)?.dialogDeleteCancelledConfirm ?? 'Delete Permanently',
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
            title: Text(widget.filterCustomerId != null
                ? AppLocalizations.of(context)?.customerInvoicesTitle ?? 'Customer Invoices'
                : AppLocalizations.of(context)?.invoicesTitle ?? 'Invoices'),
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
                        hintText: AppLocalizations.of(context)?.searchInvoices ?? 'Search invoice # or customer...',
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
                          padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
                          child: ChoiceChip(
                            label: Text(status == null 
                                ? AppLocalizations.of(context)?.filterAll.toUpperCase() ?? 'ALL' 
                                : status == InvoiceStatus.partiallyPaid 
                                    ? AppLocalizations.of(context)?.filterPartial.toUpperCase() ?? 'PARTIAL' 
                                    : AppLocalizations.of(context) != null 
                                        ? _getLocalizedStatusName(context, status) 
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
              var displayInvoices = state.filteredInvoices;
              if (widget.filterCustomerId != null) {
                displayInvoices = displayInvoices
                    .where((inv) => inv.customerId.toString() == widget.filterCustomerId)
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
                  title: widget.filterCustomerId == null && state.searchQuery.isEmpty
                      ? AppLocalizations.of(context)?.noInvoicesYet ?? 'No invoices yet'
                      : widget.filterCustomerId != null && state.searchQuery.isEmpty
                          ? AppLocalizations.of(context)?.noCustomerInvoicesYet ?? 'No invoices for this customer yet.'
                          : null,
                  message: widget.filterCustomerId != null
                      ? AppLocalizations.of(context)?.noCustomerInvoicesSubtitle ?? 'Create an invoice for this customer to start tracking their billing history.'
                      : (state.searchQuery.isNotEmpty
                          ? 'No invoices match your search.'
                          : AppLocalizations.of(context)?.noInvoicesSubtitle ?? 'You haven\'t created any invoices yet.'),
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
                                    _getLocalizedStatusName(context, inv.status),
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
                                '${AppLocalizations.of(context)?.issueDate ?? "Issue Date"}: ${DateFormat('MMM dd, yyyy').format(inv.issueDate)}',
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
                                    
                                    items.add(PopupMenuItem(
                                        value: 'view_pdf',
                                        child: Row(children: [
                                          const Icon(Icons.picture_as_pdf_rounded, size: 20),
                                          const SizedBox(width: 8),
                                          Text(AppLocalizations.of(context)?.viewPdf ?? 'View PDF')
                                        ])));
                                        
                                    items.add(const PopupMenuDivider());

                                    if (inv.status == InvoiceStatus.draft) {
                                      items.add(PopupMenuItem(
                                        value: 'edit_draft',
                                        child: Text(AppLocalizations.of(context)?.editDraft ?? 'Edit Draft', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                                      ));
                                      items.add(PopupMenuItem(
                                        value: 'delete_draft',
                                        child: Text(AppLocalizations.of(context)?.deleteDraft ?? 'Delete Draft', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                                      ));
                                    } else if (inv.status == InvoiceStatus.cancelled) {
                                      items.add(PopupMenuItem(
                                        value: 'delete_cancelled',
                                        child: Text(AppLocalizations.of(context)?.deletePermanently ?? 'Delete Permanently', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                                      ));
                                    } else {
                                      if (inv.status != InvoiceStatus.paid) {
                                        items.add(PopupMenuItem(
                                            value: 'paid',
                                            child: Text(AppLocalizations.of(context)?.markAsPaid ?? 'Mark as Paid')));
                                      }
                                      if (inv.status != InvoiceStatus.unpaid) {
                                        items.add(PopupMenuItem(
                                            value: 'unpaid',
                                            child: Text(AppLocalizations.of(context)?.markAsUnpaid ?? 'Mark as Unpaid')));
                                      }
                                      items.add(const PopupMenuDivider());
                                      items.add(PopupMenuItem(
                                          value: 'cancel_invoice',
                                          child: Text(AppLocalizations.of(context)?.cancelInvoice ?? 'Cancel Invoice', style: TextStyle(color: Theme.of(context).colorScheme.error)),
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
