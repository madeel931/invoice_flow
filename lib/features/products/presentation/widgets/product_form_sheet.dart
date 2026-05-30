import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/global_button.dart';
import '../../../../core/widgets/global_text_field.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/utils/app_input_formatters.dart';
import '../../../../core/constants/app_units.dart';
import '../../../../l10n/app_localizations.dart';
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

  String _selectedUnit = AppUnits.defaultUnit;

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
      String oldUnit = widget.existingProduct!.unitType.toLowerCase();
      if (oldUnit == 'item') oldUnit = 'piece';

      _selectedUnit = AppUnits.normalize(oldUnit);
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
          SnackBar(content: Text(AppLocalizations.of(context)?.invalidPrice ?? 'Please enter a valid price.')),
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
              widget.existingProduct == null
                  ? AppLocalizations.of(context)?.addProduct ?? 'Add Item / Service'
                  : AppLocalizations.of(context)?.updateProduct ?? 'Edit Item / Service',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.lg),
            GlobalTextField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              label: '${AppLocalizations.of(context)?.productName ?? "Item Name"} *',
              prefixIcon: const Icon(Icons.inventory_2_outlined),
              maxLength: 80,
              validator: (val) => AppValidators.requiredText(
                val, 
                min: 2, 
                max: 80, 
                errorRequired: AppLocalizations.of(context)?.productRequired
              ),
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
                    textInputAction: TextInputAction.next,
                    label: '${AppLocalizations.of(context)?.basePrice ?? "Base Price"} *',
                    prefixIcon: const Icon(Icons.attach_money),
                    maxLength: 12,
                    inputFormatters: [AppInputFormatters.amount],
                    validator: (val) => AppValidators.amount(
                      val, 
                      max: 999999999, 
                      errorRequired: AppLocalizations.of(context)?.priceRequired,
                      errorInvalid: AppLocalizations.of(context)?.invalidPrice,
                      errorMax: AppLocalizations.of(context)?.amountTooLarge,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex:
                      1, // Or flex: 2 if you want to give it slightly more room
                  child: DropdownButtonFormField<String>(
                    isExpanded:
                        true, // <--- THE FIX: Prevents RenderFlex overflow
                    initialValue: _selectedUnit,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)?.billingUnit ?? 'Unit'),
                    items: AppUnits.all
                        .map((u) => DropdownMenuItem(
                              value: u.value,
                              // Added TextOverflow.ellipsis to handle long words gracefully
                              child: Text(AppUnits.localizedLabelOf(context, u.value), overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedUnit = val ?? AppUnits.defaultUnit),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            GlobalTextField(
              controller: _taxRateController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
              label: AppLocalizations.of(context)?.taxRate ?? 'Default Tax Rate (%)',
              prefixIcon: const Icon(Icons.percent),
              maxLength: 5,
              inputFormatters: [AppInputFormatters.percentage],
              validator: (val) => AppValidators.percentage(
                val, 
                errorMax: AppLocalizations.of(context)?.taxCannotExceed100
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GlobalTextField(
              controller: _descriptionController,
              textInputAction: TextInputAction.done,
              maxLines: 2,
              label: AppLocalizations.of(context)?.description ?? 'Description (Optional)',
              maxLength: 120,
              validator: (val) => AppValidators.optionalText(val, max: 120),
            ),
            const SizedBox(height: AppSpacing.xl),
            GlobalButton(
              text: widget.existingProduct == null
                  ? AppLocalizations.of(context)?.saveProduct ?? 'Save Item'
                  : AppLocalizations.of(context)?.updateProduct ?? 'Update Item',
              onPressed: _submit,
            ),
          ],
        ),
      ),
        ),
      ),
    );
  }
}
