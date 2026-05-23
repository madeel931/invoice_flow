import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';
import 'add_product_usecase.dart';

class UpdateProductUseCase implements UseCase<Product, ProductParams> {
  final ProductRepository repository;

  UpdateProductUseCase(this.repository);

  @override
  Future<Either<Failure, Product>> call(ProductParams params) async {
    if (params.product.id == null) {
      return const Left(ValidationFailure('Invalid product ID.'));
    }
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

    return await repository.updateProduct(params.product);
  }
}
