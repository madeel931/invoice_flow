import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/global_button.dart';
import '../../../../core/widgets/global_text_field.dart';
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


  @override
  void initState() {
    super.initState();
    _descController =
        TextEditingController(text: widget.existingItem?.description);
    _qtyController = TextEditingController(
      text: widget.existingItem != null
          ? widget.existingItem!.quantity.toStringAsFixed(2)
          : '1.00',
    );
    _priceController = TextEditingController(
      text: widget.existingItem != null
          ? widget.existingItem!.unitPrice.toStringAsFixed(2)
          : '',
    );
    _taxController = TextEditingController(
      text: widget.existingItem != null
          ? widget.existingItem!.taxRate.toStringAsFixed(2)
          : '0.00',
    );
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
      _taxController.text =
          product.defaultTaxRate?.toStringAsFixed(2) ?? '0.00';
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final qty = _parseDouble(_qtyController.text) ?? 1.0;
      final price = _parseDouble(_priceController.text) ?? 0.0;
      final tax = _parseDouble(_taxController.text) ?? 0.0;

      final item = InvoiceItem(
        description: _descController.text.trim(),
        quantity: qty,
        unitPrice: price,
        taxRate: tax,
      );
      Navigator.of(context).pop(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
          left: AppSpacing.lg, right: AppSpacing.lg, top: AppSpacing.lg, bottom: bottomInset + AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existingItem == null ? 'Add Line Item' : 'Edit Line Item',
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
                    label: 'Search Catalog for Item',
                    prefixIcon: const Icon(Icons.search_rounded),
                    hint: 'Type product name...',
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.md),
            ],

            GlobalTextField(
              controller: _descController,
              label: 'Description *',
              validator: (val) =>
                  val == null || val.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: GlobalTextField(
                    controller: _qtyController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    label: 'Quantity *',
                    validator: (val) =>
                        val == null || val.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: GlobalTextField(
                    controller: _priceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    label: 'Unit Price *',
                    validator: (val) =>
                        val == null || val.trim().isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            GlobalTextField(
              controller: _taxController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              label: 'Tax Rate (%)',
            ),
            const SizedBox(height: AppSpacing.xl),
            GlobalButton(text: 'Save Item', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
