import 'package:isar/isar.dart';

part 'customer_collection.g.dart';

@collection
class CustomerCollection {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value) // Indexed for fast alphabetical sorting
  late String name;

  String? email;
  String? phone;
  String? billingAddress;

  DateTime? createdAt;
  DateTime? updatedAt;
}
