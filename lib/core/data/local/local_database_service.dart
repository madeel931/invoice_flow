import 'package:isar/isar.dart';
import 'collections/app_metadata_collection.dart';

abstract class LocalDatabaseService {
  /// Initializes and opens the database connection
  Future<void> init();

  /// Exposes the Isar instance for complex queries within feature repositories
  Isar get db;

  /// Retrieves the application metadata (e.g., first launch status)
  Future<AppMetadataCollection?> getAppMetadata();

  /// Updates the application metadata
  Future<void> saveAppMetadata(AppMetadataCollection metadata);

  /// Closes the database connection safely
  Future<void> close();
}
