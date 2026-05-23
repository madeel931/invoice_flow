import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/primary_button.dart';
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
        left: 24,
        right: 24,
        top: 24,
        bottom: bottomInset + 24,
      ),
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
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                  labelText: 'Client / Company Name *',
                  prefixIcon: Icon(Icons.person)),
              validator: (val) =>
                  val == null || val.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  labelText: 'Email Address', prefixIcon: Icon(Icons.email)),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                  labelText: 'Phone Number', prefixIcon: Icon(Icons.phone)),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              textInputAction: TextInputAction.done,
              maxLines: 2,
              decoration: const InputDecoration(
                  labelText: 'Billing Address',
                  prefixIcon: Icon(Icons.location_city)),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Save Customer',
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
