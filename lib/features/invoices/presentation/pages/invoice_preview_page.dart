import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../settings/domain/usecases/get_business_profile_usecase.dart';
import '../../utils/arabic_invoice_pdf_generator.dart';
import '../../utils/invoice_pdf_generator.dart';
import '../../../../core/locale/cubit/locale_cubit.dart';
import '../../../../l10n/app_localizations.dart';
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
    final languageCode = context.read<LocaleCubit>().state?.languageCode ?? 'en';
    _pdfFuture = _generatePdf(cubit, languageCode);
  }

  Future<Uint8List> _generatePdf(InvoiceListCubit cubit, String languageCode) async {
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
    
    final bytes = languageCode == 'ar'
        ? await ArabicInvoicePdfGenerator.generate(invoice, profile)
        : await InvoicePdfGenerator.generate(invoice, profile);
        
    if (bytes.isEmpty) {
      throw Exception('Generated PDF is empty');
    }
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    final invoices = context.read<InvoiceListCubit>().state.allInvoices;
    final invoiceIndex = invoices.indexWhere((i) => i.id?.toString() == widget.invoiceId);
    final invoiceNumber = invoiceIndex != -1 ? invoices[invoiceIndex].invoiceNumber : widget.invoiceId;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.invoicePdf ?? 'Invoice PDF'),
      ),
      body: PdfPreview(
        build: (format) => _pdfFuture,
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        initialPageFormat: PdfPageFormat.a4,
        pdfFileName: 'invoice_$invoiceNumber.pdf',
        loadingWidget: const LoadingWidget(),
        onError: (context, error) => const EmptyStateWidget(
          message: 'Failed to generate PDF.',
          icon: Icons.error_outline,
        ),
      ),
    );
  }
}
