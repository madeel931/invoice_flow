import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import '../../../../core/data/local/collections/app_metadata_collection.dart';
import '../../../../core/data/local/collections/business_profile_collection.dart';
import '../../../../core/data/local/local_database_service.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final LocalDatabaseService localDb;

  OnboardingRepositoryImpl({required this.localDb});

  @override
  Future<Either<Failure, Unit>> completeSetup({
    required String businessName,
    required String currencyCode,
  }) async {
    try {
      final isar = localDb.db;

      // ACID Compliant Transaction
      // Both operations must succeed, or neither saves.
      await isar.writeTxn(() async {
        // 1. Create and save the business profile
        final profile = BusinessProfileCollection()
          ..id = 1 // Enforce single instance
          ..businessName = businessName
          ..currencyCode = currencyCode
          ..updatedAt = DateTime.now();

        await isar.businessProfileCollections.put(profile);

        // 2. Fetch metadata, mark setup as complete, and save
        final metadata = await isar.appMetadataCollections.where().findFirst();
        if (metadata != null) {
          metadata.isFirstLaunch = false;
          await isar.appMetadataCollections.put(metadata);
        }
      });

      return const Right(unit);
    } catch (e) {
      return Left(
          DatabaseFailure('Failed to save setup data: ${e.toString()}'));
    }
  }
}
