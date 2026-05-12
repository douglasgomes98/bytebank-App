import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bytebank_app/core/router/app_router.dart';
import 'package:bytebank_app/core/security/session_lock_notifier.dart';
import 'package:bytebank_app/core/theme/app_theme.dart';
import 'package:bytebank_app/features/profile/presentation/controllers/theme_notifier.dart';

class ByteBankApp extends ConsumerStatefulWidget {
  const ByteBankApp({super.key});

  @override
  ConsumerState<ByteBankApp> createState() => _ByteBankAppState();
}

class _ByteBankAppState extends ConsumerState<ByteBankApp>
    with WidgetsBindingObserver {
  bool _logoPrecached = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_logoPrecached) {
      precacheImage(const AssetImage('assets/images/logo.png'), context);
      _logoPrecached = true;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      ref.read(sessionLockNotifierProvider.notifier).lock();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode =
        ref.watch(themeNotifierProvider).valueOrNull ?? ThemeMode.system;
    final isLocked = ref.watch(sessionLockNotifierProvider);

    if (isLocked) {
      return MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        debugShowCheckedModeBanner: false,
        home: const _BiometricLockScreen(),
      );
    }

    return MaterialApp.router(
      routerConfig: ref.watch(appRouterProvider),
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
    );
  }
}

class _BiometricLockScreen extends ConsumerWidget {
  const _BiometricLockScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  onPressed: () =>
                      ref.read(sessionLockNotifierProvider.notifier).unlock(),
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
