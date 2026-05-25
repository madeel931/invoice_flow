import 'package:flutter/material.dart';
import 'package:currency_picker/currency_picker.dart';

class AppCurrencyPickerField extends StatelessWidget {
  final String? selectedCurrencyCode;
  final ValueChanged<String> onChanged;
  final String label;
  final String? errorText;

  const AppCurrencyPickerField({
    super.key,
    required this.selectedCurrencyCode,
    required this.onChanged,
    this.label = 'Currency',
    this.errorText,
  });

  String _getDisplayString() {
    if (selectedCurrencyCode == null || selectedCurrencyCode!.trim().isEmpty) {
      return '';
    }
    
    final String code = selectedCurrencyCode!.trim().toUpperCase();
    try {
      final Currency? currency = CurrencyService().findByCode(code);
      if (currency != null) {
        return '${currency.code} - ${currency.name}';
      }
    } catch (e) {
      // Ignored
    }
    return code;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: () {
        showCurrencyPicker(
          context: context,
          showFlag: true,
          showCurrencyName: true,
          showCurrencyCode: true,
          onSelect: (Currency currency) {
            onChanged(currency.code.toUpperCase());
          },
        );
      },
      child: IgnorePointer(
        child: TextFormField(
          key: ValueKey(selectedCurrencyCode),
          initialValue: _getDisplayString(),
          readOnly: true,
          decoration: InputDecoration(
            labelText: label,
            errorText: errorText,
            suffixIcon: Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
