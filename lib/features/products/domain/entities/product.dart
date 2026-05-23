import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int? id;
  final String name;
  final String? description;
  final double price;
  final String unitType;
  final double? defaultTaxRate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
    this.id,
    required this.name,
    this.description,
    required this.price,
    required this.unitType,
    this.defaultTaxRate,
    this.createdAt,
    this.updatedAt,
  });

  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? unitType,
    double? defaultTaxRate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      unitType: unitType ?? this.unitType,
      defaultTaxRate: defaultTaxRate ?? this.defaultTaxRate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        unitType,
        defaultTaxRate,
        createdAt,
        updatedAt,
      ];
}
