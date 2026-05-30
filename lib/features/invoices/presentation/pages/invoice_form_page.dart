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
import '../../../products/presentation/cubit/product_list_state.dart';
import '../../domain/entities/invoice_item.dart';
import '../cubit/invoice_form_cubit.dart';
import '../cubit/invoice_form_state.dart';
import '../../domain/services/invoice_calculator.dart';
import '../widgets/invoice_item_sheet.dart';
import '../../../../core/utils/app_input_formatters.dart';
import '../../../../l10n/app_localizations.dart';

class InvoiceFormPage extends StatelessWidget {
  final String? existingInvoiceId;
  const InvoiceFormPage({super.key, this.existingInvoiceId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) {
          final profileCurrency =
              GetIt.instance<SettingsCubit>().state.profile?.currencyCode ??
                  'AED';
          return GetIt.instance<InvoiceFormCubit>()
            ..initForm(defaultCurrencyCode: profileCurrency, existingInvoiceId: existingInvoiceId);
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
  bool _isWalkIn = false;
  bool _hasUserSelectedDueDate = false;

  String _getLocalizedError(BuildContext context, String error) {
    final loc = AppLocalizations.of(context);
    switch (error) {
      case 'err_invoice_number_exists': return loc?.errInvoiceNumberExists ?? 'An invoice with this number already exists.';
      case 'err_invoice_number_required': return loc?.errInvoiceNumberRequired ?? 'Invoice number is required and max 40 characters.';
      case 'err_due_date_invalid': return loc?.errDueDateInvalid ?? 'Due date cannot be before issue date.';
      case 'err_no_items': return loc?.errNoItems ?? 'An invoice must have at least one line item.';
      case 'err_discount_negative': return loc?.errDiscountNegative ?? 'Discount cannot be negative.';
      case 'err_discount_exceeds_subtotal': return loc?.errDiscountExceedsSubtotal ?? 'Discount cannot exceed the invoice subtotal.';
      case 'err_discount_exceeds_100': return loc?.errDiscountExceeds100 ?? 'Discount percentage cannot exceed 100%.';
      case 'err_paid_amount_negative': return loc?.errPaidAmountNegative ?? 'Paid amount cannot be negative.';
      case 'err_paid_amount_exceeds_total': return loc?.errPaidAmountExceedsTotal ?? 'Paid amount cannot exceed grand total.';
      case 'err_item_desc_invalid': return loc?.errItemDescInvalid ?? 'Item description is required and max 120 characters.';
      case 'err_item_qty_invalid': return loc?.errItemQtyInvalid ?? 'Quantity must be greater than 0 and max 999999.';
      case 'err_item_price_invalid': return loc?.errItemPriceInvalid ?? 'Unit price must be >= 0 and max 999999999.';
      case 'err_item_tax_invalid': return loc?.errItemTaxInvalid ?? 'Tax rate must be between 0 and 100.';
      default: return error;
    }
  }

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
    if (picked != null) {
      if (!context.mounted) return;
      if (isIssueDate) {
        DateTime newDueDate = context.read<InvoiceFormCubit>().state.draftInvoice!.dueDate;
        if (!_hasUserSelectedDueDate || newDueDate.isBefore(picked)) {
          newDueDate = picked;
        }
        context.read<InvoiceFormCubit>().updateDates(issueDate: picked, dueDate: newDueDate);
      } else {
        _hasUserSelectedDueDate = true;
        context.read<InvoiceFormCubit>().updateDates(dueDate: picked);
      }
    }
  }

  Future<void> _openItemSheet([InvoiceItem? existingItem, int? index]) async {
    final productCubit = context.read<ProductListCubit>();
    if (productCubit.state.status != ProductListStatus.loaded) {
      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
      await productCubit.loadProducts();
      if (!mounted) return;
      Navigator.pop(context);
    }
    if (!mounted) return;
    
    final catalog = productCubit.state.allProducts;
    final result = await InvoiceItemSheet.show(context,
        item: existingItem, catalog: catalog);

    if (result != null) {
      if (!mounted) return;
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
                  content: Text(_getLocalizedError(context, state.errorMessage!)),
                  backgroundColor: Theme.of(context).colorScheme.error));
            }
            if (state.status == InvoiceFormStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(AppLocalizations.of(context)?.invoiceSaved ?? 'Invoice saved!'),
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
              _isWalkIn = invoice.customerId == 0;
              _controllersInitialized = true;
            }

