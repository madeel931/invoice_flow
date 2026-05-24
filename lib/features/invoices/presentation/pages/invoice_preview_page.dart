import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:printing/printing.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
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
            return const LoadingWidget();
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isLeft()) {
            return const EmptyStateWidget(
              message: 'Failed to load business profile.',
              icon: Icons.error_outline,
            );
          }

          final profile = snapshot.data!.fold((l) => null, (r) => r);

          if (profile == null) {
            return const EmptyStateWidget(
              message: 'Profile not configured.',
              icon: Icons.domain_disabled,
            );
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
