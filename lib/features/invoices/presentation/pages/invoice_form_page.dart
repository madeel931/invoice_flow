import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/formatters.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../../settings/presentation/cubit/settings_state.dart';
import '../../../../core/widgets/global_button.dart';
import '../../../../core/widgets/global_card.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../customers/presentation/cubit/customer_list_cubit.dart';
import '../../../customers/presentation/cubit/customer_list_state.dart';
import '../../../products/presentation/cubit/product_list_cubit.dart';
import '../../../products/presentation/cubit/product_list_state.dart';
import '../../domain/entities/invoice_item.dart';
import '../../domain/entities/invoice_status.dart';
import '../cubit/invoice_form_cubit.dart';
import '../cubit/invoice_form_state.dart';
import '../widgets/invoice_item_sheet.dart';

class InvoiceFormPage extends StatelessWidget {
  const InvoiceFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) => GetIt.instance<InvoiceFormCubit>()..initForm()),
        BlocProvider(
            create: (_) =>
                GetIt.instance<CustomerListCubit>()..loadCustomers()),
        BlocProvider(
            create: (_) => GetIt.instance<ProductListCubit>()..loadProducts()),
      ],
      child: const _InvoiceFormView(),
    );
  }
}

class _InvoiceFormView extends StatefulWidget {
  const _InvoiceFormView();

  @override
  State<_InvoiceFormView> createState() => _InvoiceFormViewState();
}

class _InvoiceFormViewState extends State<_InvoiceFormView> {
  final _discountController = TextEditingController();
  final _notesController = TextEditingController();
  final _dateFormat = DateFormat('MMM dd, yyyy');

