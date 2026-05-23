import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/presentation/widgets/primary_button.dart';
import '../../../../core/presentation/widgets/surface_card.dart';
import '../../../../core/utils/app_directories.dart';
import '../../domain/entities/business_profile.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';
import '../cubit/backup_cubit.dart';
import '../cubit/backup_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) => GetIt.instance<SettingsCubit>()..loadProfile()),
        BlocProvider(create: (_) => GetIt.instance<BackupCubit>()),
      ],
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
  final List<String> _currencies = [
    'USD',
    'EUR',
    'GBP',
    'SAR',
    'AED',
    'INR',
    'AUD',
    'CAD'
  ];

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

  Future<void> _importBackup() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null && result.files.single.path != null && mounted) {
      context.read<BackupCubit>().importData(result.files.single.path!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: MultiBlocListener(
        listeners: [
          BlocListener<SettingsCubit, SettingsState>(
            listener: (context, state) {
              if (state.status == SettingsStatus.error) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Colors.red));
              } else if (state.status == SettingsStatus.success) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Settings saved!'),
                    backgroundColor: Colors.green));
              }
            },
          ),
          BlocListener<BackupCubit, BackupState>(
            listener: (context, state) async {
              if (state.status == BackupStatus.error) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Colors.red));
              } else if (state.status == BackupStatus.success &&
                  state.backupFilePath != null) {
                final xFile = XFile(state.backupFilePath!);
                await Share.shareXFiles([xFile],
                    text: 'InvoiceFlow Pro Backup File');
              } else if (state.status == BackupStatus.restoreSuccess) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => AlertDialog(
                    title: const Text('Restore Complete!',
                        style: TextStyle(color: Colors.green)),
                    content: const Text(
                        'Your data has been successfully restored.\n\n'
                        'To prevent data corruption, you MUST force close (swipe away) '
                        'and reopen the application to load the new database safely.'),
                    actions: [
                      TextButton(
                        onPressed: () => SystemNavigator.pop(),
                        child: const Text('Close App'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            if (state.status == SettingsStatus.loading ||
                state.status == SettingsStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.profile != null) _populateForm(state.profile!);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SurfaceCard(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: _pickImage,
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1),
                                  backgroundImage:
                                      state.profile?.logoPath != null
                                          ? FileImage(File(
                                              AppDirectories.constructImagePath(
                                                  state.profile!.logoPath!)))
                                          : null,
                                  child: state.profile?.logoPath == null
                                      ? Icon(Icons.add_a_photo,
                                          size: 32,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary)
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text('Tap to upload logo',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('Business Details',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        SurfaceCard(
                          child: Column(
                            children: [
                              TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                      labelText: 'Business Name',
                                      prefixIcon: Icon(Icons.storefront)),
                                  validator: (val) =>
                                      val!.isEmpty ? 'Required' : null),
                              const SizedBox(height: 16),
                              TextFormField(
                                  controller: _taxIdController,
                                  decoration: const InputDecoration(
                                      labelText: 'Tax ID / VAT Number',
                                      prefixIcon: Icon(Icons.receipt_long))),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _selectedCurrency,
                                decoration: const InputDecoration(
                                    labelText: 'Base Currency',
                                    prefixIcon: Icon(Icons.payments)),
                                items: _currencies
                                    .map((c) => DropdownMenuItem(
                                        value: c, child: Text(c)))
                                    .toList(),
                                onChanged: (val) =>
                                    setState(() => _selectedCurrency = val!),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('Contact Information',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        SurfaceCard(
                          child: Column(
                            children: [
                              TextFormField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                      labelText: 'Email Address',
                                      prefixIcon: Icon(Icons.email_outlined))),
                              const SizedBox(height: 16),
                              TextFormField(
                                  controller: _phoneController,
                                  decoration: const InputDecoration(
                                      labelText: 'Phone Number',
                                      prefixIcon: Icon(Icons.phone_outlined))),
                              const SizedBox(height: 16),
                              TextFormField(
                                  controller: _websiteController,
                                  decoration: const InputDecoration(
                                      labelText: 'Website',
                                      prefixIcon:
                                          Icon(Icons.language_outlined))),
                              const SizedBox(height: 16),
                              TextFormField(
                                  controller: _addressController,
                                  decoration: const InputDecoration(
                                      labelText: 'Registered Address',
                                      prefixIcon: Icon(Icons.location_on)),
                                  maxLines: 3),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                            text: 'Save Profile',
                            isLoading: state.status == SettingsStatus.saving,
                            onPressed: () => _saveProfile(state.profile!)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text('Data Management',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SurfaceCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        BlocBuilder<BackupCubit, BackupState>(
                          builder: (context, backupState) {
                            final isProcessing =
                                backupState.status == BackupStatus.processing;
                            return ListTile(
                              leading: const Icon(Icons.cloud_upload_outlined),
                              title: const Text('Export Backup'),
                              subtitle:
                                  const Text('Save your database securely.'),
                              trailing: isProcessing
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))
                                  : const Icon(Icons.chevron_right),
                              onTap: isProcessing
                                  ? null
                                  : () =>
                                      context.read<BackupCubit>().exportData(),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.restore),
                          title: const Text('Restore Backup'),
                          subtitle:
                              const Text('Replace current data with backup.'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _importBackup,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
