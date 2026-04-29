import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_notifier.dart';
import 'providers/auth_provider.dart';
import 'providers/shoe_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SoleAiApp());
}

class SoleAiApp extends StatelessWidget {
  const SoleAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkSession()),
        ChangeNotifierProvider(create: (_) => ShoeProvider()),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (_, theme, __) => MaterialApp(
          title:                    'Sole AI',
          debugShowCheckedModeBanner: false,
          theme:                    AppTheme.light,
          darkTheme:                AppTheme.dark,
          themeMode:                theme.themeMode,
          home:                     const _AuthGate(),
        ),
      ),
    );
  }
}

/// Router dinamis — rebuild otomatis saat status login berubah
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    return auth.isLoggedIn
        ? const HomeScreen()
        : const LoginScreen();
  }
}