            return Scaffold(
              appBar: AppBar(
                title: Text(invoice.invoiceNumber),
                actions: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8.0),
                    child: TextButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(invoice.id == null 
                          ? AppLocalizations.of(context)?.create ?? 'Create' 
                          : AppLocalizations.of(context)?.save ?? 'Save'),
                      onPressed: () {
                        if (!_isWalkIn && invoice.customerId == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    AppLocalizations.of(context)?.selectCustomerOrWalkIn ?? 'Please select a saved customer or switch to Walk-in.')),
                          );
                          return;
                        }
                        if (invoice.items.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    AppLocalizations.of(context)?.cannotSaveInvoice ?? 'Add at least one item before creating invoice.')),
                          );
                          return;
                        }
                        context
                            .read<InvoiceFormCubit>()
                            .saveIssuedInvoice();
                      },
                    ),
                  ),
                ],
              ),
              // FIX: Wait for Products and Customers to finish loading from DB before showing form
              body: Builder(builder: (context) {
                final custState = context.watch<CustomerListCubit>().state;
                const walkInCustomer =
                    Customer(id: 0, name: 'Walk-in Customer');
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
                            SegmentedButton<bool>(
                              segments: [
                                ButtonSegment(
                                    value: false, 
                                    label: FittedBox(fit: BoxFit.scaleDown, child: Text(AppLocalizations.of(context)?.savedCustomer ?? 'Saved Customer'))),
                                ButtonSegment(
                                    value: true, 
                                    label: FittedBox(fit: BoxFit.scaleDown, child: Text(AppLocalizations.of(context)?.walkInCustomer ?? 'Walk-in Customer'))),
                              ],
                              selected: {_isWalkIn},
                              onSelectionChanged: (Set<bool> newSelection) {
                                setState(() {
                                  _isWalkIn = newSelection.first;
                                });
                                if (_isWalkIn) {
                                  context.read<InvoiceFormCubit>().updateCustomer(const Customer(id: 0, name: 'Walk-in Customer'));
                                } else {
                                  context.read<InvoiceFormCubit>().updateCustomer(const Customer(id: 0, name: ''));
                                }
                              },
                            ),
                            if (!_isWalkIn) ...[
                              const SizedBox(height: 16),
                              Autocomplete<Customer>(
                                initialValue:
                                    TextEditingValue(text: invoice.customerName == 'Walk-in Customer' ? '' : invoice.customerName),
                                displayStringForOption: (Customer option) =>
                                    option.name,
                                optionsBuilder:
                                    (TextEditingValue textEditingValue) {
                                  if (textEditingValue.text.isEmpty) {
                                    return availableCustomers.where((c) => c.id != 0);
                                  }
                                  return availableCustomers
                                      .where((c) => c.id != 0)
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
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)?.selectCustomer ?? 'Search & Select Customer',
                                      prefixIcon:
                                          const Icon(Icons.person_search_rounded),
                                      hintText: AppLocalizations.of(context)?.searchCustomer ?? 'Type to search...',
                                    ),
                                  );
                                },
                              ),
                            ],
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ListTile(
                                    title: Text(AppLocalizations.of(context)?.issueDate ?? 'Issue Date',
                                        style: const TextStyle(
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
                                    title: Text(AppLocalizations.of(context)?.dueDate ?? 'Due Date',
                                        style: const TextStyle(
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
                      Text(AppLocalizations.of(context)?.invoiceItems ?? 'Line Items',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (invoice.items.isEmpty)
                        GlobalCard(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                              child: Text(AppLocalizations.of(context)?.noItemsAdded ?? 'No items added yet.',
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
                        label: Text(AppLocalizations.of(context)?.addLineItem ?? 'Add Line Item'),
                      ),
                      const SizedBox(height: 24),
                      GlobalCard(
                        child: Column(
                          children: [
                            SegmentedButton<String>(
                              segments: [
                                ButtonSegment(
                                    value: 'amount', label: Text(AppLocalizations.of(context)?.discountAmount ?? 'Amount')),
                                ButtonSegment(
                                    value: 'percentage',
                                    label: Text(AppLocalizations.of(context)?.discountPercentage ?? 'Percentage')),
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
                              maxLength: invoice.discountType == 'percentage' ? 6 : 12,
                              inputFormatters: [AppInputFormatters.amount],
                              decoration: InputDecoration(
                                  counterText: '',
                                  labelText:
                                      invoice.discountType == 'percentage'
                                          ? AppLocalizations.of(context)?.discountPercentage ?? 'Discount Percentage (%)'
                                          : AppLocalizations.of(context)?.discountAmount ?? 'Discount Amount (-)',
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
                                if (parsed < 0) return AppLocalizations.of(context)?.cannotBeNegative ?? 'Cannot be negative';
                                if (invoice.discountType == 'percentage' &&
                                    parsed > 100) {
                                  return AppLocalizations.of(context)?.cannotExceed100 ?? 'Cannot exceed 100%';
                                }
                                final calc =
                                    InvoiceCalculator.calculate(invoice);
                                if (invoice.discountType == 'amount' &&
                                    parsed > calc.subtotal) {
                                  return AppLocalizations.of(context)?.cannotExceedSubtotal ?? 'Cannot exceed subtotal';
                                }
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
                              decoration: InputDecoration(
                                  counterText: '',
                                  labelText: AppLocalizations.of(context)?.paidAmount ?? 'Paid Amount',
                                  prefixIcon: const Icon(Icons.payments)),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (val) {
                                final parsed = double.tryParse(
                                        val?.replaceAll(',', '.') ?? '') ??
                                    0.0;
                                if (parsed < 0) return AppLocalizations.of(context)?.cannotBeNegative ?? 'Cannot be negative';
                                final calc =
                                    InvoiceCalculator.calculate(invoice);
                                if (parsed > calc.grandTotal) {
                                  return AppLocalizations.of(context)?.cannotExceedGrandTotal ?? 'Cannot exceed grand total';
                                }
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
                              decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)?.notesPaymentTerms ?? 'Notes / Payment Terms',
                                  prefixIcon: const Icon(Icons.notes)),
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
                    // Live-calculate totals so the user sees real-time impact of discounts/taxes.
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
                              Text('${AppLocalizations.of(context)?.subtotal ?? "Subtotal"}:',
                                  style: const TextStyle(color: Colors.grey)),
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
                                        ? '${AppLocalizations.of(context)?.discount ?? "Discount"} (${invoice.discountAmount}%):'
                                        : '${AppLocalizations.of(context)?.discount ?? "Discount"}:',
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
                              Text('${AppLocalizations.of(context)?.tax ?? "Total Tax"}:',
                                  style: const TextStyle(color: Colors.grey)),
                              Text(
                                  '+ ${AppFormatters.formatCurrency(calc.totalTax, currencyCode)}')
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text((AppLocalizations.of(context)?.grandTotal ?? 'TOTAL').toUpperCase(),
                                  style: const TextStyle(
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
                                Text('${AppLocalizations.of(context)?.amountPaid ?? "Amount Paid"}:',
                                    style: const TextStyle(color: Colors.green)),
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
                              Text('${AppLocalizations.of(context)?.balanceDue ?? "Balance Due"}:',
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
                            text: AppLocalizations.of(context)?.saveAsDraft ?? 'Save as Draft',
                            isLoading:
                                invoiceState.status == InvoiceFormStatus.saving,
                            onPressed: invoice.items.isEmpty
                                ? null
                                : () => context
                                    .read<InvoiceFormCubit>()
                                    .saveDraft(),
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
