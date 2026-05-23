import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:invoice_flow_pro/features/customers/presentation/pages/customers_page.dart';
import 'package:invoice_flow_pro/features/settings/presentation/pages/settings_page.dart';

import '../../core/data/local/local_database_service.dart';
import '../../features/invoices/domain/entities/invoice.dart';
import '../../features/invoices/presentation/pages/invoice_form_page.dart';
import '../../features/invoices/presentation/pages/invoice_preview_page.dart';
import '../../features/invoices/presentation/pages/invoices_list_page.dart';
import '../../features/products/presentation/pages/products_page.dart';
import 'route_constants.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,

    // Navigation Guard
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
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.customers,
        name: 'customers',
        builder: (context, state) => const CustomersPage(),
      ),
      GoRoute(
        path: AppRoutes.products,
        name: 'products',
        builder: (context, state) => const ProductsPage(),
      ),
      GoRoute(
        path: AppRoutes.invoiceForm,
        name: 'invoice-form',
        builder: (context, state) => const InvoiceFormPage(),
      ),
      GoRoute(
        path: AppRoutes.invoicesList,
        name: 'invoices-list',
        builder: (context, state) => const InvoicesListPage(),
      ),
      GoRoute(
        path: AppRoutes.invoicePreview,
        name: 'invoice-preview',
        builder: (context, state) {
          // Pass the invoice entity strongly typed through go_router's extra parameter
          final invoice = state.extra as Invoice;
          return InvoicePreviewPage(invoice: invoice);
        },
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
