import 'package:equatable/equatable.dart';

class InvoiceItem extends Equatable {
  final String description; // Product/Service name
  final double quantity;
  final double unitPrice;
  final double taxRate; // e.g., 15.0 for 15%
  final String? unitType; // e.g., hour, kg, piece

  const InvoiceItem({
    required this.description,
    this.quantity = 1.0,
    required this.unitPrice,
    this.taxRate = 0.0,
    this.unitType,
  });

  /// The total price for this specific line item before tax
  double get subtotal => quantity * unitPrice;

  /// The total tax amount for this specific line item
  double get taxAmount => subtotal * (taxRate / 100);

  /// The total price including tax for this line item
  double get total => subtotal + taxAmount;

  @override
  List<Object?> get props => [description, quantity, unitPrice, taxRate, unitType];
}
