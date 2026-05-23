import 'package:isar/isar.dart';

part 'app_metadata_collection.g.dart';

@collection
class AppMetadataCollection {
  Id id = Isar.autoIncrement;

  /// Tracks if the user has completed the initial setup/onboarding
  bool isFirstLaunch;

  /// Tracks the current database schema version for future migrations
  int schemaVersion;

  /// Timestamp of when the app was first installed/opened
  DateTime? createdAt;

  AppMetadataCollection({
    this.isFirstLaunch = true,
    this.schemaVersion = 1,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
