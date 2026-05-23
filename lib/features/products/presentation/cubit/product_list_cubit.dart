import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/add_product_usecase.dart';
import '../../domain/usecases/delete_product_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';
import 'product_list_state.dart';

class ProductListCubit extends Cubit<ProductListState> {
  final GetProductsUseCase getProducts;
  final AddProductUseCase addProduct;
  final UpdateProductUseCase updateProduct;
  final DeleteProductUseCase deleteProduct;

  ProductListCubit({
    required this.getProducts,
    required this.addProduct,
    required this.updateProduct,
    required this.deleteProduct,
  }) : super(const ProductListState());

  Future<void> loadProducts() async {
    emit(state.copyWith(status: ProductListStatus.loading));

    final result = await getProducts(NoParams());

    result.fold(
      (failure) => emit(state.copyWith(
        status: ProductListStatus.error,
        errorMessage: failure.message,
      )),
      (products) => emit(state.copyWith(
        status: ProductListStatus.loaded,
        allProducts: products,
        filteredProducts: _filter(products, state.searchQuery),
      )),
    );
  }

  void search(String query) {
    emit(state.copyWith(
      searchQuery: query,
      filteredProducts: _filter(state.allProducts, query),
    ));
  }

  List<Product> _filter(List<Product> list, String query) {
    if (query.trim().isEmpty) return list;
    final lowerQuery = query.toLowerCase();
    return list.where((p) {
      return p.name.toLowerCase().contains(lowerQuery) ||
          (p.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  Future<void> saveProduct(Product product) async {
    final isUpdate = product.id != null;

    final result = isUpdate
        ? await updateProduct(ProductParams(product: product))
        : await addProduct(ProductParams(product: product));

    result.fold(
      (failure) => emit(state.copyWith(
        status: ProductListStatus.error,
        errorMessage: failure.message,
      )),
      (savedProduct) {
        final updatedList = List<Product>.from(state.allProducts);
        if (isUpdate) {
          final index = updatedList.indexWhere((p) => p.id == savedProduct.id);
          if (index != -1) updatedList[index] = savedProduct;
        } else {
          updatedList.add(savedProduct);
          updatedList.sort((a, b) => a.name.compareTo(b.name));
        }

        emit(state.copyWith(
          status: ProductListStatus.loaded,
          allProducts: updatedList,
          filteredProducts: _filter(updatedList, state.searchQuery),
        ));
      },
    );
  }

  Future<void> removeProduct(int id) async {
    final result = await deleteProduct(DeleteProductParams(id: id));

    result.fold(
      (failure) => emit(state.copyWith(
        status: ProductListStatus.error,
        errorMessage: failure.message,
      )),
      (_) {
        final updatedList = state.allProducts.where((p) => p.id != id).toList();
        emit(state.copyWith(
          status: ProductListStatus.loaded,
          allProducts: updatedList,
          filteredProducts: _filter(updatedList, state.searchQuery),
        ));
      },
    );
  }
}
