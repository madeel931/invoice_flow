import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('ur')
  ];

  /// Label or text for app name
  ///
  /// In en, this message translates to:
  /// **'InvoiceFlow Pro'**
  String get appName;

  /// Label or text for dashboard
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Label or text for invoices
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get invoices;

  /// Label or text for customers
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// Label or text for products
  ///
  /// In en, this message translates to:
  /// **'Products & Services'**
  String get products;

  /// Label or text for items nav label
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get itemsNavLabel;

  /// Label or text for settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Label or text for business profile
  ///
  /// In en, this message translates to:
  /// **'Business Profile'**
  String get businessProfile;

  /// Label or text for backup restore
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupRestore;

  /// Label or text for language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Label or text for english
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Label or text for arabic
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// Label or text for save
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Label or text for cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Label or text for create
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Label or text for edit
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Label or text for delete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Label or text for no recent invoices
  ///
  /// In en, this message translates to:
  /// **'No recent invoices yet.'**
  String get noRecentInvoices;

  /// Label or text for total revenue
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// Label or text for outstanding balance
  ///
  /// In en, this message translates to:
  /// **'Outstanding Balance'**
  String get outstandingBalance;

  /// Label or text for recent invoice
  ///
  /// In en, this message translates to:
  /// **'Recent Invoice'**
  String get recentInvoice;

  /// Label or text for system default
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// Label or text for language settings
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// Label or text for choose app language
  ///
  /// In en, this message translates to:
  /// **'Choose app language'**
  String get chooseAppLanguage;

  /// Label or text for customers title
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customersTitle;

  /// Label or text for products title
  ///
  /// In en, this message translates to:
  /// **'Items & Services'**
  String get productsTitle;

  /// Label or text for invoices title
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get invoicesTitle;

  /// Label or text for no customers yet
  ///
  /// In en, this message translates to:
  /// **'No customers yet'**
  String get noCustomersYet;

  /// Label or text for no customers subtitle
  ///
  /// In en, this message translates to:
  /// **'Add customers to create invoices faster.'**
  String get noCustomersSubtitle;

  /// Label or text for add customer
  ///
  /// In en, this message translates to:
  /// **'Add Customer'**
  String get addCustomer;

  /// Label or text for no products yet
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get noProductsYet;

  /// Label or text for no products subtitle
  ///
  /// In en, this message translates to:
  /// **'Add your first product or service to speed up invoice creation.'**
  String get noProductsSubtitle;

  /// Label or text for add product
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// Label or text for no invoices yet
  ///
  /// In en, this message translates to:
  /// **'No invoices yet'**
  String get noInvoicesYet;

  /// Label or text for no invoices subtitle
  ///
  /// In en, this message translates to:
  /// **'Create your first invoice to start tracking your business.'**
  String get noInvoicesSubtitle;

  /// Label or text for create invoice
  ///
  /// In en, this message translates to:
  /// **'Create Invoice'**
  String get createInvoice;

  /// Search hint input label for customers
  ///
  /// In en, this message translates to:
  /// **'Search customers...'**
  String get searchCustomers;

  /// Search hint input label for products
  ///
  /// In en, this message translates to:
  /// **'Search items...'**
  String get searchProducts;

  /// Search hint input label for invoices
  ///
  /// In en, this message translates to:
  /// **'Search invoices...'**
  String get searchInvoices;

  /// Status label for draft
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// Status label for unpaid
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get statusUnpaid;

  /// Status label for partiallypaid
  ///
  /// In en, this message translates to:
  /// **'Partially Paid'**
  String get statusPartiallyPaid;

  /// Status label for paid
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// Status label for overdue
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get statusOverdue;

  /// Status label for cancelled
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// Label or text for filter all
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Label or text for filter partial
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get filterPartial;

  /// Label or text for view details
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// Label or text for view pdf
  ///
  /// In en, this message translates to:
  /// **'View PDF'**
  String get viewPdf;

  /// Label or text for edit draft
  ///
  /// In en, this message translates to:
  /// **'Edit Draft'**
  String get editDraft;

  /// Label or text for delete draft
  ///
  /// In en, this message translates to:
  /// **'Delete Draft'**
  String get deleteDraft;

  /// Label or text for delete permanently
  ///
  /// In en, this message translates to:
  /// **'Delete Permanently'**
  String get deletePermanently;

  /// Label or text for mark as paid
  ///
  /// In en, this message translates to:
  /// **'Mark as Paid'**
  String get markAsPaid;

  /// Label or text for mark as unpaid
  ///
  /// In en, this message translates to:
  /// **'Mark as Unpaid'**
  String get markAsUnpaid;

  /// Label or text for cancel invoice
  ///
  /// In en, this message translates to:
  /// **'Cancel Invoice'**
  String get cancelInvoice;

  /// Label or text for customer deleted
  ///
  /// In en, this message translates to:
  /// **'Customer deleted successfully.'**
  String get customerDeleted;

  /// Label or text for product deleted
  ///
  /// In en, this message translates to:
  /// **'Item deleted successfully.'**
  String get productDeleted;

  /// Label or text for customer name
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customerName;

  /// Label or text for phone number
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// Label or text for email address
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// Label or text for address
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// Label or text for save customer
  ///
  /// In en, this message translates to:
  /// **'Save Customer'**
  String get saveCustomer;

  /// Label or text for update customer
  ///
  /// In en, this message translates to:
  /// **'Update Customer'**
  String get updateCustomer;

  /// Label or text for customer required
  ///
  /// In en, this message translates to:
  /// **'Customer Name is required'**
  String get customerRequired;

  /// Label or text for invalid email
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get invalidEmail;

  /// Label or text for phone too long
  ///
  /// In en, this message translates to:
  /// **'Phone number is too long'**
  String get phoneTooLong;

  /// Label or text for address too long
  ///
  /// In en, this message translates to:
  /// **'Address is too long'**
  String get addressTooLong;

  /// Label or text for product name
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get productName;

  /// Label or text for description
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Label or text for base price
  ///
  /// In en, this message translates to:
  /// **'Base Price'**
  String get basePrice;

  /// Label or text for billing unit
  ///
  /// In en, this message translates to:
  /// **'Billing Unit'**
  String get billingUnit;

  /// Label or text for tax rate
  ///
  /// In en, this message translates to:
  /// **'Tax Rate (%)'**
  String get taxRate;

  /// Label or text for save product
  ///
  /// In en, this message translates to:
  /// **'Save Product'**
  String get saveProduct;

  /// Label or text for update product
  ///
  /// In en, this message translates to:
  /// **'Update Product'**
  String get updateProduct;

  /// Label or text for product required
  ///
  /// In en, this message translates to:
  /// **'Item Name is required'**
  String get productRequired;

  /// Label or text for price required
  ///
  /// In en, this message translates to:
  /// **'Price is required'**
  String get priceRequired;

  /// Label or text for invalid price
  ///
  /// In en, this message translates to:
  /// **'Enter a valid price'**
  String get invalidPrice;

  /// Label or text for tax cannot exceed100
  ///
  /// In en, this message translates to:
  /// **'Tax cannot exceed 100%'**
  String get taxCannotExceed100;

  /// Label or text for add line item
  ///
  /// In en, this message translates to:
  /// **'Add Line Item'**
  String get addLineItem;

  /// Label or text for edit line item
  ///
  /// In en, this message translates to:
  /// **'Edit Line Item'**
  String get editLineItem;

  /// Label or text for item description
  ///
  /// In en, this message translates to:
  /// **'Item Description'**
  String get itemDescription;

  /// Label or text for quantity
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// Label or text for unit price
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get unitPrice;

  /// Label or text for tax
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// Label or text for unit
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// Label or text for save item
  ///
  /// In en, this message translates to:
  /// **'Save Item'**
  String get saveItem;

  /// Label or text for update item
  ///
  /// In en, this message translates to:
  /// **'Update Item'**
  String get updateItem;

  /// Label or text for select saved product
  ///
  /// In en, this message translates to:
  /// **'Select Saved Product'**
  String get selectSavedProduct;

  /// Search hint input label for savedproducts
  ///
  /// In en, this message translates to:
  /// **'Search saved products...'**
  String get searchSavedProducts;

  /// Label or text for no products found
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// Label or text for quantity required
  ///
  /// In en, this message translates to:
  /// **'Quantity is required'**
  String get quantityRequired;

  /// Dialog text for deletedrafttitle
  ///
  /// In en, this message translates to:
  /// **'Delete Draft?'**
  String get dialogDeleteDraftTitle;

  /// Dialog text for deletedraftmessage
  ///
  /// In en, this message translates to:
  /// **'This draft invoice will be permanently deleted. This action cannot be undone.'**
  String get dialogDeleteDraftMessage;

  /// Dialog text for deletedraftconfirm
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get dialogDeleteDraftConfirm;

  /// Dialog text for cancelinvoicetitle
  ///
  /// In en, this message translates to:
  /// **'Cancel Invoice?'**
  String get dialogCancelInvoiceTitle;

  /// Dialog text for cancelinvoicemessage
  ///
  /// In en, this message translates to:
  /// **'This invoice will be marked as cancelled but kept for your records.'**
  String get dialogCancelInvoiceMessage;

  /// Dialog text for cancelinvoiceconfirm
  ///
  /// In en, this message translates to:
  /// **'Cancel Invoice'**
  String get dialogCancelInvoiceConfirm;

  /// Dialog text for cancelinvoicecancel
  ///
  /// In en, this message translates to:
  /// **'Keep Invoice'**
  String get dialogCancelInvoiceCancel;

  /// Dialog text for deletecancelledtitle
  ///
  /// In en, this message translates to:
  /// **'Delete Cancelled Invoice?'**
  String get dialogDeleteCancelledTitle;

  /// Dialog text for deletecancelledmessage
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete this cancelled invoice record. This action cannot be undone.'**
  String get dialogDeleteCancelledMessage;

  /// Dialog text for deletecancelledconfirm
  ///
  /// In en, this message translates to:
  /// **'Delete Permanently'**
  String get dialogDeleteCancelledConfirm;

  /// Label or text for edit invoice
  ///
  /// In en, this message translates to:
  /// **'Edit Invoice'**
  String get editInvoice;

  /// Label or text for save invoice
  ///
  /// In en, this message translates to:
  /// **'Save Invoice'**
  String get saveInvoice;

  /// Label or text for save as draft
  ///
  /// In en, this message translates to:
  /// **'Save as Draft'**
  String get saveAsDraft;

  /// Label or text for saved customer
  ///
  /// In en, this message translates to:
  /// **'Saved Customer'**
  String get savedCustomer;

  /// Label or text for walk in customer
  ///
  /// In en, this message translates to:
  /// **'Walk-in Customer'**
  String get walkInCustomer;

  /// Label or text for select customer
  ///
  /// In en, this message translates to:
  /// **'Select Customer'**
  String get selectCustomer;

  /// Search hint input label for customer
  ///
  /// In en, this message translates to:
  /// **'Search Customer'**
  String get searchCustomer;

  /// Label or text for issue date
  ///
  /// In en, this message translates to:
  /// **'Issue Date'**
  String get issueDate;

  /// Label or text for due date
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// Label or text for discount
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// Label or text for discount amount
  ///
  /// In en, this message translates to:
  /// **'Discount Amount'**
  String get discountAmount;

  /// Label or text for discount percentage
  ///
  /// In en, this message translates to:
  /// **'Discount (%)'**
  String get discountPercentage;

  /// Label or text for paid amount
  ///
  /// In en, this message translates to:
  /// **'Paid Amount'**
  String get paidAmount;

  /// Label or text for invoice items
  ///
  /// In en, this message translates to:
  /// **'Invoice Items'**
  String get invoiceItems;

  /// Label or text for subtotal
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// Label or text for grand total
  ///
  /// In en, this message translates to:
  /// **'Grand Total'**
  String get grandTotal;

  /// Label or text for balance due
  ///
  /// In en, this message translates to:
  /// **'Balance Due'**
  String get balanceDue;

  /// Label or text for amount paid
  ///
  /// In en, this message translates to:
  /// **'Amount Paid'**
  String get amountPaid;

  /// Label or text for no items added
  ///
  /// In en, this message translates to:
  /// **'No items added yet.'**
  String get noItemsAdded;

  /// Label or text for select customer or walk in
  ///
  /// In en, this message translates to:
  /// **'Select a customer or use walk-in'**
  String get selectCustomerOrWalkIn;

  /// Label or text for invoice saved
  ///
  /// In en, this message translates to:
  /// **'Invoice saved successfully.'**
  String get invoiceSaved;

  /// Label or text for draft saved
  ///
  /// In en, this message translates to:
  /// **'Draft saved successfully.'**
  String get draftSaved;

  /// Label or text for invoice updated
  ///
  /// In en, this message translates to:
  /// **'Invoice updated successfully.'**
  String get invoiceUpdated;

  /// Label or text for cannot save invoice
  ///
  /// In en, this message translates to:
  /// **'Cannot save invoice. Please check your inputs.'**
  String get cannotSaveInvoice;

  /// Label or text for business details
  ///
  /// In en, this message translates to:
  /// **'Business Details'**
  String get businessDetails;

  /// Label or text for business name
  ///
  /// In en, this message translates to:
  /// **'Business Name'**
  String get businessName;

  /// Label or text for business email
  ///
  /// In en, this message translates to:
  /// **'Business Email'**
  String get businessEmail;

  /// Label or text for business phone
  ///
  /// In en, this message translates to:
  /// **'Business Phone'**
  String get businessPhone;

  /// Label or text for business address
  ///
  /// In en, this message translates to:
  /// **'Business Address'**
  String get businessAddress;

  /// Label or text for tax id
  ///
  /// In en, this message translates to:
  /// **'Tax ID'**
  String get taxId;

  /// Label or text for base currency
  ///
  /// In en, this message translates to:
  /// **'Default Invoice Currency'**
  String get baseCurrency;

  /// Label or text for save profile
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveProfile;

  /// Label or text for profile saved
  ///
  /// In en, this message translates to:
  /// **'Business profile saved successfully.'**
  String get profileSaved;

  /// Label or text for select logo
  ///
  /// In en, this message translates to:
  /// **'Select Logo'**
  String get selectLogo;

  /// Label or text for change logo
  ///
  /// In en, this message translates to:
  /// **'Change Logo'**
  String get changeLogo;

  /// Label or text for remove logo
  ///
  /// In en, this message translates to:
  /// **'Remove Logo'**
  String get removeLogo;

  /// Label or text for business name required
  ///
  /// In en, this message translates to:
  /// **'Business name is required'**
  String get businessNameRequired;

  /// Label or text for invalid business email
  ///
  /// In en, this message translates to:
  /// **'Enter a valid business email'**
  String get invalidBusinessEmail;

  /// Label or text for invoice summary
  ///
  /// In en, this message translates to:
  /// **'Invoice Summary'**
  String get invoiceSummary;

  /// Label or text for view all
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// Label or text for new invoice
  ///
  /// In en, this message translates to:
  /// **'New Invoice'**
  String get newInvoice;

  /// Label or text for theme
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Label or text for system
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// Label or text for light
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Label or text for dark
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appVersion(String version);

  /// Label or text for create backup title
  ///
  /// In en, this message translates to:
  /// **'Create Backup?'**
  String get createBackupTitle;

  /// Label or text for create backup
  ///
  /// In en, this message translates to:
  /// **'Create Backup'**
  String get createBackup;

  /// Label or text for restore backup title
  ///
  /// In en, this message translates to:
  /// **'Restore Backup?'**
  String get restoreBackupTitle;

  /// Label or text for restore backup
  ///
  /// In en, this message translates to:
  /// **'Restore Backup'**
  String get restoreBackup;

  /// Label or text for choose backup
  ///
  /// In en, this message translates to:
  /// **'Choose Backup'**
  String get chooseBackup;

  /// Label or text for confirm restore
  ///
  /// In en, this message translates to:
  /// **'Confirm Restore'**
  String get confirmRestore;

  /// Label or text for restore now
  ///
  /// In en, this message translates to:
  /// **'Restore Now'**
  String get restoreNow;

  /// Label or text for backup and restore
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupAndRestore;

  /// Label or text for data management
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// Label or text for export backup
  ///
  /// In en, this message translates to:
  /// **'Export Backup'**
  String get exportBackup;

  /// Label or text for export backup subtitle
  ///
  /// In en, this message translates to:
  /// **'Save your database securely.'**
  String get exportBackupSubtitle;

  /// Label or text for restore backup subtitle
  ///
  /// In en, this message translates to:
  /// **'Replace current data with backup.'**
  String get restoreBackupSubtitle;

  /// Label or text for backup created success
  ///
  /// In en, this message translates to:
  /// **'Backup created successfully.'**
  String get backupCreatedSuccess;

  /// Label or text for backup created missing path
  ///
  /// In en, this message translates to:
  /// **'Backup created but file path is missing.'**
  String get backupCreatedMissingPath;

  /// Label or text for create backup content
  ///
  /// In en, this message translates to:
  /// **'This will export your local InvoiceFlow Pro data into a backup file that you can store safely.'**
  String get createBackupContent;

  /// Label or text for restore warning content
  ///
  /// In en, this message translates to:
  /// **'Restoring a backup may replace your current local data. Create a fresh backup before continuing.'**
  String get restoreWarningContent;

  /// Label or text for restore selected content
  ///
  /// In en, this message translates to:
  /// **'Backup file selected: {fileName}\n\nRestoring will replace your current local database. This action cannot be undone.'**
  String restoreSelectedContent(String fileName);

  /// Label or text for restore completed
  ///
  /// In en, this message translates to:
  /// **'Restore Completed'**
  String get restoreCompleted;

  /// Label or text for restore success message
  ///
  /// In en, this message translates to:
  /// **'Your backup was restored successfully. Please restart the app to load restored data safely.'**
  String get restoreSuccessMessage;

  /// Label or text for close app i o s
  ///
  /// In en, this message translates to:
  /// **'Close InvoiceFlow Pro from the app switcher and reopen it.'**
  String get closeAppIOS;

  /// Label or text for close app
  ///
  /// In en, this message translates to:
  /// **'Close App'**
  String get closeApp;

  /// Label or text for backup created sharing failed
  ///
  /// In en, this message translates to:
  /// **'Backup created but sharing failed.'**
  String get backupCreatedSharingFailed;

  /// Label or text for invalid backup file
  ///
  /// In en, this message translates to:
  /// **'Please select a valid InvoiceFlow Pro backup file.'**
  String get invalidBackupFile;

  /// Label or text for could not access backup
  ///
  /// In en, this message translates to:
  /// **'Could not access the selected backup file.'**
  String get couldNotAccessBackup;

  /// Label or text for item details
  ///
  /// In en, this message translates to:
  /// **'Item Details'**
  String get itemDetails;

  /// Label or text for default tax rate
  ///
  /// In en, this message translates to:
  /// **'Default Tax Rate'**
  String get defaultTaxRate;

  /// Label or text for delete item title
  ///
  /// In en, this message translates to:
  /// **'Delete Item?'**
  String get deleteItemTitle;

  /// Label or text for delete customer title
  ///
  /// In en, this message translates to:
  /// **'Delete Customer?'**
  String get deleteCustomerTitle;

  /// Label or text for customer details
  ///
  /// In en, this message translates to:
  /// **'Customer Details'**
  String get customerDetails;

  /// Label or text for billing address
  ///
  /// In en, this message translates to:
  /// **'Billing Address'**
  String get billingAddress;

  /// Label or text for no contact info
  ///
  /// In en, this message translates to:
  /// **'No contact information provided.'**
  String get noContactInfo;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'{label} copied to clipboard'**
  String copiedToClipboard(String label);

  /// Label or text for failed to load profile
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile for PDF.'**
  String get failedToLoadProfile;

  /// Label or text for draft deleted
  ///
  /// In en, this message translates to:
  /// **'Draft deleted successfully.'**
  String get draftDeleted;

  /// Label or text for invoice cancelled
  ///
  /// In en, this message translates to:
  /// **'Invoice cancelled.'**
  String get invoiceCancelled;

  /// Label or text for cancelled invoice deleted
  ///
  /// In en, this message translates to:
  /// **'Cancelled invoice deleted.'**
  String get cancelledInvoiceDeleted;

  /// Label or text for error
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Status label for
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Label or text for billed to
  ///
  /// In en, this message translates to:
  /// **'Billed To'**
  String get billedTo;

  /// Label or text for line items
  ///
  /// In en, this message translates to:
  /// **'Line Items'**
  String get lineItems;

  /// Label or text for preview pdf
  ///
  /// In en, this message translates to:
  /// **'Preview PDF'**
  String get previewPdf;

  /// Label or text for unit piece
  ///
  /// In en, this message translates to:
  /// **'Piece'**
  String get unitPiece;

  /// Label or text for unit hour
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get unitHour;

  /// Label or text for unit day
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get unitDay;

  /// Label or text for unit project
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get unitProject;

  /// Label or text for unit service
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get unitService;

  /// Label or text for unit kg
  ///
  /// In en, this message translates to:
  /// **'Kilogram'**
  String get unitKg;

  /// Label or text for unit gram
  ///
  /// In en, this message translates to:
  /// **'Gram'**
  String get unitGram;

  /// Label or text for unit liter
  ///
  /// In en, this message translates to:
  /// **'Liter'**
  String get unitLiter;

  /// Label or text for unit meter
  ///
  /// In en, this message translates to:
  /// **'Meter'**
  String get unitMeter;

  /// Label or text for unit km
  ///
  /// In en, this message translates to:
  /// **'Kilometer'**
  String get unitKm;

  /// Label or text for unit box
  ///
  /// In en, this message translates to:
  /// **'Box'**
  String get unitBox;

  /// Label or text for unit pack
  ///
  /// In en, this message translates to:
  /// **'Pack'**
  String get unitPack;

  /// Label or text for unit set
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get unitSet;

  /// Label or text for delete customer content
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {customerName}? This action cannot be undone.'**
  String deleteCustomerContent(String customerName);

  /// Label or text for delete item content
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{productName}\"? This action cannot be undone.'**
  String deleteItemContent(String productName);

  /// Label or text for delete draft title
  ///
  /// In en, this message translates to:
  /// **'Delete Draft?'**
  String get deleteDraftTitle;

  /// Label or text for delete draft message
  ///
  /// In en, this message translates to:
  /// **'This draft invoice will be permanently deleted. This action cannot be undone.'**
  String get deleteDraftMessage;

  /// Label or text for delete cancelled title
  ///
  /// In en, this message translates to:
  /// **'Delete Cancelled Invoice?'**
  String get deleteCancelledTitle;

  /// Label or text for delete cancelled message
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete this cancelled invoice record. This action cannot be undone.'**
  String get deleteCancelledMessage;

  /// Label or text for contact information
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// Label or text for pdf ready
  ///
  /// In en, this message translates to:
  /// **'PDF Ready'**
  String get pdfReady;

  /// Label or text for pdf generated
  ///
  /// In en, this message translates to:
  /// **'Invoice {invoiceNumber} for {customerName} has been generated successfully.'**
  String pdfGenerated(String invoiceNumber, String customerName);

  /// Label or text for mark paid
  ///
  /// In en, this message translates to:
  /// **'Mark Paid'**
  String get markPaid;

  /// Label or text for mark unpaid
  ///
  /// In en, this message translates to:
  /// **'Mark Unpaid'**
  String get markUnpaid;

  /// Label or text for invoice pdf
  ///
  /// In en, this message translates to:
  /// **'Invoice PDF'**
  String get invoicePdf;

  /// Label or text for print pdf
  ///
  /// In en, this message translates to:
  /// **'Print PDF'**
  String get printPdf;

  /// Label or text for share pdf
  ///
  /// In en, this message translates to:
  /// **'Share PDF'**
  String get sharePdf;

  /// Label or text for website
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// Label or text for website hint
  ///
  /// In en, this message translates to:
  /// **'Enter website URL'**
  String get websiteHint;

  /// Label or text for phone too short
  ///
  /// In en, this message translates to:
  /// **'Phone number is too short'**
  String get phoneTooShort;

  /// Label or text for amount too large
  ///
  /// In en, this message translates to:
  /// **'Amount is too large'**
  String get amountTooLarge;

  /// Label or text for contact phone
  ///
  /// In en, this message translates to:
  /// **'Contact Phone'**
  String get contactPhone;

  /// Label or text for total invoice
  ///
  /// In en, this message translates to:
  /// **'Total Invoice'**
  String get totalInvoice;

  /// Label or text for total invoices
  ///
  /// In en, this message translates to:
  /// **'Total Invoices'**
  String get totalInvoices;

  /// Label or text for notes payment terms
  ///
  /// In en, this message translates to:
  /// **'Notes / Payment Terms'**
  String get notesPaymentTerms;

  /// Label or text for welcome title
  ///
  /// In en, this message translates to:
  /// **'Welcome to InvoiceFlow Pro'**
  String get welcomeTitle;

  /// Label or text for welcome subtitle
  ///
  /// In en, this message translates to:
  /// **'Set up your business profile to start generating professional invoices.'**
  String get welcomeSubtitle;

  /// Label or text for complete setup
  ///
  /// In en, this message translates to:
  /// **'Complete Setup'**
  String get completeSetup;

  /// Label or text for customer invoices title
  ///
  /// In en, this message translates to:
  /// **'Customer Invoices'**
  String get customerInvoicesTitle;

  /// Label or text for no customer invoices yet
  ///
  /// In en, this message translates to:
  /// **'No invoices for this customer yet.'**
  String get noCustomerInvoicesYet;

  /// Label or text for no customer invoices subtitle
  ///
  /// In en, this message translates to:
  /// **'Create an invoice for this customer to start tracking their billing history.'**
  String get noCustomerInvoicesSubtitle;

  /// Label or text for cannot exceed100
  ///
  /// In en, this message translates to:
  /// **'Cannot exceed 100%'**
  String get cannotExceed100;

  /// Label or text for cannot be negative
  ///
  /// In en, this message translates to:
  /// **'Cannot be negative'**
  String get cannotBeNegative;

  /// Label or text for cannot exceed subtotal
  ///
  /// In en, this message translates to:
  /// **'Cannot exceed subtotal'**
  String get cannotExceedSubtotal;

  /// Label or text for cannot exceed grand total
  ///
  /// In en, this message translates to:
  /// **'Cannot exceed grand total'**
  String get cannotExceedGrandTotal;

  /// Label or text for backup instruction text
  ///
  /// In en, this message translates to:
  /// **'Keep your data safe by exporting backups regularly. You can restore your data on any device.'**
  String get backupInstructionText;

  /// Label or text for restore warning text
  ///
  /// In en, this message translates to:
  /// **'Restore may replace existing local data. Keep a safe backup before importing.'**
  String get restoreWarningText;

  /// Label or text for processing backup request
  ///
  /// In en, this message translates to:
  /// **'Processing backup request...'**
  String get processingBackupRequest;

  /// Label or text for an error occurred
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get anErrorOccurred;

  /// No description provided for @discountWithPercentage.
  ///
  /// In en, this message translates to:
  /// **'Discount ({percentage}%)'**
  String discountWithPercentage(String percentage);

  /// Label or text for revenue by currency
  ///
  /// In en, this message translates to:
  /// **'Revenue by Currency'**
  String get revenueByCurrency;

  /// Label or text for outstanding by currency
  ///
  /// In en, this message translates to:
  /// **'Outstanding by Currency'**
  String get outstandingByCurrency;

  /// Label or text for urdu
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get urdu;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
