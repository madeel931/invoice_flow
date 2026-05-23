import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/presentation/widgets/surface_card.dart';
import '../../domain/entities/product.dart';
import '../cubit/product_list_cubit.dart';
import '../cubit/product_list_state.dart';
import '../widgets/product_form_sheet.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<ProductListCubit>()..loadProducts(),
      child: const _ProductsView(),
    );
  }
}

class _ProductsView extends StatefulWidget {
  const _ProductsView();

  @override
  State<_ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<_ProductsView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showProductForm([Product? product]) async {
    final result = await ProductFormSheet.show(context, product: product);
    if (result != null && mounted) {
      context.read<ProductListCubit>().saveProduct(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products & Services'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => context.read<ProductListCubit>().search(val),
              decoration: InputDecoration(
                hintText: 'Search inventory...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<ProductListCubit>().search('');
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
      body: BlocConsumer<ProductListCubit, ProductListState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Theme.of(context).colorScheme.error),
            );
          }
        },
        builder: (context, state) {
          if (state.status == ProductListStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.allProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text('Your catalog is empty.',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text('Add items or services to speed up invoicing.'),
                ],
              ),
            );
          }

          if (state.filteredProducts.isEmpty) {
            return const Center(child: Text('No matching items found.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.filteredProducts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = state.filteredProducts[index];
              return SurfaceCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  // We do not hardcode the currency symbol here since the user's currency is in Settings.
                  // For the catalog, raw formatted numbers are sufficient. Currency is appended during invoice generation.
                  subtitle: Text(
                    '${product.price.toStringAsFixed(2)} / ${product.unitType}'
                    '${product.defaultTaxRate != null ? '  •  ${product.defaultTaxRate}% Tax' : ''}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () => _showProductForm(product),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline,
                            size: 20,
                            color: Theme.of(context).colorScheme.error),
                        onPressed: () => context
                            .read<ProductListCubit>()
                            .removeProduct(product.id!),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }
}
