import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/primary_button.dart';
import '../../domain/entities/product.dart';

class ProductFormSheet extends StatefulWidget {
  final Product? existingProduct;

  const ProductFormSheet({super.key, this.existingProduct});

  static Future<Product?> show(BuildContext context, {Product? product}) {
    return showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ProductFormSheet(existingProduct: product),
    );
  }

  @override
  State<ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _taxRateController;

  String _selectedUnit = 'Item';
  final List<String> _unitTypes = [
    'Item',
    'Hour',
    'Day',
    'Project',
    'Kg',
    'Lbs',
    'Km',
    'Mile',
    'Custom'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingProduct?.name);
    _descriptionController =
        TextEditingController(text: widget.existingProduct?.description);

    // Format to 2 decimal places for the UI, drop trailing zeros if clean
    _priceController = TextEditingController(
      text: widget.existingProduct != null
          ? widget.existingProduct!.price.toStringAsFixed(2)
          : '',
    );
    _taxRateController = TextEditingController(
      text: widget.existingProduct?.defaultTaxRate != null
          ? widget.existingProduct!.defaultTaxRate!.toStringAsFixed(2)
          : '',
    );

    if (widget.existingProduct != null) {
      if (_unitTypes.contains(widget.existingProduct!.unitType)) {
        _selectedUnit = widget.existingProduct!.unitType;
      } else {
        _selectedUnit = 'Custom';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _taxRateController.dispose();
    super.dispose();
  }

  /// Safely parses UI numbers, handling European comma decimals.
  double? _parseDouble(String value) {
    if (value.trim().isEmpty) return null;
    final sanitized = value.replaceAll(',', '.').trim();
    return double.tryParse(sanitized);
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final parsedPrice = _parseDouble(_priceController.text);
      final parsedTax = _parseDouble(_taxRateController.text);

      if (parsedPrice == null || parsedPrice < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid price.')),
        );
        return;
      }

      final product = Product(
        id: widget.existingProduct?.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        price: parsedPrice,
        unitType: _selectedUnit,
        defaultTaxRate: parsedTax,
        createdAt: widget.existingProduct?.createdAt,
      );

      Navigator.of(context).pop(product);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: bottomInset + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existingProduct == null
                  ? 'Add Item / Service'
                  : 'Edit Item / Service',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                  labelText: 'Item Name *',
                  prefixIcon: Icon(Icons.inventory_2_outlined)),
              validator: (val) =>
                  val == null || val.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                        labelText: 'Base Price *',
                        prefixIcon: Icon(Icons.attach_money)),
                    validator: (val) =>
                        val == null || val.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex:
                      1, // Or flex: 2 if you want to give it slightly more room
                  child: DropdownButtonFormField<String>(
                    isExpanded:
                        true, // <--- THE FIX: Prevents RenderFlex overflow
                    value: _selectedUnit,
                    decoration: const InputDecoration(labelText: 'Unit'),
                    items: _unitTypes
                        .map((u) => DropdownMenuItem(
                              value: u,
                              // Added TextOverflow.ellipsis to handle long words gracefully
                              child: Text(u, overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedUnit = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _taxRateController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                  labelText: 'Default Tax Rate (%)',
                  prefixIcon: Icon(Icons.percent)),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              textInputAction: TextInputAction.done,
              maxLines: 2,
              decoration:
                  const InputDecoration(labelText: 'Description (Optional)'),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Save Item',
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
