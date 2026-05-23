import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'local_database_service.dart';
import 'collections/app_metadata_collection.dart';
import 'collections/business_profile_collection.dart';
import 'collections/customer_collection.dart';
import 'collections/product_collection.dart';
import 'collections/invoice_collection.dart';

class IsarDatabaseService implements LocalDatabaseService {
  late final Isar _isar;

  @override
  Isar get db => _isar;

  @override
  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();

    _isar = await Isar.open(
      [
        AppMetadataCollectionSchema,
        BusinessProfileCollectionSchema,
        CustomerCollectionSchema,
        ProductCollectionSchema,
        InvoiceCollectionSchema, // <-- Added Invoice Schema
      ],
      directory: dir.path,
      name: 'invoice_flow_pro_db',
      inspector: true,
    );

    await _initializeMetadataIfNeeded();
  }

  // ... (keep the exact same implementation for _initializeMetadataIfNeeded, getAppMetadata, saveAppMetadata, close)
  Future<void> _initializeMetadataIfNeeded() async {
    final count = await _isar.appMetadataCollections.count();
    if (count == 0) {
      final initialMetadata = AppMetadataCollection();
      await _isar.writeTxn(() async {
        await _isar.appMetadataCollections.put(initialMetadata);
      });
    }
  }

  @override
  Future<AppMetadataCollection?> getAppMetadata() async {
    return await _isar.appMetadataCollections.where().findFirst();
  }

  @override
  Future<void> saveAppMetadata(AppMetadataCollection metadata) async {
    await _isar.writeTxn(() async {
      await _isar.appMetadataCollections.put(metadata);
    });
  }

  @override
  Future<void> close() async {
    if (_isar.isOpen) {
      await _isar.close();
    }
  }
}
