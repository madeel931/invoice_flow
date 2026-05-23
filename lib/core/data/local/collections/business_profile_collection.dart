import 'package:isar/isar.dart';

part 'business_profile_collection.g.dart';

@collection
class BusinessProfileCollection {
  Id id = Isar.autoIncrement; // Will always be 1 since it's a single profile

  late String businessName;

  late String currencyCode; // ISO 4217 Currency Code (e.g., USD, EUR, SAR)

  String? email;
  String? phone;
  String? website;

  String? logoPath;
  String? taxId;
  String? address;

  DateTime? updatedAt;
}
