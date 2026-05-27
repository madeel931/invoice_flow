import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/global_button.dart';
import '../../../../core/widgets/global_text_field.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/utils/app_input_formatters.dart';
import '../../../../core/constants/app_units.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/invoice_item.dart';

class InvoiceItemSheet extends StatefulWidget {
  final InvoiceItem? existingItem;
  final List<Product> catalog;

  const InvoiceItemSheet({
    super.key,
    this.existingItem,
    required this.catalog,
  });

  static Future<InvoiceItem?> show(
    BuildContext context, {
    InvoiceItem? item,
    required List<Product> catalog,
  }) {
    return showModalBottomSheet<InvoiceItem>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXl)),
      ),
      builder: (_) => InvoiceItemSheet(existingItem: item, catalog: catalog),
    );
  }

  @override
  State<InvoiceItemSheet> createState() => _InvoiceItemSheetState();
}

class _InvoiceItemSheetState extends State<InvoiceItemSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _descController;
  late TextEditingController _qtyController;
  late TextEditingController _priceController;
  late TextEditingController _taxController;
  
  String _selectedUnit = AppUnits.defaultUnit;


  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    
    _descController =
        TextEditingController(text: item?.description);
    _qtyController = TextEditingController(
      text: item != null
          ? item.quantity.toStringAsFixed(2)
          : '1.00',
    );
    _priceController = TextEditingController(
      text: item != null
          ? item.unitPrice.toStringAsFixed(2)
          : '',
    );
    _taxController = TextEditingController(
      text: item != null
          ? item.taxRate.toStringAsFixed(2)
          : '',
    );
    
    if (item?.unitType != null) {
      _selectedUnit = AppUnits.normalize(item!.unitType);
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    _taxController.dispose();
    super.dispose();
  }

  double? _parseDouble(String value) {
    if (value.trim().isEmpty) return null;
    return double.tryParse(value.replaceAll(',', '.').trim());
  }

  void _onCatalogItemSelected(Product? product) {
    if (product == null) return;
    setState(() {
      _descController.text = product.name;
      _priceController.text = product.price.toStringAsFixed(2);
      _taxController.text = (product.defaultTaxRate ?? 0.0).toStringAsFixed(2);
      
      _selectedUnit = AppUnits.normalize(product.unitType);
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final parsedQty = _parseDouble(_qtyController.text) ?? 1.0;
      final parsedPrice = _parseDouble(_priceController.text) ?? 0.0;
      final parsedTax = _parseDouble(_taxController.text) ?? 0.0;

      final item = InvoiceItem(
        description: _descController.text.trim(),
        quantity: parsedQty,
        unitPrice: parsedPrice,
        taxRate: parsedTax,
        unitType: _selectedUnit,
      );
      Navigator.of(context).pop(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomInset,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existingItem == null 
                  ? AppLocalizations.of(context)?.addLineItem ?? 'Add Line Item' 
                  : AppLocalizations.of(context)?.editLineItem ?? 'Edit Line Item',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),

            // Quick Catalog Selector
            if (widget.catalog.isNotEmpty) ...[
              Autocomplete<Product>(
                displayStringForOption: (Product option) => option.name,
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return widget.catalog;
                  }
                  return widget.catalog.where((Product option) {
                    return option.name
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (Product selection) {
                  _onCatalogItemSelected(selection);
                  FocusScope.of(context).unfocus(); // Dismiss keyboard
                },
                fieldViewBuilder:
                    (context, controller, focusNode, onFieldSubmitted) {
                  return GlobalTextField(
                    controller: controller,
                    focusNode: focusNode,
                    label: AppLocalizations.of(context)?.selectSavedProduct ?? 'Search Catalog for Item',
                    prefixIcon: const Icon(Icons.search_rounded),
                    hint: AppLocalizations.of(context)?.searchSavedProducts ?? 'Type product name...',
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.md),
            ],

            GlobalTextField(
              controller: _descController,
              label: '${AppLocalizations.of(context)?.itemDescription ?? "Description"} *',
              maxLength: 100,
              validator: (val) => AppValidators.requiredText(
                val, 
                min: 2, 
                max: 100, 
                errorRequired: AppLocalizations.of(context)?.productRequired
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: GlobalTextField(
                    controller: _qtyController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    label: '${AppLocalizations.of(context)?.quantity ?? "Quantity"} *',
                    maxLength: 6,
                    inputFormatters: [AppInputFormatters.amount],
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return AppLocalizations.of(context)?.quantityRequired ?? 'Required';
                      final parsed = double.tryParse(val.replaceAll(',', '.').trim());
                      if (parsed == null) return AppLocalizations.of(context)?.invalidPrice ?? 'Enter a valid quantity';
                      if (parsed <= 0) return AppLocalizations.of(context)?.quantityRequired ?? 'Quantity must be greater than zero';
                      if (parsed > 999999) return 'Quantity is too large';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedUnit,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)?.unit ?? 'Unit'),
                    items: AppUnits.all
                        .map((u) => DropdownMenuItem(
                              value: u.value,
                              child: Text(AppUnits.localizedLabelOf(context, u.value), overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedUnit = val ?? AppUnits.defaultUnit),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: GlobalTextField(
                    controller: _priceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    label: '${AppLocalizations.of(context)?.unitPrice ?? "Unit Price"} *',
                    maxLength: 12,
                    inputFormatters: [AppInputFormatters.amount],
                    validator: (val) => AppValidators.amount(
                      val, 
                      max: 99999999.99, 
                      errorRequired: AppLocalizations.of(context)?.priceRequired,
                      errorInvalid: AppLocalizations.of(context)?.invalidPrice,
                      errorMax: AppLocalizations.of(context)?.amountTooLarge,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            GlobalTextField(
              controller: _taxController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              label: AppLocalizations.of(context)?.taxRate ?? 'Tax Rate (%)',
              maxLength: 5,
              inputFormatters: [AppInputFormatters.percentage],
              validator: (val) => AppValidators.percentage(
                val, 
                errorMax: AppLocalizations.of(context)?.taxCannotExceed100
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            GlobalButton(
              text: widget.existingItem == null
                  ? AppLocalizations.of(context)?.saveItem ?? 'Save Item'
                  : AppLocalizations.of(context)?.updateItem ?? 'Update Item', 
              onPressed: _submit
            ),
          ],
        ),
      ),
        ),
      ),
    );
  }
}
