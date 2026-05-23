import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final int?
      id; // Nullable because a new customer doesn't have an ID until saved
  final String name;
  final String? email;
  final String? phone;
  final String? billingAddress;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Customer({
    this.id,
    required this.name,
    this.email,
    this.phone,
    this.billingAddress,
    this.createdAt,
    this.updatedAt,
  });

  Customer copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? billingAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      billingAddress: billingAddress ?? this.billingAddress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        billingAddress,
        createdAt,
        updatedAt,
      ];
}
