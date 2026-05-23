import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/di/injection_container.dart' as di;
import 'config/routes/app_router.dart';
import 'config/theme/app_theme.dart';

void main() async {
  // Ensure Flutter engine is properly initialized before running native code
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for a consistent business app experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Dependency Injection
  await di.init();

  runApp(const InvoiceFlowApp());
}

class InvoiceFlowApp extends StatelessWidget {
  const InvoiceFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'InvoiceFlow Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
