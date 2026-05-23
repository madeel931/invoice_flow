import 'package:dartz/dartz.dart' show Either, Left, Right, Unit, unit;
import 'package:isar/isar.dart';

import '../../../../core/data/local/collections/product_collection.dart';
import '../../../../core/data/local/local_database_service.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

// Mappers
extension on ProductCollection {
  Product toEntity() {
    return Product(
      id: id,
      name: name,
      description: description,
      price: price,
      unitType: unitType,
      defaultTaxRate: defaultTaxRate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension on Product {
  ProductCollection toCollection() {
    final collection = ProductCollection()
      ..name = name
      ..description = description
      ..price = price
      ..unitType = unitType
      ..defaultTaxRate = defaultTaxRate
      ..createdAt = createdAt ?? DateTime.now()
      ..updatedAt = DateTime.now();

    if (id != null) {
      collection.id = id!;
    }
    return collection;
  }
}

class ProductRepositoryImpl implements ProductRepository {
  final LocalDatabaseService localDb;

  ProductRepositoryImpl({required this.localDb});

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      final isar = localDb.db;
      final collections =
          await isar.productCollections.where().sortByName().findAll();

      final products = collections.map((p) => p.toEntity()).toList();
      return Right(products);
    } catch (e) {
      return Left(DatabaseFailure('Failed to fetch products: $e'));
    }
  }

  @override
  Future<Either<Failure, Product>> addProduct(Product product) async {
    try {
      final isar = localDb.db;
      final newCollection = product.toCollection();

      await isar.writeTxn(() async {
        await isar.productCollections.put(newCollection);
      });

      return Right(newCollection.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to add product: $e'));
    }
  }

  @override
  Future<Either<Failure, Product>> updateProduct(Product product) async {
    try {
      if (product.id == null) {
        return const Left(
            ValidationFailure('Cannot update a product without an ID.'));
      }

      final isar = localDb.db;
      final updatedCollection = product.toCollection();

      await isar.writeTxn(() async {
        await isar.productCollections.put(updatedCollection);
      });

      return Right(updatedCollection.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to update product: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteProduct(int id) async {
    try {
      final isar = localDb.db;

      await isar.writeTxn(() async {
        await isar.productCollections.delete(id);
      });

      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete product: $e'));
    }
  }
}
