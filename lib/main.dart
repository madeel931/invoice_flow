import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/cubit/theme_cubit.dart';
import 'core/di/injection_container.dart' as di;
import 'config/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'features/invoices/presentation/cubit/invoice_list_cubit.dart';
import 'l10n/app_localizations.dart';
import 'core/locale/cubit/locale_cubit.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await initializeDateFormatting();

  final prefs = await SharedPreferences.getInstance();
  final savedThemeStr = prefs.getString('app_theme_mode');
  ThemeMode initialTheme = ThemeMode.system;
  if (savedThemeStr == 'light') {
    initialTheme = ThemeMode.light;
  } else if (savedThemeStr == 'dark') {
    initialTheme = ThemeMode.dark;
  }

  final savedLocaleStr = prefs.getString('app_locale_code');
  Locale? initialLocale;
  if (savedLocaleStr == 'en') {
    initialLocale = const Locale('en');
  } else if (savedLocaleStr == 'ar') {
    initialLocale = const Locale('ar');
  } else if (savedLocaleStr == 'ur') {
    initialLocale = const Locale('ur');
  }

  await di.init();
  runApp(InvoiceFlowApp(initialTheme: initialTheme, initialLocale: initialLocale));
}

class InvoiceFlowApp extends StatelessWidget {
  final ThemeMode initialTheme;
  final Locale? initialLocale;
  
  const InvoiceFlowApp({super.key, required this.initialTheme, this.initialLocale});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit(initialTheme)),
        BlocProvider(create: (_) => LocaleCubit(initialLocale)),
        // LIFTING STATE UP: Now all tabs share these exact instances!
        BlocProvider(create: (_) => di.sl<DashboardCubit>()..loadDashboard()),
        BlocProvider(create: (_) => di.sl<InvoiceListCubit>()..loadInvoices()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LocaleCubit, Locale?>(
            builder: (context, locale) {
              return MaterialApp.router(
                title: 'InvoiceFlow Pro',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
                locale: locale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                routerConfig: AppRouter.router,
              );
            },
          );
        },
      ),
    );
  }
}
