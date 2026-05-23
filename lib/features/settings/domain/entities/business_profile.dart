import 'package:equatable/equatable.dart';

class BusinessProfile extends Equatable {
  final String businessName;
  final String currencyCode;
  final String? logoPath;
  final String? taxId;
  final String? address;

  // ADDED: Contact Fields
  final String? email;
  final String? phone;
  final String? website;

  const BusinessProfile({
    required this.businessName,
    required this.currencyCode,
    this.logoPath,
    this.taxId,
    this.address,
    this.email,
    this.phone,
    this.website,
  });

  BusinessProfile copyWith({
    String? businessName,
    String? currencyCode,
    String? logoPath,
    String? taxId,
    String? address,
    String? email,
    String? phone,
    String? website,
  }) {
    return BusinessProfile(
      businessName: businessName ?? this.businessName,
      currencyCode: currencyCode ?? this.currencyCode,
      logoPath: logoPath ?? this.logoPath,
      taxId: taxId ?? this.taxId,
      address: address ?? this.address,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      website: website ?? this.website,
    );
  }

  @override
  List<Object?> get props => [
        businessName,
        currencyCode,
        logoPath,
        taxId,
        address,
        email,
        phone,
        website,
      ];
}
