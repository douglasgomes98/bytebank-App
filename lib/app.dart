import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/dependencies.dart';
import 'core/security/biometric_authenticator.dart';
import 'core/security/session_lock_controller.dart';
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
/// [AppDependencies] (composition root) e os disponibiliza para a árvore
/// via `MultiProvider`. A escolha do tema reage ao [ThemeController] e
/// a tela inicial é determinada pela [_AuthGate], que observa o
/// [AuthController]. Quando o usuário tem biometria habilitada, o
/// [SessionLockController] interpõe uma tela de bloqueio enquanto a
/// identidade não for reconfirmada.
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
        ChangeNotifierProvider<SessionLockController>.value(
          value: _dependencies.sessionLockController..attach(),
        ),
        Provider<BiometricAuthenticator>.value(
          value: _dependencies.biometricAuthenticator,
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
/// [AuthController.status] e o [SessionLockController.state].
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  AuthStatus? _previousAuthStatus;

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final lockController = context.watch<SessionLockController>();

    _syncSessionLock(authController.status, lockController);

    switch (authController.status) {
      case AuthStatus.initial:
      case AuthStatus.loading:
        return const Scaffold(
          body: LoadingIndicator(message: 'Carregando...'),
        );
      case AuthStatus.authenticated:
        if (!lockController.isUnlocked) {
          return _BiometricLockScreen(controller: lockController);
        }
        return const DashboardScreen();
      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        return const LoginScreen();
    }
  }

  void _syncSessionLock(
    AuthStatus status,
    SessionLockController lockController,
  ) {
    if (_previousAuthStatus == status) return;
    final previous = _previousAuthStatus;
    _previousAuthStatus = status;
    final authenticated = status == AuthStatus.authenticated;
    final freshSignIn = previous == AuthStatus.unauthenticated ||
        previous == AuthStatus.error;
    Future.microtask(
      () => lockController.refresh(
        hasAuthenticatedSession: authenticated,
        freshSignIn: freshSignIn,
      ),
    );
  }
}

/// Tela apresentada quando a sessão está autenticada mas a biometria
/// ainda não foi confirmada nesta abertura do app.
class _BiometricLockScreen extends StatelessWidget {
  const _BiometricLockScreen({required this.controller});

  final SessionLockController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.fingerprint, size: 80),
                const SizedBox(height: 24),
                Text(
                  'Acesso bloqueado',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Confirme sua identidade para acessar suas informações.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => controller.unlock(),
                  icon: const Icon(Icons.lock_open),
                  label: const Text('Desbloquear'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
