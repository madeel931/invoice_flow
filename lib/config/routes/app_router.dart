import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:invoice_flow_pro/features/customers/presentation/pages/customers_page.dart';
import 'package:invoice_flow_pro/features/settings/presentation/pages/settings_page.dart';
import 'package:invoice_flow_pro/features/settings/presentation/pages/backup_restore_page.dart';

import '../../core/data/local/local_database_service.dart';
import '../../core/presentation/widgets/main_shell_page.dart';
import '../../features/customers/presentation/pages/customer_detail_page.dart';

import '../../features/invoices/presentation/pages/invoice_detail_page.dart';
import '../../features/invoices/presentation/pages/invoice_form_page.dart';
import '../../features/invoices/presentation/pages/invoice_preview_page.dart';
import '../../features/invoices/presentation/pages/invoices_list_page.dart';
import '../../features/products/presentation/pages/product_detail_page.dart';
import '../../features/products/presentation/pages/products_page.dart';
import 'route_constants.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';

// 1. ADDED: Navigator keys for the shell routing
final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');


class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey, // ADDED: Attach root key
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,

    // Navigation Guard (Kept exactly as you wrote it)
    redirect: (BuildContext context, GoRouterState state) async {
      final dbService = GetIt.instance<LocalDatabaseService>();
      final metadata = await dbService.getAppMetadata();

      // Default to true if metadata is mysteriously null (fail-safe)
      final bool isFirstLaunch = metadata?.isFirstLaunch ?? true;

      final bool isGoingToOnboarding =
          state.matchedLocation == AppRoutes.onboarding;
      final bool isAtSplash = state.matchedLocation == AppRoutes.splash;

      // Rule 1: If it's the first launch, and they aren't already going to onboarding, force them there.
      if (isFirstLaunch && !isGoingToOnboarding) {
        return AppRoutes.onboarding;
      }

      // Rule 2: If they have already completed onboarding, prevent them from seeing Splash or Onboarding again.
      if (!isFirstLaunch && (isAtSplash || isGoingToOnboarding)) {
        return AppRoutes.dashboard;
      }

      // Rule 3: Allow the navigation to proceed normally.
      return null;
    },

    routes: [
      // --- NON-SHELL ROUTES (Full Screen Pages) ---
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.backupRestore,
        name: 'backup-restore',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BackupRestorePage(),
      ),
      GoRoute(
        path: AppRoutes.invoiceForm,
        name: 'invoice-form',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => InvoiceFormPage(existingInvoiceId: state.uri.queryParameters['id']),
      ),
      GoRoute(
        path: '${AppRoutes.invoicePreview}/:id',
        name: 'invoice-preview',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          // We pass the ID in the path instead of passing the full Invoice object as 'extra'.
          // This avoids GoRouter serialization crashes when deep linking or web reloading.
          final invoiceId = state.pathParameters['id']!;
          return InvoicePreviewPage(invoiceId: invoiceId);
        },
      ),
      GoRoute(
        path: '${AppRoutes.customerDetail}/:id',
        name: 'customer-detail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final customerId = state.pathParameters['id']!;
          return CustomerDetailPage(customerId: customerId);
        },
      ),
      GoRoute(
        path: '${AppRoutes.productDetail}/:id',
        name: 'product-detail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          return ProductDetailPage(productId: productId);
        },
      ),
      GoRoute(
        path: '${AppRoutes.invoiceDetail}/:id',
        name: 'invoice-detail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          // Pass ID in path to avoid GoRouter serialization issues
          final invoiceId = state.pathParameters['id']!;
          return InvoiceDetailPage(invoiceId: invoiceId);
        },
      ),
      GoRoute(
        path: '${AppRoutes.customerInvoices}/:id',
        name: 'customer-invoices',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final customerId = state.pathParameters['id']!;
          return InvoicesListPage(filterCustomerId: customerId);
        },
      ),

      // --- SHELL ROUTE (Bottom Nav + Drawer Pages) ---
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellPage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                name: 'dashboard',
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.invoicesList,
                name: 'invoices-list',
                builder: (context, state) => const InvoicesListPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.customers,
                name: 'customers',
                builder: (context, state) => const CustomersPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.products,
                name: 'products',
                builder: (context, state) => const ProductsPage(),
              ),
            ],
          ),
        ],
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text('Route not found: ${state.uri.toString()}'),
      ),
    ),
  );
}
