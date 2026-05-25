import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../../features/customers/data/customer_repository_impl.dart';
import '../utils/app_directories.dart';
import '../data/local/local_database_service.dart';
import '../data/local/isar_database_service.dart';

// Onboarding
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import '../../features/onboarding/presentation/cubit/onboarding_cubit.dart';

// Settings
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/usecases/get_business_profile_usecase.dart';
import '../../features/settings/domain/usecases/update_business_profile_usecase.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';

import '../../features/settings/domain/repositories/backup_repository.dart';
import '../../features/settings/data/repositories/backup_repository_impl.dart';
import '../../features/settings/domain/usecases/create_backup_usecase.dart';
import '../../features/settings/domain/usecases/restore_backup_usecase.dart';
import '../../features/settings/presentation/cubit/backup_cubit.dart';

// Customers
import '../../features/customers/domain/repositories/customer_repository.dart';
import '../../features/customers/domain/usecases/get_customers_usecase.dart';
import '../../features/customers/domain/usecases/add_customer_usecase.dart';
import '../../features/customers/domain/usecases/update_customer_usecase.dart';
import '../../features/customers/domain/usecases/delete_customer_usecase.dart';
import '../../features/customers/presentation/cubit/customer_list_cubit.dart';

// Products
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/usecases/get_products_usecase.dart';
import '../../features/products/domain/usecases/add_product_usecase.dart';
import '../../features/products/domain/usecases/update_product_usecase.dart';
import '../../features/products/domain/usecases/delete_product_usecase.dart';
import '../../features/products/presentation/cubit/product_list_cubit.dart';

// Invoices
import '../../features/invoices/domain/repositories/invoice_repository.dart';
import '../../features/invoices/data/repositories/invoice_repository_impl.dart';
import '../../features/invoices/domain/usecases/save_invoice_usecase.dart';
import '../../features/invoices/domain/usecases/get_invoices_usecase.dart';
import '../../features/invoices/domain/usecases/delete_invoice_usecase.dart';
import '../../features/invoices/domain/usecases/get_next_invoice_number_usecase.dart';
import '../../features/invoices/presentation/cubit/invoice_form_cubit.dart';
import '../../features/invoices/presentation/cubit/invoice_list_cubit.dart';

// Dashboard Analytics
import '../../features/dashboard/domain/repositories/analytics_repository.dart';
import '../../features/dashboard/data/repositories/analytics_repository_impl.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_metrics_usecase.dart';
import '../../features/dashboard/domain/usecases/get_recent_invoice_usecase.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // 1. Core Utilities & Directories
  sl.registerLazySingleton(() => Logger(
        printer: PrettyPrinter(
            methodCount: 0,
            errorMethodCount: 5,
            lineLength: 80,
            colors: true,
            printEmojis: true),
      ));

  await AppDirectories.init();

  // 2. Database Services
  final localDbService = IsarDatabaseService();
  await localDbService.init();
  sl.registerLazySingleton<LocalDatabaseService>(() => localDbService);

  // ---------------------------------------------------------------------------
  // FEATURE: ONBOARDING
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<OnboardingRepository>(
      () => OnboardingRepositoryImpl(localDb: sl()));
  sl.registerLazySingleton(() => CompleteOnboardingUseCase(sl()));
  sl.registerFactory(() => OnboardingCubit(completeOnboarding: sl()));

  // ---------------------------------------------------------------------------
  // FEATURE: SETTINGS / BUSINESS PROFILE
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(localDb: sl()));
  sl.registerLazySingleton(() => GetBusinessProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateBusinessProfileUseCase(sl()));
  sl.registerLazySingleton(
      () => SettingsCubit(getProfile: sl(), updateProfile: sl())..loadProfile());

  // ---------------------------------------------------------------------------
  // FEATURE: CUSTOMERS
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<CustomerRepository>(
      () => CustomerRepositoryImpl(localDb: sl()));
  sl.registerLazySingleton(() => GetCustomersUseCase(sl()));
  sl.registerLazySingleton(() => AddCustomerUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCustomerUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCustomerUseCase(sl()));
  sl.registerFactory(() => CustomerListCubit(
        getCustomers: sl(),
        addCustomer: sl(),
        updateCustomer: sl(),
        deleteCustomer: sl(),
      ));

  // ---------------------------------------------------------------------------
  // FEATURE: PRODUCTS
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(localDb: sl()));
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => AddProductUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProductUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProductUseCase(sl()));
  sl.registerFactory(() => ProductListCubit(
        getProducts: sl(),
        addProduct: sl(),
        updateProduct: sl(),
        deleteProduct: sl(),
      ));

  // ---------------------------------------------------------------------------
  // FEATURE: INVOICES
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<InvoiceRepository>(
      () => InvoiceRepositoryImpl(localDb: sl()));
  sl.registerLazySingleton(() => SaveInvoiceUseCase(sl()));
  sl.registerLazySingleton(() => GetNextInvoiceNumberUseCase(sl()));
  sl.registerLazySingleton(() => GetInvoicesUseCase(sl()));
  sl.registerLazySingleton(() => DeleteInvoiceUseCase(sl()));

  sl.registerFactory(() => InvoiceFormCubit(
        getNextInvoiceNumber: sl(),
        saveInvoiceUseCase: sl(),
      ));
  sl.registerFactory(() => InvoiceListCubit(
        getInvoices: sl(),
        deleteInvoice: sl(),
        getNextNumber: sl(),
        saveInvoice: sl(),
      ));

  // ---------------------------------------------------------------------------
  // FEATURE: DASHBOARD ANALYTICS
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<AnalyticsRepository>(
      () => AnalyticsRepositoryImpl(localDb: sl()));
  sl.registerLazySingleton(() => GetDashboardMetricsUseCase(sl()));
  sl.registerLazySingleton(() => GetRecentInvoiceUseCase(sl()));
  sl.registerFactory(() =>
      DashboardCubit(getMetrics: sl(), getProfile: sl(), getRecentInvoice: sl()));

  // Backup System
  sl.registerLazySingleton<BackupRepository>(
      () => BackupRepositoryImpl(localDb: sl()));
  sl.registerLazySingleton(() => CreateBackupUseCase(sl()));
  sl.registerLazySingleton(() => RestoreBackupUseCase(sl()));
  sl.registerLazySingleton(
      () => BackupCubit(createBackup: sl(), restoreBackup: sl()));

  sl<Logger>().i('Dependency Injection Initialized successfully.');
}
