import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/dependencies.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/loading_indicator.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/profile/presentation/controllers/theme_controller.dart';
import 'features/transactions/presentation/controllers/transaction_controller.dart';
import 'features/transactions/presentation/screens/dashboard_screen.dart';

/// Widget raiz da aplicação.
///
/// Constrói os controllers da camada de apresentação a partir de
/// [AppDependencies] (composition root, item 4 da proposta) e os
/// disponibiliza para a árvore via `MultiProvider`. A escolha do tema
/// reage ao [ThemeController] e a tela inicial é determinada pela
/// [_AuthGate], que observa o [AuthController].
class ByteBankApp extends StatelessWidget {
  /// Cria a [ByteBankApp] usando uma instância nova de [AppDependencies].
  ByteBankApp({super.key}) : _dependencies = AppDependencies();

  final AppDependencies _dependencies;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeController>(
          create: (_) => _dependencies.buildThemeController(),
        ),
        ChangeNotifierProvider<AuthController>(
          create: (_) => _dependencies.buildAuthController(),
        ),
        ChangeNotifierProvider<TransactionController>(
          create: (_) => _dependencies.buildTransactionController(),
        ),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) => MaterialApp(
          title: 'ByteBank',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeController.themeMode,
          home: const _AuthGate(),
        ),
      ),
    );
  }
}

/// Componente que decide qual tela exibir conforme o
/// [AuthController.status].
///
/// Substitui o uso direto do `FirebaseAuth.authStateChanges` na camada de
/// UI: a presença/ausência de sessão é descoberta exclusivamente através
/// do controller (que, internamente, consome o caso de uso
/// `WatchAuthState`).
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final authStatus = context.watch<AuthController>().status;

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
