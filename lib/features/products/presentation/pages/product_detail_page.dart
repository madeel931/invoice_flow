import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/global_card.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../../settings/presentation/cubit/settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/product.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Item?'),
          content: Text(
              'Are you sure you want to delete "${product.name}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error),
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true && context.mounted) {
      context.pop('delete'); // Return intent to list page
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Item',
            onPressed: () => context.pop('edit'), // Return intent
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: colorScheme.error),
            tooltip: 'Delete Item',
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        bloc: GetIt.instance<SettingsCubit>(),
        builder: (context, settingsState) {
          final currencyCode = settingsState.profile?.currencyCode ?? 'AED';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- HEADER ---
                CircleAvatar(
                  radius: 48,
                  backgroundColor: colorScheme.secondaryContainer,
                  child: Icon(Icons.inventory_2_rounded,
                      size: 48, color: colorScheme.onSecondaryContainer),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  product.name,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),

                // --- PRICING CARD ---
                GlobalCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Base Price',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                          Text(
                            '${AppFormatters.formatCurrency(product.price, currencyCode)} / ${product.unitType.toLowerCase()}',
                            style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary),
                          ),
                        ],
                      ),
                      const Divider(height: AppSpacing.xl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Billing Unit'),
                          Chip(
                              label: Text(product.unitType),
                              visualDensity: VisualDensity.compact),
                        ],
                      ),
                      if (product.defaultTaxRate != null &&
                          product.defaultTaxRate! > 0) ...[
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Default Tax Rate'),
                            Text('${product.defaultTaxRate!.toStringAsFixed(1)}%',
                                style:
                                    const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // --- DESCRIPTION CARD ---
                if (product.description != null && product.description!.isNotEmpty)
                  GlobalCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.notes,
                                size: 20, color: colorScheme.secondary),
                            const SizedBox(width: AppSpacing.sm),
                            Text('Description',
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(product.description!,
                            style:
                                theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
