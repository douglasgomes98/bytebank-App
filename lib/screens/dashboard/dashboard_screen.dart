import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/transaction/transaction_card.dart';
import '../transactions/transaction_list_screen.dart';
import '../transactions/transaction_form_screen.dart';
import '../transactions/transaction_detail_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().user?.id;
      if (userId != null) {
        context.read<TransactionProvider>().setUserId(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _HomeTab(),
          TransactionListScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transações',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nova transação'),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final txProvider = context.watch<TransactionProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, ${user?.name.split(' ').first ?? 'Usuário'}'),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
      ),
      body: txProvider.status == TransactionStatus.loading
          ? const LoadingIndicator(message: 'Carregando...')
          : RefreshIndicator(
              onRefresh: () async {
                final userId = context.read<AuthProvider>().user?.id;
                if (userId != null) {
                  context.read<TransactionProvider>().setUserId(userId);
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BalanceCard(
                      balance: txProvider.balance,
                      income: txProvider.totalIncome,
                      expenses: txProvider.totalExpenses,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Últimas transações',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Ver todas'),
                          ),
                        ],
                      ),
                    ),
                    if (txProvider.transactions.isEmpty)
                      const _EmptyTransactions()
                    else
                      ...txProvider.transactions.take(5).map(
                            (t) => TransactionCard(
                              transaction: t,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TransactionDetailScreen(transaction: t),
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final double balance;
  final double income;
  final double expenses;

  const _BalanceCard({
    required this.balance,
    required this.income,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saldo disponível',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            Formatters.currency(balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Receitas',
                  value: Formatters.currency(income),
                  icon: Icons.arrow_downward,
                  iconColor: Colors.greenAccent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatItem(
                  label: 'Despesas',
                  value: Formatters.currency(expenses),
                  icon: Icons.arrow_upward,
                  iconColor: Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma transação',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione sua primeira transação',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
