import 'package:isar/isar.dart';

part 'product_collection.g.dart';

@collection
class ProductCollection {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String name;

  String? description;

  /// Stored as a double. In the presentation layer, we will format this
  /// precisely to the user's localized currency decimal limits.
  late double price;

  /// e.g., "Item", "Hour", "Project", "Kg"
  late String unitType;

  /// Default tax percentage applied to this item (e.g., 15.0 for 15%)
  double? defaultTaxRate;

  DateTime? createdAt;
  DateTime? updatedAt;
}
