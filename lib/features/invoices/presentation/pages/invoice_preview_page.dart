import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:printing/printing.dart';

import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../settings/domain/usecases/get_business_profile_usecase.dart';
import '../../utils/invoice_pdf_generator.dart';
import '../cubit/invoice_list_cubit.dart';

class InvoicePreviewPage extends StatefulWidget {
  final String invoiceId;

  const InvoicePreviewPage({super.key, required this.invoiceId});

  @override
  State<InvoicePreviewPage> createState() => _InvoicePreviewPageState();
}

class _InvoicePreviewPageState extends State<InvoicePreviewPage> {
  late final Future<Uint8List> _pdfFuture;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<InvoiceListCubit>();
    _pdfFuture = _generatePdf(cubit);
  }

  Future<Uint8List> _generatePdf(InvoiceListCubit cubit) async {
    final profileResult = await GetIt.instance<GetBusinessProfileUseCase>().call(NoParams());
    
    if (profileResult.isLeft()) {
      throw Exception('Failed to load business profile.');
    }
    
    final profile = profileResult.fold((l) => null, (r) => r);
    if (profile == null) {
      throw Exception('Profile not configured.');
    }
    
    // Find invoice in cubit
    final invoices = cubit.state.allInvoices;
    final invoiceIndex = invoices.indexWhere((i) => i.id?.toString() == widget.invoiceId);
    if (invoiceIndex == -1) {
      throw Exception('Invoice not found.');
    }
    final invoice = invoices[invoiceIndex];
    
    final bytes = await InvoicePdfGenerator.generate(invoice, profile);
    if (bytes.isEmpty) {
      throw Exception('Generated PDF is empty');
    }
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice PDF'),
      ),
      body: FutureBuilder<Uint8List>(
        future: _pdfFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingWidget();
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const EmptyStateWidget(
              message: 'Failed to generate PDF.',
              icon: Icons.error_outline,
            );
          }

          final pdfBytes = snapshot.data!;
          final theme = Theme.of(context);
          final invoices = context.read<InvoiceListCubit>().state.allInvoices;
          final invoiceIndex = invoices.indexWhere((i) => i.id?.toString() == widget.invoiceId);
          if (invoiceIndex == -1) {
            return const EmptyStateWidget(
              message: 'Invoice not found.',
              icon: Icons.error_outline,
            );
          }
          final invoice = invoices[invoiceIndex];

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.picture_as_pdf,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'PDF Ready',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Invoice ${invoice.invoiceNumber} for ${invoice.customerName} has been generated successfully.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 48),
                FilledButton.icon(
                  onPressed: () async {
                    await Printing.layoutPdf(
                      onLayout: (_) async => pdfBytes,
                      name: 'invoice_${invoice.invoiceNumber}.pdf',
                    );
                  },
                  icon: const Icon(Icons.print),
                  label: const Text('Print PDF'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    await Printing.sharePdf(
                      bytes: pdfBytes,
                      filename: 'invoice_${invoice.invoiceNumber}.pdf',
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share PDF'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
