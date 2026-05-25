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
import '../../../products/presentation/cubit/product_list_cubit.dart';
import '../../domain/entities/invoice_item.dart';
import '../../domain/entities/invoice_status.dart';
import '../cubit/invoice_form_cubit.dart';
import '../cubit/invoice_form_state.dart';
import '../../domain/services/invoice_calculator.dart';
import '../widgets/invoice_item_sheet.dart';
import '../../../../core/utils/app_input_formatters.dart';

class InvoiceFormPage extends StatelessWidget {
  const InvoiceFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) {
          final profileCurrency =
              GetIt.instance<SettingsCubit>().state.profile?.currencyCode ??
                  'AED';
          return GetIt.instance<InvoiceFormCubit>()
            ..initForm(defaultCurrencyCode: profileCurrency);
        }),
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
  final _paidAmountController = TextEditingController();
  final _notesController = TextEditingController();
  final _dateFormat = DateFormat('MMM dd, yyyy');
  bool _controllersInitialized = false;

  @override
  void dispose() {
    _discountController.dispose();
    _paidAmountController.dispose();
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
        if (!context.mounted) return;
        context.read<InvoiceFormCubit>().updateDates(issueDate: picked);
      } else {
        if (!context.mounted) return;
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
        final profileCurrency = settingsState.profile?.currencyCode ?? 'AED';

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

            final invoice = invoiceState.draftInvoice;
            if (invoice == null) {
              return const Scaffold(
                  body: Center(child: Text('Draft invoice is unavailable.')));
            }
            final currencyCode = invoice.currencyCode?.trim().isNotEmpty == true
                ? invoice.currencyCode!
                : profileCurrency;

            if (!_controllersInitialized) {
              if (invoice.discountAmount > 0) {
                _discountController.text = invoice.discountAmount.toString();
              }
              if (invoice.paidAmount > 0) {
                _paidAmountController.text = invoice.paidAmount.toString();
              }
              if (invoice.notes != null) {
                _notesController.text = invoice.notes!;
              }
              _controllersInitialized = true;
            }

            return Scaffold(
              appBar: AppBar(
                title: Text(invoice.invoiceNumber),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    onPressed: () {
                      if (invoice.items.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Add at least one item before creating invoice.')),
                        );
                        return;
                      }
                      context
                          .read<InvoiceFormCubit>()
                          .saveInvoice(InvoiceStatus.unpaid);
                    },
                  ),
                ],
              ),
              // FIX: Wait for Products and Customers to finish loading from DB before showing form
              body: Builder(builder: (context) {
                final custState = context.watch<CustomerListCubit>().state;
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
                                    '${item.quantity}${item.unitType != null ? ' ${item.unitType!.toLowerCase()}' : ''} x ${AppFormatters.formatCurrency(item.unitPrice, currencyCode)}   (Tax: ${item.taxRate}%)'),
                                trailing: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 150),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                          AppFormatters.formatCurrency(
                                              item.total, currencyCode),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                    )),
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
                            SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(
                                    value: 'amount', label: Text('Amount')),
                                ButtonSegment(
                                    value: 'percentage',
                                    label: Text('Percentage')),
                              ],
                              selected: {invoice.discountType},
                              onSelectionChanged: (Set<String> newSelection) {
                                context
                                    .read<InvoiceFormCubit>()
                                    .updateDiscountType(newSelection.first);
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _discountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              maxLength: 12,
                              inputFormatters: [AppInputFormatters.amount],
                              decoration: InputDecoration(
                                  labelText:
                                      invoice.discountType == 'percentage'
                                          ? 'Discount Percentage (%)'
                                          : 'Discount Amount (-)',
                                  prefixIcon:
                                      invoice.discountType == 'percentage'
                                          ? const Icon(Icons.percent)
                                          : const Icon(Icons.money_off)),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (val) {
                                final parsed = double.tryParse(
                                        val?.replaceAll(',', '.') ?? '') ??
                                    0.0;
                                if (parsed < 0) return 'Cannot be negative';
                                if (invoice.discountType == 'percentage' &&
                                    parsed > 100) return 'Cannot exceed 100%';
                                final calc =
                                    InvoiceCalculator.calculate(invoice);
                                if (invoice.discountType == 'amount' &&
                                    parsed > calc.subtotal)
                                  return 'Cannot exceed subtotal';
                                return null;
                              },
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
                              controller: _paidAmountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              maxLength: 12,
                              inputFormatters: [AppInputFormatters.amount],
                              decoration: const InputDecoration(
                                  labelText: 'Paid Amount',
                                  prefixIcon: Icon(Icons.payments)),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (val) {
                                final parsed = double.tryParse(
                                        val?.replaceAll(',', '.') ?? '') ??
                                    0.0;
                                if (parsed < 0) return 'Cannot be negative';
                                final calc =
                                    InvoiceCalculator.calculate(invoice);
                                if (parsed > calc.grandTotal)
                                  return 'Cannot exceed grand total';
                                return null;
                              },
                              onChanged: (val) {
                                final parsed =
                                    double.tryParse(val.replaceAll(',', '.')) ??
                                        0.0;
                                context
                                    .read<InvoiceFormCubit>()
                                    .updatePaidAmount(parsed);
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _notesController,
                              maxLines: 2,
                              maxLength: 500,
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
                child: Builder(
                  builder: (context) {
                    final calc = InvoiceCalculator.calculate(invoice);
                    return Container(
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
                                  calc.subtotal, currencyCode))
                            ],
                          ),
                          if (calc.discountValue > 0) ...[
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    invoice.discountType == 'percentage'
                                        ? 'Discount (${invoice.discountAmount}%):'
                                        : 'Discount:',
                                    style: const TextStyle(color: Colors.red)),
                                Text(
                                    '- ${AppFormatters.formatCurrency(calc.discountValue, currencyCode)}',
                                    style: const TextStyle(color: Colors.red))
                              ],
                            ),
                          ],
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Tax:',
                                  style: TextStyle(color: Colors.grey)),
                              Text(
                                  '+ ${AppFormatters.formatCurrency(calc.totalTax, currencyCode)}')
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('TOTAL',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                              const SizedBox(width: 16),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                      AppFormatters.formatCurrency(
                                          calc.grandTotal, currencyCode),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary)),
                                ),
                              ),
                            ],
                          ),
                          if (calc.paidAmount > 0) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Amount Paid:',
                                    style: TextStyle(color: Colors.green)),
                                Text(
                                    '- ${AppFormatters.formatCurrency(calc.paidAmount, currencyCode)}',
                                    style: const TextStyle(color: Colors.green))
                              ],
                            ),
                          ],
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Balance Due:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: calc.balanceDue > 0
                                          ? Colors.orange
                                          : null)),
                              Text(
                                  AppFormatters.formatCurrency(
                                      calc.balanceDue, currencyCode),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: calc.balanceDue > 0
                                          ? Colors.orange
                                          : null))
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
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
