import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'core/constants.dart';
import 'core/theme.dart';
import 'core/theme_provider.dart';
import 'features/auth/auth_controller.dart';
import 'features/developer/developer_dashboard.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/main_layout.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1280, 800),
      minimumSize: Size(1024, 768),
      center: true,
      backgroundColor: Color.fromRGBO(0, 0, 0, 0),
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: AppConstants.appTitle,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    runApp(const ProviderScope(child: MyApp()));
  }, (error, stack) {
    debugPrint("🔥 CRITICAL APP ERROR: $error");
    debugPrint(stack.toString());
  });
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: AppConstants.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: authState.isAuthenticated
          ? (authState.role == AuthRole.developer
              ? const DeveloperDashboard()
              : const MainLayout())
          : const LoginScreen(),
    );
  }
}
