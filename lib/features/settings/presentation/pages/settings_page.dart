import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/global_button.dart';
import '../../../../core/widgets/global_card.dart';
import '../../../../core/presentation/widgets/app_currency_picker_field.dart';
import '../../../../core/widgets/global_text_field.dart';
import '../../../../core/utils/app_directories.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/utils/app_input_formatters.dart';
import '../../domain/entities/business_profile.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: GetIt.instance<SettingsCubit>(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatefulWidget {
  const _SettingsView();

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _taxIdController;
  late TextEditingController _addressController;

  // ADDED: Contact Controllers
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _websiteController;

  String _selectedCurrency = 'USD';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _taxIdController = TextEditingController();
    _addressController = TextEditingController();

    // FIX: Initialize the new controllers
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _websiteController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taxIdController.dispose();
    _addressController.dispose();

    // FIX: Dispose the new controllers to prevent memory leaks
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _populateForm(BusinessProfile profile) {
    if (_nameController.text.isEmpty) {
      _nameController.text = profile.businessName;
      _taxIdController.text = profile.taxId ?? '';
      _addressController.text = profile.address ?? '';

      // FIX: Populate contact fields
      _emailController.text = profile.email ?? '';
      _phoneController.text = profile.phone ?? '';
      _websiteController.text = profile.website ?? '';

      _selectedCurrency = profile.currencyCode;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      context.read<SettingsCubit>().pickAndSaveLogo(pickedFile.path);
    }
  }

  void _saveProfile(BusinessProfile currentProfile) {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      final updatedProfile = currentProfile.copyWith(
        businessName: _nameController.text.trim(),
        taxId: _taxIdController.text.trim(),
        address: _addressController.text.trim(),
        currencyCode: _selectedCurrency,
        // FIX: Save contact fields
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        website: _websiteController.text.trim(),
      );
      context.read<SettingsCubit>().saveSettings(updatedProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocListener<SettingsCubit, SettingsState>(
        listener: (context, state) {
          if (state.status == SettingsStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error));
          } else if (state.status == SettingsStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Settings saved!'),
                backgroundColor: AppColors.success));
          }
        },
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            if (state.status == SettingsStatus.loading ||
                state.status == SettingsStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.profile != null) _populateForm(state.profile!);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GlobalCard(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: state.status == SettingsStatus.saving
                                    ? null
                                    : _pickImage,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.1),
                                      backgroundImage: state
                                                  .profile?.logoPath !=
                                              null
                                          ? FileImage(File(
                                              AppDirectories.constructImagePath(
                                                  state.profile!.logoPath!)))
                                          : null,
                                      child: state.profile?.logoPath == null &&
                                              state.status !=
                                                  SettingsStatus.saving
                                          ? Icon(Icons.add_a_photo,
                                              size: 32,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary)
                                          : null,
                                    ),
                                    // ADDED: Circular progress indicator overlaid on the avatar during compression
                                    if (state.status == SettingsStatus.saving)
                                      Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.3),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                              color: Colors.white),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text('Tap to upload logo',
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text('Business Details',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: AppSpacing.sm),
                        GlobalCard(
                          child: Column(
                            children: [
                              GlobalTextField(
                                  controller: _nameController,
                                  label: 'Business Name',
                                  prefixIcon: const Icon(Icons.storefront),
                                  maxLength: 100,
                                  validator: (val) => AppValidators.requiredText(val, min: 2, max: 100, fieldName: 'Business Name')),
                              const SizedBox(height: AppSpacing.md),
                              GlobalTextField(
                                  controller: _taxIdController,
                                  label: 'Tax ID / VAT Number',
                                  prefixIcon: const Icon(Icons.receipt_long),
                                  maxLength: 40,
                                  validator: (val) => AppValidators.optionalText(val, max: 40, fieldName: 'Tax ID')),
                              const SizedBox(height: AppSpacing.md),
                              AppCurrencyPickerField(
                                label: 'Base Currency',
                                selectedCurrencyCode: _selectedCurrency,
                                onChanged: (val) =>
                                    setState(() => _selectedCurrency = val),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text('Contact Information',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: AppSpacing.sm),
                        GlobalCard(
                          child: Column(
                            children: [
                              GlobalTextField(
                                  controller: _emailController,
                                  label: 'Email Address',
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  maxLength: 120,
                                  validator: (val) => AppValidators.email(val, max: 120)),
                              const SizedBox(height: AppSpacing.md),
                              GlobalTextField(
                                  controller: _phoneController,
                                  label: 'Phone Number',
                                  prefixIcon: const Icon(Icons.phone_outlined),
                                  maxLength: 20,
                                  inputFormatters: [AppInputFormatters.phone],
                                  validator: (val) => AppValidators.phone(val, max: 20)),
                              const SizedBox(height: AppSpacing.md),
                              GlobalTextField(
                                  controller: _websiteController,
                                  label: 'Website',
                                  prefixIcon:
                                      const Icon(Icons.language_outlined),
                                  maxLength: 100,
                                  validator: (val) => AppValidators.optionalText(val, max: 100, fieldName: 'Website')),
                              const SizedBox(height: AppSpacing.md),
                              GlobalTextField(
                                  controller: _addressController,
                                  label: 'Registered Address',
                                  prefixIcon: const Icon(Icons.location_on),
                                  maxLines: 3,
                                  maxLength: 250,
                                  validator: (val) => AppValidators.optionalText(val, max: 250, fieldName: 'Address')),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        GlobalButton(
                            text: 'Save Profile',
                            isLoading: state.status == SettingsStatus.saving,
                            onPressed: () => _saveProfile(state.profile!)),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
