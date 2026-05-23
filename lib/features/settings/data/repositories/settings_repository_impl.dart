import 'package:dartz/dartz.dart' show Either, Left, Right;
import 'package:isar/isar.dart';

import '../../../../core/data/local/collections/business_profile_collection.dart';
import '../../../../core/data/local/local_database_service.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/business_profile.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final LocalDatabaseService localDb;

  SettingsRepositoryImpl({required this.localDb});

  @override
  Future<Either<Failure, BusinessProfile>> getBusinessProfile() async {
    try {
      final isar = localDb.db;
      final collection =
          await isar.businessProfileCollections.where().findFirst();

      if (collection == null) {
        return const Left(DatabaseFailure('Profile not found'));
      }

      final profile = BusinessProfile(
        businessName: collection.businessName,
        currencyCode: collection.currencyCode,
        logoPath: collection.logoPath,
        taxId: collection.taxId,
        address: collection.address,
        email: collection.email, // New fields safely loaded
        phone: collection.phone,
        website: collection.website,
      );

      return Right(profile);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  // FIX: Return type is now Future<Either<Failure, BusinessProfile>>
  Future<Either<Failure, BusinessProfile>> updateBusinessProfile(
      BusinessProfile profile) async {
    try {
      final isar = localDb.db;

      final existing =
          await isar.businessProfileCollections.where().findFirst();

      final newCollection = BusinessProfileCollection()
        ..id = existing?.id ?? Isar.autoIncrement
        ..businessName = profile.businessName
        ..currencyCode = profile.currencyCode
        ..logoPath = profile.logoPath
        ..taxId = profile.taxId
        ..address = profile.address
        ..email = profile.email // New fields safely saved
        ..phone = profile.phone
        ..website = profile.website
        ..updatedAt = DateTime.now();

      await isar.writeTxn(() async {
        await isar.businessProfileCollections.put(newCollection);
      });

      // FIX: Return the updated profile instead of Unit
      return Right(profile);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
