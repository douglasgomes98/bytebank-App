import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/security/biometric_authenticator.dart';
import '../../../../core/security/session_lock_notifier.dart';
import '../../../../core/utils/formatters.dart';
import '../../../auth/presentation/controllers/auth_notifier.dart';
import '../../../transactions/presentation/controllers/transaction_notifier.dart';
import '../controllers/theme_notifier.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateStreamProvider).valueOrNull;
    final themeMode =
        ref.watch(themeNotifierProvider).valueOrNull ?? ThemeMode.system;
    final isDarkMode = themeMode == ThemeMode.dark;
    final txAsync = ref.watch(transactionNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        user?.name.isNotEmpty == true
                            ? user!.name[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.name ?? '',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      user?.email ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 16),
                    if (user?.createdAt != null)
                      Text(
                        'Membro desde ${Formatters.date(user!.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            txAsync.whenOrNull(
                  data: (uiState) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatItem(
                            label: 'Total receitas',
                            value:
                                Formatters.currency(uiState.totalIncome),
                            color: Colors.green,
                          ),
                          _StatItem(
                            label: 'Total despesas',
                            value:
                                Formatters.currency(uiState.totalExpense),
                            color: Colors.red,
                          ),
                          _StatItem(
                            label: 'Transações',
                            value:
                                uiState.transactions.length.toString(),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ) ??
                const SizedBox.shrink(),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Tema escuro'),
                    subtitle: const Text('Alternar entre claro e escuro'),
                    value: isDarkMode,
                    onChanged: (_) => ref
                        .read(themeNotifierProvider.notifier)
                        .setTheme(
                          isDarkMode ? ThemeMode.light : ThemeMode.dark,
                        ),
                    secondary: const Icon(Icons.dark_mode_outlined),
                  ),
                  const Divider(height: 1),
                  _BiometricSwitch(ref: ref),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Sair',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () => _confirmLogout(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authNotifierProvider.notifier).signOut();
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}

class _BiometricSwitch extends StatefulWidget {
  final WidgetRef ref;

  const _BiometricSwitch({required this.ref});

  @override
  State<_BiometricSwitch> createState() => _BiometricSwitchState();
}

class _BiometricSwitchState extends State<_BiometricSwitch> {
  bool _enabled = false;
  bool _available = false;

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    final biometric =
        widget.ref.read(biometricAuthenticatorProvider);
    final availability = await biometric.availability();
    if (mounted) {
      setState(
        () => _available = availability == BiometricAvailability.available,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = widget.ref.watch(sessionLockNotifierProvider);
    return SwitchListTile(
      title: const Text('Bloqueio por biometria'),
      subtitle: Text(
        _available
            ? 'Exigir biometria ao reabrir o app'
            : 'Biometria indisponível neste dispositivo.',
      ),
      value: _available && _enabled,
      onChanged: _available
          ? (value) {
              setState(() => _enabled = value);
              if (value) {
                widget.ref
                    .read(sessionLockNotifierProvider.notifier)
                    .lock();
              }
            }
          : null,
      secondary: Icon(
        isLocked ? Icons.lock : Icons.fingerprint_outlined,
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
