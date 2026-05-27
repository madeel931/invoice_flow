import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'InvoiceFlow Pro'**
  String get appName;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @invoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get invoices;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products & Services'**
  String get products;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @businessProfile.
  ///
  /// In en, this message translates to:
  /// **'Business Profile'**
  String get businessProfile;

  /// No description provided for @backupRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupRestore;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @noRecentInvoices.
  ///
  /// In en, this message translates to:
  /// **'No recent invoices yet.'**
  String get noRecentInvoices;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// No description provided for @outstandingBalance.
  ///
  /// In en, this message translates to:
  /// **'Outstanding Balance'**
  String get outstandingBalance;

  /// No description provided for @recentInvoice.
  ///
  /// In en, this message translates to:
  /// **'Recent Invoice'**
  String get recentInvoice;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @chooseAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose app language'**
  String get chooseAppLanguage;

  /// No description provided for @customersTitle.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customersTitle;

  /// No description provided for @productsTitle.
  ///
  /// In en, this message translates to:
  /// **'Items & Services'**
  String get productsTitle;

  /// No description provided for @invoicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get invoicesTitle;

  /// No description provided for @noCustomersYet.
  ///
  /// In en, this message translates to:
  /// **'No customers yet'**
  String get noCustomersYet;

  /// No description provided for @noCustomersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add customers to create invoices faster.'**
  String get noCustomersSubtitle;

  /// No description provided for @addCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add Customer'**
  String get addCustomer;

  /// No description provided for @noProductsYet.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get noProductsYet;

  /// No description provided for @noProductsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first product or service to speed up invoice creation.'**
  String get noProductsSubtitle;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @noInvoicesYet.
  ///
  /// In en, this message translates to:
  /// **'No invoices yet'**
  String get noInvoicesYet;

  /// No description provided for @noInvoicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your first invoice to start tracking your business.'**
  String get noInvoicesSubtitle;

  /// No description provided for @createInvoice.
  ///
  /// In en, this message translates to:
  /// **'Create Invoice'**
  String get createInvoice;

  /// No description provided for @searchCustomers.
  ///
  /// In en, this message translates to:
  /// **'Search customers...'**
  String get searchCustomers;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search items...'**
  String get searchProducts;

  /// No description provided for @searchInvoices.
  ///
  /// In en, this message translates to:
  /// **'Search invoice # or customer...'**
  String get searchInvoices;

  /// No description provided for @statusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// No description provided for @statusUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get statusUnpaid;

  /// No description provided for @statusPartiallyPaid.
  ///
  /// In en, this message translates to:
  /// **'Partially Paid'**
  String get statusPartiallyPaid;

  /// No description provided for @statusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// No description provided for @statusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get statusOverdue;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get filterPartial;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @viewPdf.
  ///
  /// In en, this message translates to:
  /// **'View PDF'**
  String get viewPdf;

  /// No description provided for @editDraft.
  ///
  /// In en, this message translates to:
  /// **'Edit Draft'**
  String get editDraft;

  /// No description provided for @deleteDraft.
  ///
  /// In en, this message translates to:
  /// **'Delete Draft'**
  String get deleteDraft;

  /// No description provided for @deletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete Permanently'**
  String get deletePermanently;

  /// No description provided for @markAsPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark as Paid'**
  String get markAsPaid;

  /// No description provided for @markAsUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Mark as Unpaid'**
  String get markAsUnpaid;

  /// No description provided for @cancelInvoice.
  ///
  /// In en, this message translates to:
  /// **'Cancel Invoice'**
  String get cancelInvoice;

  /// No description provided for @customerDeleted.
  ///
  /// In en, this message translates to:
  /// **'Customer deleted successfully.'**
  String get customerDeleted;

  /// No description provided for @productDeleted.
  ///
  /// In en, this message translates to:
  /// **'Item deleted successfully.'**
  String get productDeleted;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customerName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @saveCustomer.
  ///
  /// In en, this message translates to:
  /// **'Save Customer'**
  String get saveCustomer;

  /// No description provided for @updateCustomer.
  ///
  /// In en, this message translates to:
  /// **'Update Customer'**
  String get updateCustomer;

  /// No description provided for @customerRequired.
  ///
  /// In en, this message translates to:
  /// **'Customer Name is required'**
  String get customerRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @phoneTooLong.
  ///
  /// In en, this message translates to:
  /// **'Phone number is too long'**
  String get phoneTooLong;

  /// No description provided for @addressTooLong.
  ///
  /// In en, this message translates to:
  /// **'Address is too long'**
  String get addressTooLong;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get productName;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @basePrice.
  ///
  /// In en, this message translates to:
  /// **'Base Price'**
  String get basePrice;

  /// No description provided for @billingUnit.
  ///
  /// In en, this message translates to:
  /// **'Billing Unit'**
  String get billingUnit;

  /// No description provided for @taxRate.
  ///
  /// In en, this message translates to:
  /// **'Tax Rate (%)'**
  String get taxRate;

  /// No description provided for @saveProduct.
  ///
  /// In en, this message translates to:
  /// **'Save Product'**
  String get saveProduct;

  /// No description provided for @updateProduct.
  ///
  /// In en, this message translates to:
  /// **'Update Product'**
  String get updateProduct;

  /// No description provided for @productRequired.
  ///
  /// In en, this message translates to:
  /// **'Item Name is required'**
  String get productRequired;

  /// No description provided for @priceRequired.
  ///
  /// In en, this message translates to:
  /// **'Price is required'**
  String get priceRequired;

  /// No description provided for @invalidPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid price'**
  String get invalidPrice;

  /// No description provided for @taxCannotExceed100.
  ///
  /// In en, this message translates to:
  /// **'Tax cannot exceed 100%'**
  String get taxCannotExceed100;

  /// No description provided for @addLineItem.
  ///
  /// In en, this message translates to:
  /// **'Add Line Item'**
  String get addLineItem;

  /// No description provided for @editLineItem.
  ///
  /// In en, this message translates to:
  /// **'Edit Line Item'**
  String get editLineItem;

  /// No description provided for @itemDescription.
  ///
  /// In en, this message translates to:
  /// **'Item Description'**
  String get itemDescription;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @unitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get unitPrice;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @saveItem.
  ///
  /// In en, this message translates to:
  /// **'Save Item'**
  String get saveItem;

  /// No description provided for @updateItem.
  ///
  /// In en, this message translates to:
  /// **'Update Item'**
  String get updateItem;

  /// No description provided for @selectSavedProduct.
  ///
  /// In en, this message translates to:
  /// **'Select Saved Product'**
  String get selectSavedProduct;

  /// No description provided for @searchSavedProducts.
  ///
  /// In en, this message translates to:
  /// **'Search saved products...'**
  String get searchSavedProducts;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @quantityRequired.
  ///
  /// In en, this message translates to:
  /// **'Quantity is required'**
  String get quantityRequired;

  /// No description provided for @dialogDeleteDraftTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Draft?'**
  String get dialogDeleteDraftTitle;

  /// No description provided for @dialogDeleteDraftMessage.
  ///
  /// In en, this message translates to:
  /// **'This draft invoice will be permanently deleted. This action cannot be undone.'**
  String get dialogDeleteDraftMessage;

  /// No description provided for @dialogDeleteDraftConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get dialogDeleteDraftConfirm;

  /// No description provided for @dialogCancelInvoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Invoice?'**
  String get dialogCancelInvoiceTitle;

  /// No description provided for @dialogCancelInvoiceMessage.
  ///
  /// In en, this message translates to:
  /// **'This invoice will be marked as cancelled but kept for your records.'**
  String get dialogCancelInvoiceMessage;

  /// No description provided for @dialogCancelInvoiceConfirm.
  ///
  /// In en, this message translates to:
  /// **'Cancel Invoice'**
  String get dialogCancelInvoiceConfirm;

  /// No description provided for @dialogCancelInvoiceCancel.
  ///
  /// In en, this message translates to:
  /// **'Keep Invoice'**
  String get dialogCancelInvoiceCancel;

  /// No description provided for @dialogDeleteCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Cancelled Invoice?'**
  String get dialogDeleteCancelledTitle;

  /// No description provided for @dialogDeleteCancelledMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete this cancelled invoice record. This action cannot be undone.'**
  String get dialogDeleteCancelledMessage;

  /// No description provided for @dialogDeleteCancelledConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete Permanently'**
  String get dialogDeleteCancelledConfirm;

  /// No description provided for @editInvoice.
  ///
  /// In en, this message translates to:
  /// **'Edit Invoice'**
  String get editInvoice;

  /// No description provided for @saveInvoice.
  ///
  /// In en, this message translates to:
  /// **'Save Invoice'**
  String get saveInvoice;

  /// No description provided for @saveAsDraft.
  ///
  /// In en, this message translates to:
  /// **'Save as Draft'**
  String get saveAsDraft;

  /// No description provided for @savedCustomer.
  ///
  /// In en, this message translates to:
  /// **'Saved Customer'**
  String get savedCustomer;

  /// No description provided for @walkInCustomer.
  ///
  /// In en, this message translates to:
  /// **'Walk-in Customer'**
  String get walkInCustomer;

  /// No description provided for @selectCustomer.
  ///
  /// In en, this message translates to:
  /// **'Select Customer'**
  String get selectCustomer;

  /// No description provided for @searchCustomer.
  ///
  /// In en, this message translates to:
  /// **'Search Customer'**
  String get searchCustomer;

  /// No description provided for @issueDate.
  ///
  /// In en, this message translates to:
  /// **'Issue Date'**
  String get issueDate;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @discountAmount.
  ///
  /// In en, this message translates to:
  /// **'Discount Amount'**
  String get discountAmount;

  /// No description provided for @discountPercentage.
  ///
  /// In en, this message translates to:
  /// **'Discount (%)'**
  String get discountPercentage;

  /// No description provided for @paidAmount.
  ///
  /// In en, this message translates to:
  /// **'Paid Amount'**
  String get paidAmount;

  /// No description provided for @invoiceItems.
  ///
  /// In en, this message translates to:
  /// **'Invoice Items'**
  String get invoiceItems;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @grandTotal.
  ///
  /// In en, this message translates to:
  /// **'Grand Total'**
  String get grandTotal;

  /// No description provided for @balanceDue.
  ///
  /// In en, this message translates to:
  /// **'Balance Due'**
  String get balanceDue;

  /// No description provided for @amountPaid.
  ///
  /// In en, this message translates to:
  /// **'Amount Paid'**
  String get amountPaid;

  /// No description provided for @noItemsAdded.
  ///
  /// In en, this message translates to:
  /// **'No items added yet.'**
  String get noItemsAdded;

  /// No description provided for @selectCustomerOrWalkIn.
  ///
  /// In en, this message translates to:
  /// **'Select a customer or use walk-in'**
  String get selectCustomerOrWalkIn;

  /// No description provided for @invoiceSaved.
  ///
  /// In en, this message translates to:
  /// **'Invoice saved successfully.'**
  String get invoiceSaved;

  /// No description provided for @draftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved successfully.'**
  String get draftSaved;

  /// No description provided for @invoiceUpdated.
  ///
  /// In en, this message translates to:
  /// **'Invoice updated successfully.'**
  String get invoiceUpdated;

  /// No description provided for @cannotSaveInvoice.
  ///
  /// In en, this message translates to:
  /// **'Cannot save invoice. Please check your inputs.'**
  String get cannotSaveInvoice;

  /// No description provided for @businessDetails.
  ///
  /// In en, this message translates to:
  /// **'Business Details'**
  String get businessDetails;

  /// No description provided for @businessName.
  ///
  /// In en, this message translates to:
  /// **'Business Name'**
  String get businessName;

  /// No description provided for @businessEmail.
  ///
  /// In en, this message translates to:
  /// **'Business Email'**
  String get businessEmail;

  /// No description provided for @businessPhone.
  ///
  /// In en, this message translates to:
  /// **'Business Phone'**
  String get businessPhone;

  /// No description provided for @businessAddress.
  ///
  /// In en, this message translates to:
  /// **'Business Address'**
  String get businessAddress;

  /// No description provided for @taxId.
  ///
  /// In en, this message translates to:
  /// **'Tax ID'**
  String get taxId;

  /// No description provided for @baseCurrency.
  ///
  /// In en, this message translates to:
  /// **'Base Currency'**
  String get baseCurrency;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveProfile;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Business profile saved successfully.'**
  String get profileSaved;

  /// No description provided for @selectLogo.
  ///
  /// In en, this message translates to:
  /// **'Select Logo'**
  String get selectLogo;

  /// No description provided for @changeLogo.
  ///
  /// In en, this message translates to:
  /// **'Change Logo'**
  String get changeLogo;

  /// No description provided for @removeLogo.
  ///
  /// In en, this message translates to:
  /// **'Remove Logo'**
  String get removeLogo;

  /// No description provided for @businessNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Business name is required'**
  String get businessNameRequired;

  /// No description provided for @invalidBusinessEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid business email'**
  String get invalidBusinessEmail;

  /// No description provided for @invoiceSummary.
  ///
  /// In en, this message translates to:
  /// **'Invoice Summary'**
  String get invoiceSummary;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @newInvoice.
  ///
  /// In en, this message translates to:
  /// **'New Invoice'**
  String get newInvoice;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appVersion(String version);

  /// No description provided for @createBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Backup?'**
  String get createBackupTitle;

  /// No description provided for @createBackup.
  ///
  /// In en, this message translates to:
  /// **'Create Backup'**
  String get createBackup;

  /// No description provided for @restoreBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore Backup?'**
  String get restoreBackupTitle;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore Backup'**
  String get restoreBackup;

  /// No description provided for @chooseBackup.
  ///
  /// In en, this message translates to:
  /// **'Choose Backup'**
  String get chooseBackup;

  /// No description provided for @confirmRestore.
  ///
  /// In en, this message translates to:
  /// **'Confirm Restore'**
  String get confirmRestore;

  /// No description provided for @restoreNow.
  ///
  /// In en, this message translates to:
  /// **'Restore Now'**
  String get restoreNow;

  /// No description provided for @backupAndRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupAndRestore;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @exportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export Backup'**
  String get exportBackup;

  /// No description provided for @exportBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save your database securely.'**
  String get exportBackupSubtitle;

  /// No description provided for @restoreBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Replace current data with backup.'**
  String get restoreBackupSubtitle;

  /// No description provided for @backupCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup created successfully.'**
  String get backupCreatedSuccess;

  /// No description provided for @backupCreatedMissingPath.
  ///
  /// In en, this message translates to:
  /// **'Backup created but file path is missing.'**
  String get backupCreatedMissingPath;

  /// No description provided for @createBackupContent.
  ///
  /// In en, this message translates to:
  /// **'This will export your local InvoiceFlow Pro data into a backup file that you can store safely.'**
  String get createBackupContent;

  /// No description provided for @restoreWarningContent.
  ///
  /// In en, this message translates to:
  /// **'Restoring a backup may replace your current local data. Create a fresh backup before continuing.'**
  String get restoreWarningContent;

  /// No description provided for @restoreSelectedContent.
  ///
  /// In en, this message translates to:
  /// **'Backup file selected: {fileName}\n\nRestoring will replace your current local database. This action cannot be undone.'**
  String restoreSelectedContent(Object fileName);

  /// No description provided for @restoreCompleted.
  ///
  /// In en, this message translates to:
  /// **'Restore Completed'**
  String get restoreCompleted;

  /// No description provided for @restoreSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your backup was restored successfully. Please restart the app to load restored data safely.'**
  String get restoreSuccessMessage;

  /// No description provided for @closeAppIOS.
  ///
  /// In en, this message translates to:
  /// **'Close InvoiceFlow Pro from the app switcher and reopen it.'**
  String get closeAppIOS;

  /// No description provided for @closeApp.
  ///
  /// In en, this message translates to:
  /// **'Close App'**
  String get closeApp;

  /// No description provided for @backupCreatedSharingFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup created but sharing failed.'**
  String get backupCreatedSharingFailed;

  /// No description provided for @invalidBackupFile.
  ///
  /// In en, this message translates to:
  /// **'Please select a valid InvoiceFlow Pro backup file.'**
  String get invalidBackupFile;

  /// No description provided for @couldNotAccessBackup.
  ///
  /// In en, this message translates to:
  /// **'Could not access the selected backup file.'**
  String get couldNotAccessBackup;

  /// No description provided for @itemDetails.
  ///
  /// In en, this message translates to:
  /// **'Item Details'**
  String get itemDetails;

  /// No description provided for @defaultTaxRate.
  ///
  /// In en, this message translates to:
  /// **'Default Tax Rate'**
  String get defaultTaxRate;

  /// No description provided for @deleteItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Item?'**
  String get deleteItemTitle;

  /// No description provided for @deleteCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Customer?'**
  String get deleteCustomerTitle;

  /// No description provided for @customerDetails.
  ///
  /// In en, this message translates to:
  /// **'Customer Details'**
  String get customerDetails;

  /// No description provided for @billingAddress.
  ///
  /// In en, this message translates to:
  /// **'Billing Address'**
  String get billingAddress;

  /// No description provided for @noContactInfo.
  ///
  /// In en, this message translates to:
  /// **'No contact information provided.'**
  String get noContactInfo;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'{label} copied to clipboard'**
  String copiedToClipboard(String label);

  /// No description provided for @failedToLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile for PDF.'**
  String get failedToLoadProfile;

  /// No description provided for @draftDeleted.
  ///
  /// In en, this message translates to:
  /// **'Draft deleted successfully.'**
  String get draftDeleted;

  /// No description provided for @invoiceCancelled.
  ///
  /// In en, this message translates to:
  /// **'Invoice cancelled.'**
  String get invoiceCancelled;

  /// No description provided for @cancelledInvoiceDeleted.
  ///
  /// In en, this message translates to:
  /// **'Cancelled invoice deleted.'**
  String get cancelledInvoiceDeleted;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @billedTo.
  ///
  /// In en, this message translates to:
  /// **'Billed To'**
  String get billedTo;

  /// No description provided for @lineItems.
  ///
  /// In en, this message translates to:
  /// **'Line Items'**
  String get lineItems;

  /// No description provided for @previewPdf.
  ///
  /// In en, this message translates to:
  /// **'Preview PDF'**
  String get previewPdf;

  /// No description provided for @unitPiece.
  ///
  /// In en, this message translates to:
  /// **'Piece'**
  String get unitPiece;

  /// No description provided for @unitHour.
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get unitHour;

  /// No description provided for @unitDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get unitDay;

  /// No description provided for @unitProject.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get unitProject;

  /// No description provided for @unitService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get unitService;

  /// No description provided for @unitKg.
  ///
  /// In en, this message translates to:
  /// **'Kilogram'**
  String get unitKg;

  /// No description provided for @unitGram.
  ///
  /// In en, this message translates to:
  /// **'Gram'**
  String get unitGram;

  /// No description provided for @unitLiter.
  ///
  /// In en, this message translates to:
  /// **'Liter'**
  String get unitLiter;

  /// No description provided for @unitMeter.
  ///
  /// In en, this message translates to:
  /// **'Meter'**
  String get unitMeter;

  /// No description provided for @unitKm.
  ///
  /// In en, this message translates to:
  /// **'Kilometer'**
  String get unitKm;

  /// No description provided for @unitBox.
  ///
  /// In en, this message translates to:
  /// **'Box'**
  String get unitBox;

  /// No description provided for @unitPack.
  ///
  /// In en, this message translates to:
  /// **'Pack'**
  String get unitPack;

  /// No description provided for @unitSet.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get unitSet;

  /// No description provided for @deleteCustomerContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {customerName}? This action cannot be undone.'**
  String deleteCustomerContent(Object customerName);

  /// No description provided for @deleteItemContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{productName}\"? This action cannot be undone.'**
  String deleteItemContent(Object productName);

  /// No description provided for @deleteDraftTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Draft?'**
  String get deleteDraftTitle;

  /// No description provided for @deleteDraftMessage.
  ///
  /// In en, this message translates to:
  /// **'This draft invoice will be permanently deleted. This action cannot be undone.'**
  String get deleteDraftMessage;

  /// No description provided for @deleteCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Cancelled Invoice?'**
  String get deleteCancelledTitle;

  /// No description provided for @deleteCancelledMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete this cancelled invoice record. This action cannot be undone.'**
  String get deleteCancelledMessage;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @pdfReady.
  ///
  /// In en, this message translates to:
  /// **'PDF Ready'**
  String get pdfReady;

  /// No description provided for @pdfGenerated.
  ///
  /// In en, this message translates to:
  /// **'Invoice {invoiceNumber} for {customerName} has been generated successfully.'**
  String pdfGenerated(Object customerName, Object invoiceNumber);

  /// No description provided for @markPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark Paid'**
  String get markPaid;

  /// No description provided for @markUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Mark Unpaid'**
  String get markUnpaid;

  /// No description provided for @invoicePdf.
  ///
  /// In en, this message translates to:
  /// **'Invoice PDF'**
  String get invoicePdf;

  /// No description provided for @printPdf.
  ///
  /// In en, this message translates to:
  /// **'Print PDF'**
  String get printPdf;

  /// No description provided for @sharePdf.
  ///
  /// In en, this message translates to:
  /// **'Share PDF'**
  String get sharePdf;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @websiteHint.
  ///
  /// In en, this message translates to:
  /// **'Enter website URL'**
  String get websiteHint;

  /// No description provided for @phoneTooShort.
  ///
  /// In en, this message translates to:
  /// **'Phone number is too short'**
  String get phoneTooShort;

  /// No description provided for @amountTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Amount is too large'**
  String get amountTooLarge;

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact Phone'**
  String get contactPhone;

  /// No description provided for @totalInvoice.
  ///
  /// In en, this message translates to:
  /// **'Total Invoice'**
  String get totalInvoice;

  /// No description provided for @totalInvoices.
  ///
  /// In en, this message translates to:
  /// **'Total Invoices'**
  String get totalInvoices;

  /// No description provided for @notesPaymentTerms.
  ///
  /// In en, this message translates to:
  /// **'Notes / Payment Terms'**
  String get notesPaymentTerms;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to InvoiceFlow Pro'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your business profile to start generating professional invoices.'**
  String get welcomeSubtitle;

  /// No description provided for @completeSetup.
  ///
  /// In en, this message translates to:
  /// **'Complete Setup'**
  String get completeSetup;

  /// No description provided for @customerInvoicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer Invoices'**
  String get customerInvoicesTitle;

  /// No description provided for @noCustomerInvoicesYet.
  ///
  /// In en, this message translates to:
  /// **'No invoices for this customer yet.'**
  String get noCustomerInvoicesYet;

  /// No description provided for @noCustomerInvoicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create an invoice for this customer to start tracking their billing history.'**
  String get noCustomerInvoicesSubtitle;
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
      <String>['ar', 'en'].contains(locale.languageCode);

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
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
