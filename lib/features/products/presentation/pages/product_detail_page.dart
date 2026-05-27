import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_units.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/global_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../../settings/presentation/cubit/settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products_usecase.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Future<Product> _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture = _loadProduct();
  }

  Future<Product> _loadProduct() async {
    final getProducts = GetIt.instance<GetProductsUseCase>();
    final result = await getProducts(NoParams());
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (products) {
        final index = products.indexWhere((p) => p.id?.toString() == widget.productId);
        if (index == -1) throw Exception('Product not found.');
        return products[index];
      },
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, Product product) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)?.deleteItemTitle ?? 'Delete Item?'),
          content: Text(
              AppLocalizations.of(context)?.deleteItemContent(product.name) ?? 'Are you sure you want to delete "${product.name}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error),
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: Text(AppLocalizations.of(context)?.delete ?? 'Delete'),
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

    return FutureBuilder<Product>(
      future: _productFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text(AppLocalizations.of(context)?.itemDetails ?? 'Item Details')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: Text(AppLocalizations.of(context)?.itemDetails ?? 'Item Details')),
            body: EmptyStateWidget(
              icon: Icons.error_outline,
              title: AppLocalizations.of(context)?.error ?? 'Item Not Found',
              message: 'This item may have been deleted or does not exist.',
            ),
          );
        }

        final product = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)?.itemDetails ?? 'Item Details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Item',
                onPressed: () => context.pop('edit'), // Return intent
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: colorScheme.error),
                tooltip: 'Delete Item',
                onPressed: () => _showDeleteConfirmation(context, product),
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
                      child: Icon(AppUnits.iconOf(product.unitType),
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
                              Text(AppLocalizations.of(context)?.basePrice ?? 'Base Price',
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    '${AppFormatters.formatCurrency(product.price, currencyCode)} / ${AppUnits.localizedLabelOf(context, product.unitType)}',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: AppSpacing.xl),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(AppLocalizations.of(context)?.billingUnit ?? 'Billing Unit'),
                              Chip(
                                  label: Text(AppUnits.localizedLabelOf(context, product.unitType)),
                                  visualDensity: VisualDensity.compact),
                            ],
                          ),
                          if (product.defaultTaxRate != null &&
                              product.defaultTaxRate! > 0) ...[
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(AppLocalizations.of(context)?.defaultTaxRate ?? 'Default Tax Rate'),
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
                                Text(AppLocalizations.of(context)?.description ?? 'Description',
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
      },
    );
  }
}
