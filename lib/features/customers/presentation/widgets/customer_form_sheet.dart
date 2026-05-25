import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/global_button.dart';
import '../../../../core/widgets/global_text_field.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/utils/app_input_formatters.dart';
import '../../domain/entities/customer.dart';

class CustomerFormSheet extends StatefulWidget {
  final Customer? existingCustomer;

  const CustomerFormSheet({super.key, this.existingCustomer});

  static Future<Customer?> show(BuildContext context, {Customer? customer}) {
    return showModalBottomSheet<Customer>(
      context: context,
      isScrollControlled: true, // Allows sheet to expand above keyboard
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CustomerFormSheet(existingCustomer: customer),
    );
  }

  @override
  State<CustomerFormSheet> createState() => _CustomerFormSheetState();
}

class _CustomerFormSheetState extends State<CustomerFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.existingCustomer?.name);
    _emailController =
        TextEditingController(text: widget.existingCustomer?.email);
    _phoneController =
        TextEditingController(text: widget.existingCustomer?.phone);
    _addressController =
        TextEditingController(text: widget.existingCustomer?.billingAddress);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final customer = Customer(
        id: widget.existingCustomer?.id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        billingAddress: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        createdAt: widget.existingCustomer?.createdAt,
      );
      Navigator.of(context).pop(customer);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Padding logic to move the sheet up when the keyboard appears
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: bottomInset + AppSpacing.lg,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
          mainAxisSize: MainAxisSize.min, // Wrap content height
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existingCustomer == null
                  ? 'Add Customer'
                  : 'Edit Customer',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.lg),
            GlobalTextField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              label: 'Client / Company Name *',
              prefixIcon: const Icon(Icons.person),
              maxLength: 80,
              validator: (val) => AppValidators.requiredText(val, min: 2, max: 80, fieldName: 'Name'),
            ),
            const SizedBox(height: AppSpacing.md),
            GlobalTextField(
              controller: _emailController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              label: 'Email Address',
              prefixIcon: const Icon(Icons.email),
              maxLength: 120,
              validator: (val) => AppValidators.email(val, max: 120),
            ),
            const SizedBox(height: AppSpacing.md),
            GlobalTextField(
              controller: _phoneController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.phone,
              label: 'Phone Number',
              prefixIcon: const Icon(Icons.phone),
              maxLength: 20,
              inputFormatters: [AppInputFormatters.phone],
              validator: (val) => AppValidators.phone(val, max: 20),
            ),
            const SizedBox(height: AppSpacing.md),
            GlobalTextField(
              controller: _addressController,
              textInputAction: TextInputAction.done,
              maxLines: 2,
              label: 'Billing Address',
              prefixIcon: const Icon(Icons.location_city),
              maxLength: 250,
              validator: (val) => AppValidators.optionalText(val, max: 250, fieldName: 'Address'),
            ),
            const SizedBox(height: AppSpacing.xl),
            GlobalButton(
              text: 'Save Customer',
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
