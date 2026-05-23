import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class AddProductUseCase implements UseCase<Product, ProductParams> {
  final ProductRepository repository;

  AddProductUseCase(this.repository);

  @override
  Future<Either<Failure, Product>> call(ProductParams params) async {
    // Crucial Domain-Level Financial Validation
    if (params.product.name.trim().isEmpty) {
      return const Left(ValidationFailure('Product name cannot be empty.'));
    }
    if (params.product.price < 0) {
      return const Left(ValidationFailure('Price cannot be negative.'));
    }
    if (params.product.defaultTaxRate != null &&
        params.product.defaultTaxRate! < 0) {
      return const Left(ValidationFailure('Tax rate cannot be negative.'));
    }

    return await repository.addProduct(params.product);
  }
}

class ProductParams extends Equatable {
  final Product product;

  const ProductParams({required this.product});

  @override
  List<Object> get props => [product];
}
