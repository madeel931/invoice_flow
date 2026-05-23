import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';

enum ProductListStatus { initial, loading, loaded, error }

class ProductListState extends Equatable {
  final ProductListStatus status;
  final List<Product> allProducts;
  final List<Product> filteredProducts;
  final String? errorMessage;
  final String searchQuery;

  const ProductListState({
    this.status = ProductListStatus.initial,
    this.allProducts = const [],
    this.filteredProducts = const [],
    this.errorMessage,
    this.searchQuery = '',
  });

  ProductListState copyWith({
    ProductListStatus? status,
    List<Product>? allProducts,
    List<Product>? filteredProducts,
    String? errorMessage,
    String? searchQuery,
  }) {
    return ProductListState(
      status: status ?? this.status,
      allProducts: allProducts ?? this.allProducts,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      errorMessage: errorMessage, // Intentionally nullable
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allProducts,
        filteredProducts,
        errorMessage,
        searchQuery,
      ];
}
