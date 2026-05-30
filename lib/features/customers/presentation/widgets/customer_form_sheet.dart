import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/global_button.dart';
import '../../../../core/widgets/global_text_field.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/utils/app_input_formatters.dart';
import '../../../../l10n/app_localizations.dart';
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
        bottom: bottomInset,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
          mainAxisSize: MainAxisSize.min, // Wrap content height
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existingCustomer == null
                  ? AppLocalizations.of(context)?.addCustomer ?? 'Add Customer'
                  : AppLocalizations.of(context)?.updateCustomer ?? 'Edit Customer',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.lg),
            GlobalTextField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              label: '${AppLocalizations.of(context)?.customerName ?? "Customer Name"} *',
              prefixIcon: const Icon(Icons.person),
              maxLength: 80,
              validator: (val) => AppValidators.requiredText(
                val, 
                min: 2, 
                max: 80, 
                errorRequired: AppLocalizations.of(context)?.customerRequired
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GlobalTextField(
              controller: _emailController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              label: AppLocalizations.of(context)?.emailAddress ?? 'Email Address',
              prefixIcon: const Icon(Icons.email),
              maxLength: 120,
              validator: (val) => AppValidators.email(
                val, 
                max: 120, 
                errorInvalid: AppLocalizations.of(context)?.invalidEmail
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GlobalTextField(
              controller: _phoneController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.phone,
              label: AppLocalizations.of(context)?.phoneNumber ?? 'Phone Number',
              prefixIcon: const Icon(Icons.phone),
              maxLength: 30,
              inputFormatters: [AppInputFormatters.phone],
              validator: (val) => AppValidators.phone(
                val, 
                max: 30, 
                errorMaxLength: AppLocalizations.of(context)?.phoneTooLong,
                errorMinLength: AppLocalizations.of(context)?.phoneTooShort,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GlobalTextField(
              controller: _addressController,
              textInputAction: TextInputAction.done,
              maxLines: 2,
              label: AppLocalizations.of(context)?.address ?? 'Billing Address',
              prefixIcon: const Icon(Icons.location_city),
              maxLength: 250,
              validator: (val) => AppValidators.optionalText(
                val, 
                max: 250, 
                errorMaxLength: AppLocalizations.of(context)?.addressTooLong
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            GlobalButton(
              text: widget.existingCustomer == null
                  ? AppLocalizations.of(context)?.saveCustomer ?? 'Save Customer'
                  : AppLocalizations.of(context)?.updateCustomer ?? 'Update Customer',
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
