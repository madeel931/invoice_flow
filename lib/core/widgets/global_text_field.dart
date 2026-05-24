import 'package:flutter/material.dart';

class GlobalTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final int maxLines;
  final Widget? prefixIcon;
  final bool enabled;
  final bool readOnly;

  const GlobalTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.obscureText = false,
    this.maxLines = 1,
    this.prefixIcon,
    this.enabled = true,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      maxLines: maxLines,
      enabled: enabled,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
      ),
    );
  }
}
