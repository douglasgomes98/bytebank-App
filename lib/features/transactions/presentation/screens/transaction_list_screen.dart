import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/transaction_type.dart';
import '../controllers/transaction_notifier.dart';
import '../providers/filtered_transactions_provider.dart';
import '../widgets/transaction_card.dart';

class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key});

  @override
  ConsumerState<TransactionListScreen> createState() =>
      _TransactionListScreenState();
}

class _TransactionListScreenState
    extends ConsumerState<TransactionListScreen> {
  final _scrollController = ScrollController();
  TransactionType? _filterType;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(transactionNotifierProvider.notifier).fetchNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(transactionNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transações'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  onChanged: (q) =>
                      ref.read(transactionSearchQueryProvider.notifier).update(q),
                  decoration: const InputDecoration(
                    hintText: 'Buscar transação...',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
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
                      onSelected: (_) =>
                          setState(() => _filterType = TransactionType.income),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Despesas',
                      selected: _filterType == TransactionType.expense,
                      onSelected: (_) =>
                          setState(() => _filterType = TransactionType.expense),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Transferências',
                      selected: _filterType == TransactionType.transfer,
                      onSelected: (_) =>
                          setState(() => _filterType = TransactionType.transfer),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: asyncState.when(
        loading: () => const LoadingIndicator(message: 'Carregando transações...'),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (uiState) {
          final filtered = _filterType == null
              ? uiState.transactions
              : uiState.transactions
                  .where((t) => t.type == _filterType)
                  .toList();

          if (filtered.isEmpty) return const _EmptyState();

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 80, top: 8),
            itemExtent: 72.0,
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final transaction = filtered[index];
              return TransactionCard(
                transaction: transaction,
                onTap: () => context.push(
                  '/transactions/${transaction.id}',
                  extra: transaction,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

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
