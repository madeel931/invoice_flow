import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/global_card.dart';
import '../../../../core/widgets/global_button.dart';
import '../cubit/backup_cubit.dart';
import '../cubit/backup_state.dart';

class BackupRestorePage extends StatelessWidget {
  const BackupRestorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: GetIt.instance<BackupCubit>(),
      child: const _BackupRestoreView(),
    );
  }
}

class _BackupRestoreView extends StatefulWidget {
  const _BackupRestoreView();

  @override
  State<_BackupRestoreView> createState() => _BackupRestoreViewState();
}

class _BackupRestoreViewState extends State<_BackupRestoreView> {
  bool _restoreCompleted = false;

  Future<void> _confirmExport() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Backup?'),
        content: const Text(
            'This will export your local InvoiceFlow Pro data into a backup file that you can store safely.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Create Backup'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      context.read<BackupCubit>().exportData();
    }
  }

  // Restore is destructive to local data. We force confirmation before even opening the file picker.
  Future<void> _confirmRestoreWarning() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Backup?'),
        content: const Text(
            'Restoring a backup may replace your current local data. Create a fresh backup before continuing.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Choose Backup'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _pickBackupFile();
    }
  }

  Future<void> _pickBackupFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['isar'],
    );

    if (result != null && result.files.single.path != null && mounted) {
      final String path = result.files.single.path!;
      
      if (!path.toLowerCase().endsWith('.isar')) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select a valid InvoiceFlow Pro backup file.'),
          backgroundColor: AppColors.error,
        ));
        return;
      }

      final file = File(path);
      if (!await file.exists()) {
         if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                 content: Text('Could not access the selected backup file.'),
                 backgroundColor: AppColors.error,
              ));
         }
         return;
      }

      await _confirmSelectedFile(path);
    }
  }

  Future<void> _confirmSelectedFile(String path) async {
    final fileName = path.split(Platform.pathSeparator).last;
    
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Restore'),
        content: Text(
            'Backup file selected: $fileName\n\nRestoring will replace your current local database. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Restore Now'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      context.read<BackupCubit>().importData(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    // If restore is complete, block the back button. The app must be restarted to safely load the new database instance.
    return PopScope(
      canPop: !_restoreCompleted,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Backup & Restore'),
          automaticallyImplyLeading: !_restoreCompleted,
        ),
        body: BlocListener<BackupCubit, BackupState>(
          listener: (context, state) async {
            if (state.status == BackupStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: AppColors.error,
              ));
            } else if (state.status == BackupStatus.success) {
              if (state.backupFilePath == null || state.backupFilePath!.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Backup created but file path is missing.'),
                  backgroundColor: AppColors.error,
                ));
                return;
              }
              try {
                final box = context.findRenderObject() as RenderBox?;
                final origin = box != null
                    ? box.localToGlobal(Offset.zero) & box.size
                    : null;
                
                final xFile = XFile(state.backupFilePath!);
                await Share.shareXFiles(
                  [xFile],
                  text: 'InvoiceFlow Pro Backup',
                  sharePositionOrigin: origin,
                );
                if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                     content: Text('Backup created successfully.'),
                     backgroundColor: AppColors.success,
                   ));
                }
              } catch (e) {
                // Catch share failures (e.g., iPad share sheet cancellation bugs) and show path as fallback
                if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                     content: Text('Backup created but sharing failed. File path: ${state.backupFilePath}'),
                     backgroundColor: AppColors.error,
                   ));
                }
              }
            } else if (state.status == BackupStatus.restoreSuccess) {
              setState(() {
                _restoreCompleted = true;
              });
            }
          },
          child: _restoreCompleted 
            ? _buildRestartRequiredView() 
            : _buildMainView(),
        ),
      ),
    );
  }

  Widget _buildRestartRequiredView() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.success,
            size: 80,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Restore Completed',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Your backup was restored successfully. Please restart the app to load restored data safely.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (Platform.isIOS) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Close InvoiceFlow Pro from the app switcher and reopen it.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
          GlobalButton(
            text: 'Close App',
            onPressed: () {
              SystemNavigator.pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlobalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Data Management',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Keep your data safe by exporting backups regularly. You can restore your data on any device.',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GlobalCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                BlocBuilder<BackupCubit, BackupState>(
                  builder: (context, backupState) {
                    final isProcessing = backupState.status == BackupStatus.processing;
                    return Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.cloud_upload_outlined, color: Theme.of(context).colorScheme.primary),
                          title: const Text('Export Backup'),
                          subtitle: const Text('Save your database securely.'),
                          trailing: const Icon(Icons.chevron_right),
                          enabled: !isProcessing,
                          onTap: isProcessing ? null : _confirmExport,
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.restore, color: Theme.of(context).colorScheme.error),
                          title: const Text('Restore Backup'),
                          subtitle: const Text('Replace current data with backup.'),
                          trailing: const Icon(Icons.chevron_right),
                          enabled: !isProcessing,
                          onTap: isProcessing ? null : _confirmRestoreWarning,
                        ),
                        if (isProcessing) ...[
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Text(
                                  'Processing backup request...',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GlobalCard(
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Restore may replace existing local data. Keep a safe backup before importing.',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
