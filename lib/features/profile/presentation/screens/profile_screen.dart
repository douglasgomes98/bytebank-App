import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/security/biometric_authenticator.dart';
import '../../../../core/security/session_lock_controller.dart';
import '../../../../core/utils/formatters.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../transactions/presentation/controllers/transaction_controller.dart';
import '../controllers/theme_controller.dart';

/// Tela de perfil do usuário.
///
/// Exibe avatar, nome e e-mail, totais agregados das transações e os
/// controles de tema, segurança e logout.
class ProfileScreen extends StatelessWidget {
  /// Cria a [ProfileScreen].
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;
    final themeController = context.watch<ThemeController>();
    final txController = context.watch<TransactionController>();
    final lockController = context.watch<SessionLockController>();

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
                      backgroundColor:
                          Theme.of(context).colorScheme.primary,
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
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 16),
                    if (user?.createdAt != null)
                      Text(
                        'Membro desde ${Formatters.date(user!.createdAt)}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatItem(
                      label: 'Total receitas',
                      value: Formatters.currency(txController.totalIncome),
                      color: Colors.green,
                    ),
                    _StatItem(
                      label: 'Total despesas',
                      value:
                          Formatters.currency(txController.totalExpenses),
                      color: Colors.red,
                    ),
                    _StatItem(
                      label: 'Transações',
                      value: txController.transactions.length.toString(),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Tema escuro'),
                    subtitle: const Text('Alternar entre claro e escuro'),
                    value: themeController.isDarkMode,
                    onChanged: (_) => themeController.toggleTheme(),
                    secondary: const Icon(Icons.dark_mode_outlined),
                  ),
                  const Divider(height: 1),
                  _BiometricSwitch(controller: lockController),
                  const Divider(height: 1),
                  ListTile(
                    leading:
                        const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Sair',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () => _confirmLogout(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Apresenta o diálogo de confirmação e dispara o logout através de
  /// [AuthController.signOut], limpando também a lista de transações em
  /// memória.
  void _confirmLogout(BuildContext context) {
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
              context.read<TransactionController>().clear();
              context.read<AuthController>().signOut();
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}

/// Switch para ativar/desativar a exigência de biometria ao reabrir o
/// app. Consome a disponibilidade real do hardware via
/// [BiometricAuthenticator] (injetado por `Provider`) e a flag
/// persistida via [SessionLockController].
class _BiometricSwitch extends StatefulWidget {
  const _BiometricSwitch({required this.controller});

  final SessionLockController controller;

  @override
  State<_BiometricSwitch> createState() => _BiometricSwitchState();
}

class _BiometricSwitchState extends State<_BiometricSwitch> {
  Future<_BiometricSettings>? _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_BiometricSettings> _load() async {
    final auth = context.read<BiometricAuthenticator>();
    final availability = await auth.availability();
    final enabled = await widget.controller.isBiometricEnabled();
    return _BiometricSettings(availability: availability, enabled: enabled);
  }

  Future<void> _toggle(bool value, _BiometricSettings current) async {
    if (value && current.availability != BiometricAvailability.available) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_unavailableMessage(current.availability))),
      );
      return;
    }
    await widget.controller.setBiometricEnabled(value);
    if (!mounted) return;
    setState(() {
      _future = Future.value(
        _BiometricSettings(
          availability: current.availability,
          enabled: value,
        ),
      );
    });
  }

  String _unavailableMessage(BiometricAvailability availability) {
    switch (availability) {
      case BiometricAvailability.notEnrolled:
        return 'Cadastre uma biometria nas configurações do dispositivo.';
      case BiometricAvailability.unavailable:
      case BiometricAvailability.available:
        return 'Biometria indisponível neste dispositivo.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_BiometricSettings>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final supported =
            data?.availability == BiometricAvailability.available;
        return SwitchListTile(
          title: const Text('Bloqueio por biometria'),
          subtitle: Text(
            supported
                ? 'Exigir biometria ao reabrir o app'
                : _unavailableMessage(
                    data?.availability ??
                        BiometricAvailability.unavailable,
                  ),
          ),
          value: supported && (data?.enabled ?? false),
          onChanged:
              data == null || !supported ? null : (v) => _toggle(v, data),
          secondary: const Icon(Icons.fingerprint_outlined),
        );
      },
    );
  }
}

class _BiometricSettings {
  const _BiometricSettings({
    required this.availability,
    required this.enabled,
  });

  final BiometricAvailability availability;
  final bool enabled;
}

/// Bloco de estatística (valor + rótulo) reutilizado dentro do cartão
/// de totais.
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
