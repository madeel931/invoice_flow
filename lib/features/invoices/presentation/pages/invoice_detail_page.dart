import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/formatters.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../../settings/presentation/cubit/settings_state.dart';
import 'package:printing/printing.dart';
import 'package:get_it/get_it.dart';

import '../../../../config/routes/route_constants.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/global_card.dart';
import '../../../../core/constants/app_units.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../settings/domain/usecases/get_business_profile_usecase.dart';
import '../../domain/usecases/get_invoices_usecase.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_status.dart';
import '../../domain/services/invoice_calculator.dart';
import '../../utils/invoice_pdf_generator.dart';
import '../cubit/invoice_list_cubit.dart';
import '../cubit/invoice_list_state.dart';

class InvoiceDetailPage extends StatefulWidget {
  final String invoiceId;

  const InvoiceDetailPage({super.key, required this.invoiceId});

  @override
  State<InvoiceDetailPage> createState() => _InvoiceDetailPageState();
}

class _InvoiceDetailPageState extends State<InvoiceDetailPage> {
  late Future<Invoice> _invoiceFuture;
  bool _isGeneratingPdf = false;

  @override
  void initState() {
    super.initState();
    _invoiceFuture = _loadInvoice();
  }

  Future<Invoice> _loadInvoice() async {
    final getInvoices = GetIt.instance<GetInvoicesUseCase>();
    final result = await getInvoices(NoParams());

    return result.fold(
      (failure) => throw Exception(failure.message),
      (invoices) {
        final index =
            invoices.indexWhere((i) => i.id?.toString() == widget.invoiceId);
        if (index == -1) throw Exception('Invoice not found.');
        return invoices[index];
      },
    );
  }

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
        return Colors.black54;
    }
  }

  String _getLocalizedStatusName(BuildContext context, InvoiceStatus status) {
    final loc = AppLocalizations.of(context);
    switch (status) {
      case InvoiceStatus.draft:
        return loc?.statusDraft.toUpperCase() ?? 'DRAFT';
      case InvoiceStatus.unpaid:
        return loc?.statusUnpaid.toUpperCase() ?? 'UNPAID';
      case InvoiceStatus.partiallyPaid:
        return loc?.statusPartiallyPaid.toUpperCase() ?? 'PARTIALLY PAID';
      case InvoiceStatus.paid:
        return loc?.statusPaid.toUpperCase() ?? 'PAID';
      case InvoiceStatus.overdue:
        return loc?.statusOverdue.toUpperCase() ?? 'OVERDUE';
      case InvoiceStatus.cancelled:
        return loc?.statusCancelled.toUpperCase() ?? 'CANCELLED';
    }
  }

  Future<void> _sharePdf(BuildContext context, Invoice currentInvoice) async {
    if (_isGeneratingPdf) return;
    setState(() => _isGeneratingPdf = true);

    try {
      final getProfile = GetIt.instance<GetBusinessProfileUseCase>();
      final result = await getProfile(NoParams());

      await result.fold(
          (l) async => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(AppLocalizations.of(context)?.failedToLoadProfile ??
                  'Failed to load profile for PDF.'))), (profile) async {
        final bytes =
            await InvoicePdfGenerator.generate(currentInvoice, profile);
        final fileName =
            '${currentInvoice.invoiceNumber}_${currentInvoice.customerName.replaceAll(' ', '_')}.pdf';

        // Uses the Printing package to instantly open the native OS share sheet!
        await Printing.sharePdf(bytes: bytes, filename: fileName);
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to generate PDF. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    String? cancelText,
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
            child: Text(
                cancelText ?? AppLocalizations.of(context)?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDestructive
                ? FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  Future<void> _handleInvoiceAction(Invoice inv, String action) async {
    if (action == 'edit_draft') {
      final listCubit = context.read<InvoiceListCubit>();
      final nav = GoRouter.of(context);
      context.push('${AppRoutes.invoiceForm}?id=${inv.id}').then((_) {
        if (mounted) {
          listCubit.loadInvoices();
          nav.pop();
        }
      });
      return;
    }

    if (action == 'delete_draft') {
      final confirm = await _showConfirmDialog(
        title:
            AppLocalizations.of(context)?.deleteDraftTitle ?? 'Delete Draft?',
        message: AppLocalizations.of(context)?.deleteDraftMessage ??
            'This draft invoice will be permanently deleted. This action cannot be undone.',
        confirmText: AppLocalizations.of(context)?.delete ?? 'Delete',
        isDestructive: true,
      );
      if (confirm == true && mounted) {
        if (inv.id != null) {
          await context.read<InvoiceListCubit>().delete(inv.id!);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(AppLocalizations.of(context)?.draftDeleted ??
                    'Draft deleted successfully.')));
            context.pop();
          }
        }
      }
      return;
    }

    if (action == 'cancel_invoice') {
      // Cancelling an invoice preserves it for accounting records instead of deleting it entirely.
      final confirm = await _showConfirmDialog(
        title: AppLocalizations.of(context)?.dialogCancelInvoiceTitle ??
            'Cancel Invoice?',
        message: AppLocalizations.of(context)?.dialogCancelInvoiceMessage ??
            'This invoice will be marked as cancelled but kept for your records.',
        confirmText: AppLocalizations.of(context)?.dialogCancelInvoiceConfirm ??
            'Cancel Invoice',
        cancelText: AppLocalizations.of(context)?.dialogCancelInvoiceCancel ??
            'Keep Invoice',
        isDestructive: true,
      );
      if (confirm == true && mounted) {
        await context
            .read<InvoiceListCubit>()
            .updateStatus(inv, InvoiceStatus.cancelled);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(AppLocalizations.of(context)?.invoiceCancelled ??
                  'Invoice cancelled.')));
        }
      }
      return;
    }

    if (action == 'delete_cancelled') {
      final confirm = await _showConfirmDialog(
        title: AppLocalizations.of(context)?.deleteCancelledTitle ??
            'Delete Cancelled Invoice?',
        message: AppLocalizations.of(context)?.deleteCancelledMessage ??
            'This will permanently delete this cancelled invoice record. This action cannot be undone.',
        confirmText: AppLocalizations.of(context)?.deletePermanently ??
            'Delete Permanently',
        isDestructive: true,
      );
      if (confirm == true && mounted) {
        if (inv.id != null) {
          await context.read<InvoiceListCubit>().delete(inv.id!);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    AppLocalizations.of(context)?.cancelledInvoiceDeleted ??
                        'Cancelled invoice deleted.')));
            context.pop();
          }
        }
      }
      return;
    }

    final newStatus = InvoiceStatus.values
        .firstWhere((e) => e.name == action, orElse: () => inv.status);
    if (newStatus != inv.status) {
      context.read<InvoiceListCubit>().updateStatus(inv, newStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Invoice>(
        future: _invoiceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                  title: Text(AppLocalizations.of(context)?.error ?? 'Error')),
              body: Center(
                  child:
                      Text(snapshot.error?.toString() ?? 'Invoice not found')),
            );
          }

          final invoice = snapshot.data!;

          return BlocBuilder<SettingsCubit, SettingsState>(
            bloc: GetIt.instance<SettingsCubit>(),
            builder: (context, settingsState) {
              final profileCurrency =
                  settingsState.profile?.currencyCode ?? 'AED';

              return BlocBuilder<InvoiceListCubit, InvoiceListState>(
                builder: (context, state) {
                  final currentInvoice = state.allInvoices.firstWhere(
                    (inv) => inv.id?.toString() == invoice.id?.toString(),
                    orElse: () => invoice,
                  );

                  final calc = InvoiceCalculator.calculate(currentInvoice);
                  final currencyCode =
                      currentInvoice.currencyCode?.trim().isNotEmpty == true
                          ? currentInvoice.currencyCode!
                          : profileCurrency;

                  String statusLabel = _getLocalizedStatusName(
                      context, currentInvoice.effectiveStatus);

                  return Scaffold(
                    appBar: AppBar(
                      title: Text(currentInvoice.invoiceNumber),
                      actions: [
                        if (_isGeneratingPdf)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.share_rounded),
                            tooltip: AppLocalizations.of(context)?.sharePdf ??
                                'Share PDF',
                            onPressed: () => _sharePdf(context, currentInvoice),
                          ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) =>
                              _handleInvoiceAction(currentInvoice, value),
                          itemBuilder: (context) {
                            final items = <PopupMenuEntry<String>>[];

                            if (currentInvoice.status == InvoiceStatus.draft) {
                              items.add(PopupMenuItem(
                                value: 'edit_draft',
                                child: Text(
                                    AppLocalizations.of(context)?.editDraft ??
                                        'Edit Draft',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary)),
                              ));
                              items.add(PopupMenuItem(
                                value: 'delete_draft',
                                child: Text(
                                    AppLocalizations.of(context)?.deleteDraft ??
                                        'Delete Draft',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error)),
                              ));
                            } else if (currentInvoice.status ==
                                InvoiceStatus.cancelled) {
                              items.add(PopupMenuItem(
                                value: 'delete_cancelled',
                                child: Text(
                                    AppLocalizations.of(context)
                                            ?.deletePermanently ??
                                        'Delete Permanently',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error)),
                              ));
                            } else {
                              if (currentInvoice.status != InvoiceStatus.paid) {
                                items.add(PopupMenuItem(
                                    value: 'paid',
                                    child: Text(AppLocalizations.of(context)
                                            ?.markAsPaid ??
                                        'Mark as Paid')));
                              }
                              if (currentInvoice.status !=
                                  InvoiceStatus.unpaid) {
                                items.add(PopupMenuItem(
                                    value: 'unpaid',
                                    child: Text(AppLocalizations.of(context)
                                            ?.markAsUnpaid ??
                                        'Mark as Unpaid')));
                              }
                              items.add(const PopupMenuDivider());
                              items.add(PopupMenuItem(
                                value: 'cancel_invoice',
                                child: Text(
                                    AppLocalizations.of(context)
                                            ?.cancelInvoice ??
                                        'Cancel Invoice',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error)),
                              ));
                            }

                            return items;
                          },
                        ),
                      ],
                    ),
                    body: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // --- HEADER: STATUS & DATES ---
                          GlobalCard(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        AppLocalizations.of(context)?.status ??
                                            'Status',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    Chip(
                                      label: Text(statusLabel,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                      backgroundColor: _getStatusColor(
                                          currentInvoice.effectiveStatus),
                                    ),
                                  ],
                                ),
                                const Divider(height: 32),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            AppLocalizations.of(context)
                                                    ?.issueDate ??
                                                'Issue Date',
                                            style: const TextStyle(
                                                color: Colors.grey)),
                                        const SizedBox(height: 4),
                                        Text(
                                            DateFormat('MMM dd, yyyy').format(
                                                currentInvoice.issueDate),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                            AppLocalizations.of(context)
                                                    ?.dueDate ??
                                                'Due Date',
                                            style: const TextStyle(
                                                color: Colors.grey)),
                                        const SizedBox(height: 4),
                                        Text(
                                            DateFormat('MMM dd, yyyy')
                                                .format(currentInvoice.dueDate),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // --- CUSTOMER DETAILS ---
                          GlobalCard(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                child: const Icon(Icons.person),
                              ),
                              title: Text(
                                  AppLocalizations.of(context)?.billedTo ??
                                      'Billed To',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                              subtitle: Text(currentInvoice.customerName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  )),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // --- LINE ITEMS ---
                          GlobalCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                    AppLocalizations.of(context)?.lineItems ??
                                        'Line Items',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                const Divider(height: 24),
                                ...calc.itemBreakdowns.map((calcItem) {
                                  final item = calcItem.item;
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 12.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(item.description,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              const SizedBox(height: 4),
                                              Text(
                                                  '${item.quantity} x ${AppFormatters.formatCurrency(item.unitPrice, currencyCode)}${item.unitType != null ? ' / ${AppUnits.localizedLabelOf(context, item.unitType)}' : ''}',
                                                  style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 13)),
                                              if (item.taxRate > 0)
                                                Text(
                                                    'Tax: ${item.taxRate.toStringAsFixed(1)}%',
                                                    style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                        Flexible(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                                AppFormatters.formatCurrency(
                                                    calcItem.itemTotal,
                                                    currencyCode),
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // --- TOTALS ---
                          GlobalCard(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        AppLocalizations.of(context)
                                                ?.subtotal ??
                                            'Subtotal',
                                        style: const TextStyle(
                                            color: Colors.grey)),
                                    Text(AppFormatters.formatCurrency(
                                        calc.subtotal, currencyCode)),
                                  ],
                                ),
                                if (calc.discountValue > 0) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          currentInvoice.discountType ==
                                                  'percentage'
                                              ? (AppLocalizations.of(context)
                                                      ?.discountWithPercentage(
                                                          currentInvoice
                                                              .discountAmount
                                                              .toString()) ??
                                                  'Discount (${currentInvoice.discountAmount}%)')
                                              : (AppLocalizations.of(context)
                                                      ?.discount ??
                                                  'Discount'),
                                          style: const TextStyle(
                                              color: Colors.red)),
                                      Text(
                                          '-${AppFormatters.formatCurrency(calc.discountValue, currencyCode)}',
                                          style: const TextStyle(
                                              color: Colors.red)),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        AppLocalizations.of(context)?.tax ??
                                            'Tax',
                                        style: const TextStyle(
                                            color: Colors.grey)),
                                    Text(
                                        '+${AppFormatters.formatCurrency(calc.totalTax, currencyCode)}'),
                                  ],
                                ),
                                const Divider(height: 32),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        AppLocalizations.of(context)
                                                ?.grandTotal ??
                                            'Grand Total',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 16),
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                            AppFormatters.formatCurrency(
                                                calc.grandTotal, currencyCode),
                                            style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        AppLocalizations.of(context)
                                                ?.amountPaid ??
                                            'Amount Paid',
                                        style: const TextStyle(
                                            color: Colors.green)),
                                    Text(
                                        '-${AppFormatters.formatCurrency(calc.paidAmount, currencyCode)}',
                                        style: const TextStyle(
                                            color: Colors.green)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        AppLocalizations.of(context)
                                                ?.balanceDue ??
                                            'Balance Due',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                        calc.balanceDue > 0
                                            ? AppFormatters.formatCurrency(
                                                calc.balanceDue, currencyCode)
                                            : 'Paid',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: calc.balanceDue > 0
                                                ? Colors.orange
                                                : Colors.green)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),

                    // --- BOTTOM QUICK ACTIONS BAR ---
                    bottomNavigationBar: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.picture_as_pdf),
                                label: Text(
                                    AppLocalizations.of(context)?.previewPdf ??
                                        'Preview PDF'),
                                // Navigate via GoRouter ID to avoid passing massive Invoice objects in the route state
                                onPressed: () => context.push(
                                    '${AppRoutes.invoicePreview}/${currentInvoice.id}'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            if (currentInvoice.status != InvoiceStatus.draft &&
                                currentInvoice.status !=
                                    InvoiceStatus.cancelled)
                              Expanded(
                                child: currentInvoice.status !=
                                        InvoiceStatus.paid
                                    ? FilledButton.icon(
                                        style: FilledButton.styleFrom(
                                            backgroundColor: Colors.green),
                                        icon: const Icon(
                                            Icons.check_circle_outline),
                                        label: Text(AppLocalizations.of(context)
                                                ?.markPaid ??
                                            'Mark Paid'),
                                        onPressed: () {
                                          context
                                              .read<InvoiceListCubit>()
                                              .updateStatus(currentInvoice,
                                                  InvoiceStatus.paid);
                                        },
                                      )
                                    : FilledButton.icon(
                                        style: FilledButton.styleFrom(
                                            backgroundColor: Colors.orange),
                                        icon: const Icon(Icons.undo),
                                        label: Text(AppLocalizations.of(context)
                                                ?.markUnpaid ??
                                            'Mark Unpaid'),
                                        onPressed: () {
                                          context
                                              .read<InvoiceListCubit>()
                                              .updateStatus(currentInvoice,
                                                  InvoiceStatus.unpaid);
                                        },
                                      ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        });
  }
}
