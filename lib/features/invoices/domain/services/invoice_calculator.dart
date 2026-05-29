import '../entities/invoice.dart';
import '../entities/invoice_item.dart';
import '../entities/invoice_status.dart';

class ItemCalculation {
  final InvoiceItem item;
  final double itemSubtotal;
  final double itemDiscount;
  final double itemTaxableAmount;
  final double itemTaxAmount;
  final double itemTotal;

  ItemCalculation({
    required this.item,
    required this.itemSubtotal,
    required this.itemDiscount,
    required this.itemTaxableAmount,
    required this.itemTaxAmount,
    required this.itemTotal,
  });
}

class InvoiceCalculation {
  final double subtotal;
  final double discountValue;
  final double taxableAmount;
  final double totalTax;
  final double grandTotal;
  final double paidAmount;
  final double balanceDue;
  final List<ItemCalculation> itemBreakdowns;

  InvoiceCalculation({
    required this.subtotal,
    required this.discountValue,
    required this.taxableAmount,
    required this.totalTax,
    required this.grandTotal,
    required this.paidAmount,
    required this.balanceDue,
    required this.itemBreakdowns,
  });
}

/// Centralized service for all invoice financial calculations.
/// Handles subtotals, mixed-tax distribution, and rounding rules to ensure UI and PDF match exactly.
class InvoiceCalculator {
  static double roundMoney(double value) {
    return (value * 100).roundToDouble() / 100;
  }

  /// Computes the full financial breakdown of an invoice.
  static InvoiceCalculation calculate(Invoice invoice) {
    double subtotal = 0.0;
    
    // 1. Calculate raw subtotal
    for (final item in invoice.items) {
      double rawItemSubtotal = item.quantity * item.unitPrice;
      if (rawItemSubtotal < 0) rawItemSubtotal = 0; // handle negatives
      subtotal += rawItemSubtotal;
    }
    subtotal = roundMoney(subtotal);

    // 2. Calculate discount value
    double discountValue = 0.0;
    if (invoice.discountType == 'percentage') {
      discountValue = subtotal * (invoice.discountAmount / 100);
    } else {
      discountValue = invoice.discountAmount;
    }
    
    if (discountValue < 0) discountValue = 0.0;
    if (discountValue > subtotal) discountValue = subtotal; // cap
    discountValue = roundMoney(discountValue);

    // 3. Proportional Item Allocation
    double totalTax = 0.0;
    double taxableAmount = 0.0;
    List<ItemCalculation> itemBreakdowns = [];

    for (final item in invoice.items) {
      double itemSubtotal = roundMoney(item.quantity * item.unitPrice);
      if (itemSubtotal < 0) itemSubtotal = 0;

      double itemShare = 0.0;
      if (subtotal > 0) {
        itemShare = itemSubtotal / subtotal;
      }
      
      double itemDiscount = roundMoney(discountValue * itemShare);
      double itemTaxable = itemSubtotal - itemDiscount;
      if (itemTaxable < 0) itemTaxable = 0;
      
      double itemTax = roundMoney(itemTaxable * (item.taxRate / 100));
      double itemTotal = itemTaxable + itemTax;

      totalTax += itemTax;
      taxableAmount += itemTaxable;

      itemBreakdowns.add(ItemCalculation(
        item: item,
        itemSubtotal: itemSubtotal,
        itemDiscount: itemDiscount,
        itemTaxableAmount: itemTaxable,
        itemTaxAmount: itemTax,
        itemTotal: itemTotal,
      ));
    }

    taxableAmount = roundMoney(taxableAmount);
    totalTax = roundMoney(totalTax);

    // 4. Ensure we don't drop fractional cents when distributing discounts across multiple items.
    if (itemBreakdowns.isNotEmpty && discountValue > 0) {
       double distributedDiscount = itemBreakdowns.fold(0, (sum, i) => sum + i.itemDiscount);
       double diff = roundMoney(discountValue - distributedDiscount);
       if (diff != 0) {
         // Apply remainder to the first item for simplicity
         final first = itemBreakdowns[0];
         final adjustedDiscount = roundMoney(first.itemDiscount + diff);
         final adjustedTaxable = roundMoney(first.itemSubtotal - adjustedDiscount);
         final adjustedTax = roundMoney(adjustedTaxable * (first.item.taxRate / 100));
         final adjustedTotal = adjustedTaxable + adjustedTax;
         
         itemBreakdowns[0] = ItemCalculation(
            item: first.item,
            itemSubtotal: first.itemSubtotal,
            itemDiscount: adjustedDiscount,
            itemTaxableAmount: adjustedTaxable,
            itemTaxAmount: adjustedTax,
            itemTotal: adjustedTotal,
         );
         
         // Recalculate totals
         taxableAmount = itemBreakdowns.fold(0, (sum, i) => sum + i.itemTaxableAmount);
         totalTax = itemBreakdowns.fold(0, (sum, i) => sum + i.itemTaxAmount);
       }
    }

    // 5. Grand Total & Payments
    double grandTotal = roundMoney(taxableAmount + totalTax);
    
    double paidAmount = invoice.paidAmount;

    // BUSINESS RULES FOR PAYMENT STATUS:
    if (invoice.status == InvoiceStatus.paid) {
      paidAmount = grandTotal;
    } else if (invoice.status == InvoiceStatus.unpaid) {
      paidAmount = 0.0;
    }
    // If partiallyPaid or overdue, keep the stored paidAmount
    
    if (paidAmount < 0) paidAmount = 0.0;
    if (paidAmount > grandTotal) paidAmount = grandTotal; // cap
    
    double balanceDue = roundMoney(grandTotal - paidAmount);

    return InvoiceCalculation(
      subtotal: subtotal,
      discountValue: discountValue,
      taxableAmount: taxableAmount,
      totalTax: totalTax,
      grandTotal: grandTotal,
      paidAmount: paidAmount,
      balanceDue: balanceDue,
      itemBreakdowns: itemBreakdowns,
    );
  }

  /// Determines the current status of the invoice based on payments and due date.
  static InvoiceStatus resolveStatus({
    required InvoiceStatus currentStatus,
    required DateTime dueDate,
    required double grandTotal,
    required double paidAmount,
    required double balanceDue,
  }) {
    if (currentStatus == InvoiceStatus.cancelled) return InvoiceStatus.cancelled;
    
    if (balanceDue <= 0 && grandTotal > 0) return InvoiceStatus.paid;
    if (balanceDue <= 0 && grandTotal == 0) return InvoiceStatus.paid; // Fully paid 0 total
    if (paidAmount > 0 && paidAmount < grandTotal) return InvoiceStatus.partiallyPaid;
    
    final today = DateTime.now();
    // Compare date-only values so same-day due dates remain valid and don't trigger overdue status early.
    final dateOnly = DateTime(today.year, today.month, today.day);
    final dueOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
    if (dueOnly.isBefore(dateOnly) && balanceDue > 0) return InvoiceStatus.overdue;
    
    return InvoiceStatus.unpaid;
  }
}
