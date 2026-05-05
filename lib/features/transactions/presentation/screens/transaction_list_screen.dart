import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/transaction_type.dart';
import '../controllers/transaction_controller.dart';
import '../widgets/transaction_card.dart';
import 'transaction_detail_screen.dart';

/// Tela com a listagem completa de transações.
///
/// Permite filtrar por tipo (receita, despesa, transferência) e por
/// trecho da descrição. A filtragem ocorre em memória através do
/// [TransactionController.filterTransactions], preservando o algoritmo
/// da versão anterior.
class TransactionListScreen extends StatefulWidget {
  /// Cria a [TransactionListScreen].
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  TransactionType? _filterType;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TransactionController>();
    final filtered = controller.filterTransactions(
      type: _filterType,
      query: _searchQuery,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transações'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Buscar transação...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'Todos',
                      selected: _filterType == null,
                      onSelected: (_) => setState(() => _filterType = null),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Receitas',
                      selected: _filterType == TransactionType.income,
                      onSelected: (_) => setState(
                        () => _filterType = TransactionType.income,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Despesas',
                      selected: _filterType == TransactionType.expense,
                      onSelected: (_) => setState(
                        () => _filterType = TransactionType.expense,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Transferências',
                      selected: _filterType == TransactionType.transfer,
                      onSelected: (_) => setState(
                        () => _filterType = TransactionType.transfer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: controller.status == TransactionStatus.loading
          ? const LoadingIndicator(message: 'Carregando transações...')
          : filtered.isEmpty
              ? const _EmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80, top: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final transaction = filtered[index];
                    return TransactionCard(
                      transaction: transaction,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TransactionDetailScreen(
                            transaction: transaction,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

/// `FilterChip` configurado com a aparência usada pela tela.
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
    );
  }
}

/// Estado vazio exibido quando o filtro não retorna resultados.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma transação encontrada',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
