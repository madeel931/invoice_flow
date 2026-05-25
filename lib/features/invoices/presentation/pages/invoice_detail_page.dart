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
import '../../../../core/widgets/global_card.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../settings/domain/usecases/get_business_profile_usecase.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_status.dart';
import '../../domain/services/invoice_calculator.dart';
import '../../utils/invoice_pdf_generator.dart';
import '../cubit/invoice_list_cubit.dart';
import '../cubit/invoice_list_state.dart';

class InvoiceDetailPage extends StatelessWidget {
  final Invoice invoice; // The initial invoice passed via routing

  const InvoiceDetailPage({super.key, required this.invoice});

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

  Future<void> _sharePdf(BuildContext context, Invoice currentInvoice) async {
    final getProfile = GetIt.instance<GetBusinessProfileUseCase>();
    final result = await getProfile(NoParams());

    result.fold(
        (l) => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load profile for PDF.'))),
        (profile) async {
      final bytes = await InvoicePdfGenerator.generate(currentInvoice, profile);
      final fileName =
          '${currentInvoice.invoiceNumber}_${currentInvoice.customerName.replaceAll(' ', '_')}.pdf';

      // Uses the Printing package to instantly open the native OS share sheet!
      await Printing.sharePdf(bytes: bytes, filename: fileName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      bloc: GetIt.instance<SettingsCubit>(),
      builder: (context, settingsState) {
        final profileCurrency = settingsState.profile?.currencyCode ?? 'AED';

        return BlocBuilder<InvoiceListCubit, InvoiceListState>(
          builder: (context, state) {
            final currentInvoice = state.allInvoices.firstWhere(
              (inv) => inv.id == invoice.id,
              orElse: () => invoice,
            );
            
            final calc = InvoiceCalculator.calculate(currentInvoice);
            final currencyCode = currentInvoice.currencyCode?.trim().isNotEmpty == true 
                ? currentInvoice.currencyCode! 
                : profileCurrency;

            String statusLabel = currentInvoice.status.name.toUpperCase();
            if (currentInvoice.status == InvoiceStatus.partiallyPaid) {
              statusLabel = 'PARTIALLY PAID';
            }

            return Scaffold(
              appBar: AppBar(
                title: Text(currentInvoice.invoiceNumber),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share_rounded),
                    tooltip: 'Share PDF',
                    onPressed: () => _sharePdf(context, currentInvoice),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Status',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Chip(
                                label: Text(
                                    statusLabel,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                backgroundColor:
                                    _getStatusColor(currentInvoice.status),
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Issue Date',
                                      style: TextStyle(color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  Text(
                                      DateFormat('MMM dd, yyyy')
                                          .format(currentInvoice.issueDate),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Due Date',
                                      style: TextStyle(color: Colors.grey)),
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
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          child: const Icon(Icons.person),
                        ),
                        title: const Text('Billed To',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                        subtitle: Text(currentInvoice.customerName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- LINE ITEMS ---
                    GlobalCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Line Items',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const Divider(height: 24),
                          ...calc.itemBreakdowns.map((calcItem) {
                            final item = calcItem.item;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(item.description,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text(
                                            '${item.quantity} x ${AppFormatters.formatCurrency(item.unitPrice, currencyCode)}${item.unitType != null ? ' / ${item.unitType!.toLowerCase()}' : ''}',
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
                                              calcItem.itemTotal, currencyCode),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal',
                                  style: TextStyle(color: Colors.grey)),
                              Text(AppFormatters.formatCurrency(
                                  calc.subtotal, currencyCode)),
                            ],
                          ),
                          if (calc.discountValue > 0) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(currentInvoice.discountType == 'percentage' 
                                     ? 'Discount (${currentInvoice.discountAmount}%)' 
                                     : 'Discount',
                                    style: const TextStyle(color: Colors.red)),
                                Text(
                                    '-${AppFormatters.formatCurrency(calc.discountValue, currencyCode)}',
                                    style:
                                        const TextStyle(color: Colors.red)),
                              ],
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Tax',
                                  style: TextStyle(color: Colors.grey)),
                              Text('+${AppFormatters.formatCurrency(
                                  calc.totalTax, currencyCode)}'),
                            ],
                          ),
                          const Divider(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Grand Total',
                                  style: TextStyle(
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Amount Paid',
                                  style: TextStyle(color: Colors.green)),
                              Text(
                                  '-${AppFormatters.formatCurrency(calc.paidAmount, currencyCode)}',
                                  style:
                                      const TextStyle(color: Colors.green)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Balance Due',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                  calc.balanceDue > 0 ? AppFormatters.formatCurrency(calc.balanceDue, currencyCode) : 'Paid',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: calc.balanceDue > 0 ? Colors.orange : Colors.green)),
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
                          label: const Text('Preview PDF'),
                          onPressed: () => context.push(
                              AppRoutes.invoicePreview,
                              extra: currentInvoice),
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (currentInvoice.status != InvoiceStatus.paid)
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                                backgroundColor: Colors.green),
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Mark Paid'),
                            onPressed: () {
                              context.read<InvoiceListCubit>().updateStatus(
                                  currentInvoice, InvoiceStatus.paid);
                            },
                          ),
                        )
                      else
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                                backgroundColor: Colors.orange),
                            icon: const Icon(Icons.undo),
                            label: const Text('Mark Unpaid'),
                            onPressed: () {
                              context.read<InvoiceListCubit>().updateStatus(
                                  currentInvoice, InvoiceStatus.unpaid);
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
  }
}
