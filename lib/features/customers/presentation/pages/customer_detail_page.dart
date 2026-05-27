import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/route_constants.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/widgets/global_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../invoices/domain/usecases/get_invoices_usecase.dart';
import '../../domain/entities/customer.dart';
import '../../domain/usecases/get_customers_usecase.dart';

class CustomerDetailPage extends StatefulWidget {
  final String customerId;

  const CustomerDetailPage({super.key, required this.customerId});

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  late Future<Customer> _customerFuture;

  @override
  void initState() {
    super.initState();
    _customerFuture = _loadCustomer();
  }

  Future<Customer> _loadCustomer() async {
    final getCustomers = GetIt.instance<GetCustomersUseCase>();
    final result = await getCustomers(NoParams());
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (customers) {
        final index = customers.indexWhere((c) => c.id?.toString() == widget.customerId);
        if (index == -1) throw Exception('Customer not found.');
        return customers[index];
      },
    );
  }

  // Dynamically fetch how many invoices this customer has
  Future<int> _getInvoiceCount(Customer customer) async {
    try {
      final getInvoices = GetIt.instance<GetInvoicesUseCase>();
      final result = await getInvoices(NoParams());
      return result.fold(
        (failure) => 0,
        (invoices) =>
            invoices.where((inv) => inv.customerId == customer.id).length,
      );
    } catch (_) {
      return 0; // Fail gracefully
    }
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)?.copiedToClipboard(label) ?? '$label copied to clipboard')),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, Customer customer) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)?.deleteCustomerTitle ?? 'Delete Customer?'),
          content: Text(
              AppLocalizations.of(context)?.deleteCustomerContent(customer.name) ?? 'Are you sure you want to delete ${customer.name}? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error),
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: Text(AppLocalizations.of(context)?.delete ?? 'Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true && context.mounted) {
      context.pop('delete'); // Return the delete intent to the list page
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FutureBuilder<Customer>(
      future: _customerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text(AppLocalizations.of(context)?.customerDetails ?? 'Customer Details')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: Text(AppLocalizations.of(context)?.customerDetails ?? 'Customer Details')),
            body: EmptyStateWidget(
              icon: Icons.error_outline,
              title: AppLocalizations.of(context)?.error ?? 'Customer Not Found',
              message: 'This customer may have been deleted or does not exist.',
            ),
          );
        }

        final customer = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)?.customerDetails ?? 'Customer Details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Customer',
                onPressed: () =>
                    context.pop('edit'), // Return the edit intent to the list page
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: colorScheme.error),
                tooltip: 'Delete Customer',
                onPressed: () => _showDeleteConfirmation(context, customer),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- HEADER AVATAR ---
                CircleAvatar(
                  radius: 48,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                    style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  customer.name,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),

                // --- INVOICE COUNT METRIC ---
                FutureBuilder<int>(
                  future: _getInvoiceCount(customer),
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    final isLoading =
                        snapshot.connectionState == ConnectionState.waiting;

                    return GlobalCard(
                      padding: EdgeInsets.zero,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16.0),
                        onTap: () {
                          context.push('${AppRoutes.customerInvoices}/${customer.id}');
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.md),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long_rounded,
                                  color: colorScheme.primary),
                              const SizedBox(width: 12),
                              isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))
                                  : Text(
                                      count == 1 ? '${AppLocalizations.of(context)?.totalInvoice ?? 'Total Invoice'}: $count' : '${AppLocalizations.of(context)?.totalInvoices ?? 'Total Invoices'}: $count',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                              const Spacer(),
                              Icon(Icons.chevron_right, color: theme.disabledColor),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // --- CONTACT DETAILS ---
                GlobalCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      if (customer.email != null && customer.email!.isNotEmpty) ...[
                        ListTile(
                          leading: Icon(Icons.email_outlined,
                              color: colorScheme.secondary),
                          title: Text(AppLocalizations.of(context)?.emailAddress ?? 'Email Address'),
                          subtitle: Text(customer.email!),
                          trailing: IconButton(
                            icon: const Icon(Icons.copy_rounded, size: 20),
                            tooltip: 'Copy Email',
                            onPressed: () => _copyToClipboard(context, customer.email!, AppLocalizations.of(context)?.emailAddress ?? 'Email'),
                          ),
                          onTap: () => _copyToClipboard(context, customer.email!, AppLocalizations.of(context)?.emailAddress ?? 'Email'),
                        ),
                        if (customer.phone != null && customer.phone!.isNotEmpty)
                          const Divider(height: 1),
                      ],
                      if (customer.phone != null && customer.phone!.isNotEmpty) ...[
                        ListTile(
                          leading: Icon(Icons.phone_outlined,
                              color: colorScheme.secondary),
                          title: Text(AppLocalizations.of(context)?.contactPhone ?? 'Contact Phone'),
                          subtitle: Text(customer.phone!),
                          trailing: IconButton(
                            icon: const Icon(Icons.copy_rounded, size: 20),
                            tooltip: 'Copy Phone',
                            onPressed: () => _copyToClipboard(context, customer.phone!, AppLocalizations.of(context)?.contactPhone ?? 'Phone'),
                          ),
                          onTap: () => _copyToClipboard(context, customer.phone!, AppLocalizations.of(context)?.contactPhone ?? 'Phone'),
                        ),
                        if (customer.billingAddress != null &&
                            customer.billingAddress!.isNotEmpty)
                          const Divider(height: 1),
                      ],
                      // FIX: Using billingAddress exactly as defined in your entity
                      if (customer.billingAddress != null &&
                          customer.billingAddress!.isNotEmpty)
                        ListTile(
                          leading: Icon(Icons.location_on_outlined,
                              color: colorScheme.secondary),
                          title: Text(AppLocalizations.of(context)?.billingAddress ?? 'Billing Address'),
                          subtitle: Text(customer.billingAddress!),
                        ),
                      // If all are empty, show a placeholder
                      if ((customer.email == null || customer.email!.isEmpty) &&
                          (customer.phone == null || customer.phone!.isEmpty) &&
                          (customer.billingAddress == null ||
                              customer.billingAddress!.isEmpty))
                        ListTile(
                          leading: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          title: Text(AppLocalizations.of(context)?.noContactInfo ?? 'No contact information provided.'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
