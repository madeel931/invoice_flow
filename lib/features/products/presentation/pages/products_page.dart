import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/route_constants.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/global_card.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../domain/entities/product.dart';
import '../cubit/product_list_cubit.dart';
import '../cubit/product_list_state.dart';
import '../widgets/product_form_sheet.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => GetIt.instance<ProductListCubit>()..loadProducts(),
        ),
        BlocProvider.value(
          value: GetIt.instance<SettingsCubit>(),
        ),
      ],
      child: const _ProductsListView(),
    );
  }
}

class _ProductsListView extends StatefulWidget {
  const _ProductsListView();

  @override
  State<_ProductsListView> createState() => _ProductsListViewState();
}

class _ProductsListViewState extends State<_ProductsListView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Uses your exact static show() method
  Future<void> _openProductForm(BuildContext context,
      {Product? product}) async {
    final result = await ProductFormSheet.show(context, product: product);

    if (result != null && context.mounted) {
      context.read<ProductListCubit>().saveProduct(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyCode = context.watch<SettingsCubit>().state.profile?.currencyCode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Items & Services'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => context.read<ProductListCubit>().search(val),
              decoration: InputDecoration(
                hintText: 'Search items...',
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
      body: BlocBuilder<ProductListCubit, ProductListState>(
        builder: (context, state) {
          if (state.status == ProductListStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.filteredProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.5)),
                  const SizedBox(height: AppSpacing.md),
                  const Text('No items found.'),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: state.filteredProducts.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final product = state.filteredProducts[index];

              return GlobalCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    child: Icon(Icons.sell_outlined,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        size: 20),
                  ),
                  title: Text(product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      '${AppFormatters.formatCurrency(product.price, currencyCode)} • ${product.unitType}'),
                  trailing: const Icon(Icons.chevron_right_rounded),

                  // --- INTERACTION LOGIC ---
                  onTap: () async {
                    final intent = await context.push(AppRoutes.productDetail,
                        extra: product);

                    if (!context.mounted) return;

                    if (intent == 'delete') {
                      // Uses your exact removeProduct(int id) method
                      context
                          .read<ProductListCubit>()
                          .removeProduct(product.id!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Item deleted successfully.')),
                      );
                    } else if (intent == 'edit') {
                      _openProductForm(context, product: product);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'product_add_fab',
        onPressed: () => _openProductForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
