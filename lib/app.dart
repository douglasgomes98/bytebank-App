import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'widgets/common/loading_indicator.dart';

class ByteBankApp extends StatelessWidget {
  const ByteBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          title: 'ByteBank',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeProvider.themeMode,
          home: const _AuthGate(),
        ),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final authStatus = context.watch<AuthProvider>().status;

    switch (authStatus) {
      case AuthStatus.initial:
      case AuthStatus.loading:
        return const Scaffold(
          body: LoadingIndicator(message: 'Carregando...'),
        );
      case AuthStatus.authenticated:
        return const DashboardScreen();
      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        return const LoginScreen();
    }
  }
}
