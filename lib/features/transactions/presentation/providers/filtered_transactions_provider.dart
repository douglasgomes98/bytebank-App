import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

import 'package:bytebank_app/features/transactions/domain/entities/transaction_entity.dart';
import 'package:bytebank_app/features/transactions/presentation/controllers/transaction_notifier.dart';

part 'filtered_transactions_provider.g.dart';

@riverpod
class TransactionSearchQuery extends _$TransactionSearchQuery {
  final _subject = BehaviorSubject<String>();

  @override
  String build() {
    ref.onDispose(_subject.close);
    return '';
  }

  void update(String query) {
    state = query;
    _subject.add(query);
  }

  Stream<String> get debouncedStream =>
      _subject.stream.debounceTime(const Duration(milliseconds: 300));
}

@riverpod
Stream<String> debouncedSearchQuery(DebouncedSearchQueryRef ref) {
  return ref
      .watch(transactionSearchQueryProvider.notifier)
      .debouncedStream
      .startWith('');
}

@riverpod
List<TransactionEntity> filteredTransactions(FilteredTransactionsRef ref) {
  final uiState = ref.watch(transactionNotifierProvider).valueOrNull;
  if (uiState == null) return const [];

  final query = ref.watch(debouncedSearchQueryProvider).valueOrNull ?? '';
  if (query.isEmpty) return uiState.transactions;

  final q = query.toLowerCase();
  return uiState.transactions
      .where((t) => t.description.toLowerCase().contains(q))
      .toList(growable: false);
}
