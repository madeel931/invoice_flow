import 'package:dartz/dartz.dart' show Either, Left, Right, Unit, unit;
import 'package:isar/isar.dart';

import '../../../../core/data/local/collections/customer_collection.dart';
import '../../../../core/data/local/local_database_service.dart';
import '../../../../core/errors/failures.dart';
import '../domain/entities/customer.dart';
import '../domain/repositories/customer_repository.dart';

// Mappers
extension on CustomerCollection {
  Customer toEntity() {
    return Customer(
      id: id,
      name: name,
      email: email,
      phone: phone,
      billingAddress: billingAddress,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension on Customer {
  CustomerCollection toCollection() {
    final collection = CustomerCollection()
      ..name = name
      ..email = email
      ..phone = phone
      ..billingAddress = billingAddress
      ..createdAt = createdAt ?? DateTime.now()
      ..updatedAt = DateTime.now();

    if (id != null) {
      collection.id = id!;
    }
    return collection;
  }
}

class CustomerRepositoryImpl implements CustomerRepository {
  final LocalDatabaseService localDb;

  CustomerRepositoryImpl({required this.localDb});

  @override
  Future<Either<Failure, List<Customer>>> getCustomers() async {
    try {
      final isar = localDb.db;
      // Fetch all customers, sorted alphabetically
      final collections =
          await isar.customerCollections.where().sortByName().findAll();

      final customers = collections.map((c) => c.toEntity()).toList();
      return Right(customers);
    } catch (e) {
      return Left(DatabaseFailure('Failed to fetch customers: $e'));
    }
  }

  @override
  Future<Either<Failure, Customer>> addCustomer(Customer customer) async {
    try {
      final isar = localDb.db;
      final newCollection = customer.toCollection();

      await isar.writeTxn(() async {
        await isar.customerCollections.put(newCollection);
      });

      return Right(newCollection.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to add customer: $e'));
    }
  }

  @override
  Future<Either<Failure, Customer>> updateCustomer(Customer customer) async {
    try {
      if (customer.id == null) {
        return const Left(
            ValidationFailure('Cannot update a customer without an ID.'));
      }

      final isar = localDb.db;
      final updatedCollection = customer.toCollection();

      await isar.writeTxn(() async {
        await isar.customerCollections.put(updatedCollection);
      });

      return Right(updatedCollection.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to update customer: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCustomer(int id) async {
    try {
      final isar = localDb.db;

      await isar.writeTxn(() async {
        await isar.customerCollections.delete(id);
      });

      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete customer: $e'));
    }
  }
}
