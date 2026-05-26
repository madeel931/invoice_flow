// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'InvoiceFlow Pro';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get invoices => 'Invoices';

  @override
  String get customers => 'Customers';

  @override
  String get products => 'Products & Services';

  @override
  String get settings => 'Settings';

  @override
  String get businessProfile => 'Business Profile';

  @override
  String get backupRestore => 'Backup & Restore';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get create => 'Create';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get noRecentInvoices => 'No recent invoices yet.';

  @override
  String get totalRevenue => 'Total Revenue';

  @override
  String get outstandingBalance => 'Outstanding Balance';

  @override
  String get recentInvoice => 'Recent Invoice';

  @override
  String get systemDefault => 'System Default';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get chooseAppLanguage => 'Choose app language';

  @override
  String get customersTitle => 'Customers';

  @override
  String get productsTitle => 'Items & Services';

  @override
  String get invoicesTitle => 'Invoices';

  @override
  String get noCustomersYet => 'No customers yet';

  @override
  String get noCustomersSubtitle => 'Add customers to create invoices faster.';

  @override
  String get addCustomer => 'Add Customer';

  @override
  String get noProductsYet => 'No products yet';

  @override
  String get noProductsSubtitle =>
      'Add your first product or service to speed up invoice creation.';

  @override
  String get addProduct => 'Add Product';

  @override
  String get noInvoicesYet => 'No invoices yet';

  @override
  String get noInvoicesSubtitle =>
      'Create your first invoice to start tracking your business.';

  @override
  String get createInvoice => 'Create Invoice';

  @override
  String get searchCustomers => 'Search customers...';

  @override
  String get searchProducts => 'Search items...';

  @override
  String get searchInvoices => 'Search invoice # or customer...';

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusUnpaid => 'Unpaid';

  @override
  String get statusPartiallyPaid => 'Partially Paid';

  @override
  String get statusPaid => 'Paid';

  @override
  String get statusOverdue => 'Overdue';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get filterAll => 'All';

  @override
  String get filterPartial => 'Partial';

  @override
  String get viewDetails => 'View Details';

  @override
  String get viewPdf => 'View PDF';

  @override
  String get editDraft => 'Edit Draft';

  @override
  String get deleteDraft => 'Delete Draft';

  @override
  String get deletePermanently => 'Delete Permanently';

  @override
  String get markAsPaid => 'Mark as Paid';

  @override
  String get markAsUnpaid => 'Mark as Unpaid';

  @override
  String get cancelInvoice => 'Cancel Invoice';

  @override
  String get customerDeleted => 'Customer deleted successfully.';

  @override
  String get productDeleted => 'Item deleted successfully.';

  @override
  String get customerName => 'Customer Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get address => 'Address';

  @override
  String get saveCustomer => 'Save Customer';

  @override
  String get updateCustomer => 'Update Customer';

  @override
  String get customerRequired => 'Customer Name is required';

  @override
  String get invalidEmail => 'Enter a valid email address';

  @override
  String get phoneTooLong => 'Phone number is too long';

  @override
  String get addressTooLong => 'Address is too long';

  @override
  String get productName => 'Item Name';

  @override
  String get description => 'Description';

  @override
  String get basePrice => 'Base Price';

  @override
  String get billingUnit => 'Billing Unit';

  @override
  String get taxRate => 'Tax Rate (%)';

  @override
  String get saveProduct => 'Save Product';

  @override
  String get updateProduct => 'Update Product';

  @override
  String get productRequired => 'Item Name is required';

  @override
  String get priceRequired => 'Price is required';

  @override
  String get invalidPrice => 'Enter a valid price';

  @override
  String get taxCannotExceed100 => 'Tax cannot exceed 100%';

  @override
  String get addLineItem => 'Add Line Item';

  @override
  String get editLineItem => 'Edit Line Item';

  @override
  String get itemDescription => 'Item Description';

  @override
  String get quantity => 'Quantity';

  @override
  String get unitPrice => 'Unit Price';

  @override
  String get tax => 'Tax';

  @override
  String get unit => 'Unit';

  @override
  String get saveItem => 'Save Item';

  @override
  String get updateItem => 'Update Item';

  @override
  String get selectSavedProduct => 'Select Saved Product';

  @override
  String get searchSavedProducts => 'Search saved products...';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get quantityRequired => 'Quantity is required';

  @override
  String get dialogDeleteDraftTitle => 'Delete Draft?';

  @override
  String get dialogDeleteDraftMessage =>
      'This draft invoice will be permanently deleted. This action cannot be undone.';

  @override
  String get dialogDeleteDraftConfirm => 'Delete';

  @override
  String get dialogCancelInvoiceTitle => 'Cancel Invoice?';

  @override
  String get dialogCancelInvoiceMessage =>
      'This invoice will be marked as cancelled but kept for your records.';

  @override
  String get dialogCancelInvoiceConfirm => 'Cancel Invoice';

  @override
  String get dialogCancelInvoiceCancel => 'Keep Invoice';

  @override
  String get dialogDeleteCancelledTitle => 'Delete Cancelled Invoice?';

  @override
  String get dialogDeleteCancelledMessage =>
      'This will permanently delete this cancelled invoice record. This action cannot be undone.';

  @override
  String get dialogDeleteCancelledConfirm => 'Delete Permanently';
}