  @override
  void dispose() {
    _discountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
      BuildContext context, bool isIssueDate, DateTime currentDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      if (isIssueDate) {
        context.read<InvoiceFormCubit>().updateDates(issueDate: picked);
      } else {
        context.read<InvoiceFormCubit>().updateDates(dueDate: picked);
      }
    }
  }

  Future<void> _openItemSheet([InvoiceItem? existingItem, int? index]) async {
    // FIX: Get the catalog directly. By the time they click this, the builder guarantees it's loaded.
    final catalog = context.read<ProductListCubit>().state.allProducts;
    final result = await InvoiceItemSheet.show(context,
        item: existingItem, catalog: catalog);

    if (result != null && mounted) {
      if (index != null) {
        context.read<InvoiceFormCubit>().updateLineItem(index, result);
      } else {
        context.read<InvoiceFormCubit>().addLineItem(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      bloc: GetIt.instance<SettingsCubit>(),
      builder: (context, settingsState) {
        final currencyCode = settingsState.profile?.currencyCode ?? 'AED';

        return BlocConsumer<InvoiceFormCubit, InvoiceFormState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Theme.of(context).colorScheme.error));
            }
            if (state.status == InvoiceFormStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Invoice saved!'),
                  backgroundColor: Colors.green));
              context.pop();
            }
          },
          builder: (context, invoiceState) {
            if (invoiceState.status == InvoiceFormStatus.loading ||
                invoiceState.status == InvoiceFormStatus.initial) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }

            final invoice = invoiceState.draftInvoice!;

            return Scaffold(
              appBar: AppBar(
                title: Text(invoice.invoiceNumber),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    onPressed: () => context
                        .read<InvoiceFormCubit>()
                        .saveInvoice(InvoiceStatus.paid),
                  ),
                ],
              ),
              // FIX: Wait for Products and Customers to finish loading from DB before showing form
              body: Builder(builder: (context) {
                final prodState = context.watch<ProductListCubit>().state;
                final custState = context.watch<CustomerListCubit>().state;

                if (prodState.status == ProductListStatus.loading ||
                    custState.status == CustomerListStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // FIX: Add Walk-In Customer to the list natively
                final walkInCustomer =
                    const Customer(id: 0, name: 'Walk-in Customer');
                final availableCustomers = [
                  walkInCustomer,
                  ...custState.allCustomers
                ];

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GlobalCard(
                        child: Column(
                          children: [
                            Autocomplete<Customer>(
                              initialValue:
                                  TextEditingValue(text: invoice.customerName),
                              displayStringForOption: (Customer option) =>
                                  option.name,
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                if (textEditingValue.text.isEmpty) {
                                  return availableCustomers;
                                }
                                return availableCustomers
                                    .where((Customer option) {
                                  return option.name.toLowerCase().contains(
                                      textEditingValue.text.toLowerCase());
                                });
                              },
                              onSelected: (Customer selection) {
                                context
                                    .read<InvoiceFormCubit>()
                                    .updateCustomer(selection);
                                FocusScope.of(context)
                                    .unfocus(); // Dismiss keyboard
                              },
                              fieldViewBuilder: (context, controller, focusNode,
                                  onFieldSubmitted) {
                                return TextFormField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  decoration: const InputDecoration(
                                    labelText: 'Search & Select Customer',
                                    prefixIcon:
                                        Icon(Icons.person_search_rounded),
                                    hintText: 'Type to search...',
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ListTile(
                                    title: const Text('Issue Date',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey)),
                                    subtitle: Text(
                                        _dateFormat.format(invoice.issueDate),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    onTap: () => _selectDate(
                                        context, true, invoice.issueDate),
                                  ),
                                ),
                                Expanded(
                                  child: ListTile(
                                    title: const Text('Due Date',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey)),
                                    subtitle: Text(
                                        _dateFormat.format(invoice.dueDate),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    onTap: () => _selectDate(
                                        context, false, invoice.dueDate),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Line Items',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (invoice.items.isEmpty)
                        GlobalCard(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                              child: Text('No items added yet.',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.5)))),
                        )
                      else
                        ...invoice.items.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: GlobalCard(
                              padding: EdgeInsets.zero,
                              child: ListTile(
                                title: Text(item.description,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                    '${item.quantity} x ${AppFormatters.formatCurrency(item.unitPrice, currencyCode)}   (Tax: ${item.taxRate}%)'),
                                trailing: Text(
                                    AppFormatters.formatCurrency(
                                        item.total, currencyCode),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                onTap: () => _openItemSheet(item, index),
                                onLongPress: () => context
                                    .read<InvoiceFormCubit>()
                                    .removeLineItem(index),
                              ),
                            ),
                          );
                        }),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _openItemSheet,
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Add Line Item'),
                      ),
                      const SizedBox(height: 24),
                      GlobalCard(
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _discountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: const InputDecoration(
                                  labelText: 'Discount Amount (-)',
                                  prefixIcon: Icon(Icons.money_off)),
                              onChanged: (val) {
                                final parsed =
                                    double.tryParse(val.replaceAll(',', '.')) ??
                                        0.0;
                                context
                                    .read<InvoiceFormCubit>()
                                    .updateDiscount(parsed);
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _notesController,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                  labelText: 'Notes / Payment Terms',
                                  prefixIcon: Icon(Icons.notes)),
                              onChanged: (val) => context
                                  .read<InvoiceFormCubit>()
                                  .updateNotes(val),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              bottomNavigationBar: SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5))
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal:',
                              style: TextStyle(color: Colors.grey)),
                          Text(AppFormatters.formatCurrency(
                              invoice.subtotal, currencyCode))
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Tax:',
                              style: TextStyle(color: Colors.grey)),
                          Text(
                              '+ ${AppFormatters.formatCurrency(invoice.totalTax, currencyCode)}')
                        ],
                      ),
                      if (invoice.discountAmount > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Discount:',
                                style: TextStyle(color: Colors.red)),
                            Text(
                                '- ${AppFormatters.formatCurrency(invoice.discountAmount, currencyCode)}',
                                style: const TextStyle(color: Colors.red))
                          ],
                        ),
                      ],
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('TOTAL',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                          Text(
                              AppFormatters.formatCurrency(
                                  invoice.totalAmount, currencyCode),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  color:
                                      Theme.of(context).colorScheme.primary)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GlobalButton(
                        text: 'Save as Draft',
                        isLoading:
                            invoiceState.status == InvoiceFormStatus.saving,
                        onPressed: invoice.items.isEmpty
                            ? null
                            : () => context
                                .read<InvoiceFormCubit>()
                                .saveInvoice(InvoiceStatus.draft),
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
