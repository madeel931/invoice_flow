import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:printing/printing.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../settings/domain/usecases/get_business_profile_usecase.dart';
import '../../domain/entities/invoice.dart';
import '../../utils/invoice_pdf_generator.dart';

class InvoicePreviewPage extends StatelessWidget {
  final Invoice invoice;

  const InvoicePreviewPage({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview ${invoice.invoiceNumber}'),
      ),
      body: FutureBuilder(
        // Fetch the BusinessProfile dynamically to pass into the PDF Engine
        future: GetIt.instance<GetBusinessProfileUseCase>().call(NoParams()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isLeft()) {
            return const Center(
                child: Text('Failed to load business profile.'));
          }

          final profile = snapshot.data!.fold((l) => null, (r) => r);

          if (profile == null) {
            return const Center(child: Text('Profile not configured.'));
          }

          return PdfPreview(
            build: (format) => InvoicePdfGenerator.generate(invoice, profile),
            canChangeOrientation: false,
            canChangePageFormat: false,
            canDebug: false,
            pdfFileName:
                '${invoice.invoiceNumber}_${invoice.customerName.replaceAll(' ', '_')}.pdf',
          );
        },
      ),
    );
  }
}
