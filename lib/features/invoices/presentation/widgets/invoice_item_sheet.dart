import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/primary_button.dart';
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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

  Product? _selectedCatalogItem;

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
      _selectedCatalogItem = product;
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
          left: 24, right: 24, top: 24, bottom: bottomInset + 24),
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
            const SizedBox(height: 16),

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
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Search Catalog for Item',
                      prefixIcon: Icon(Icons.search_rounded),
                      hintText: 'Type product name...',
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
            ],

            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description *'),
              validator: (val) =>
                  val == null || val.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _qtyController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Quantity *'),
                    validator: (val) =>
                        val == null || val.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'Unit Price *'),
                    validator: (val) =>
                        val == null || val.trim().isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _taxController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Tax Rate (%)'),
            ),
            const SizedBox(height: 32),
            PrimaryButton(text: 'Save Item', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
