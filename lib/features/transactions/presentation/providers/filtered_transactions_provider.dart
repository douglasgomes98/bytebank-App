import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bytebank_app/features/auth/presentation/controllers/auth_notifier.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_entity.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_ui_state.dart';
import 'package:bytebank_app/features/transactions/providers/transaction_providers.dart';

part 'filtered_transactions_provider.g.dart';

@riverpod
class TransactionSearchQuery extends _$TransactionSearchQuery {
  final _controller = BehaviorSubject<String>.seeded('');

  @override
  String build() {
    ref.onDispose(_controller.close);
    return '';
  }

  void update(String query) {
    state = query;
    _controller.add(query);
  }

  Stream<String> get debouncedStream =>
      _controller.stream.debounceTime(const Duration(milliseconds: 300));
}

@riverpod
Stream<TransactionUiState> filteredTransactions(
    FilteredTransactionsRef ref) async* {
  final user = ref.watch(authStateStreamProvider).valueOrNull;
  if (user == null) return;

  final watchUseCase = ref.watch(watchTransactionsProvider);
  final searchNotifier = ref.watch(transactionSearchQueryProvider.notifier);

  final transactionsStream = watchUseCase(user.id)
      .map((result) => result.fold((_) => <TransactionEntity>[], (t) => t));

  yield* Rx.combineLatest2<List<TransactionEntity>, String, TransactionUiState>(
    transactionsStream,
    searchNotifier.debouncedStream.startWith(''),
    (transactions, query) {
      final filtered = query.isEmpty
          ? transactions
          : transactions
              .where((t) =>
                  t.description.toLowerCase().contains(query.toLowerCase()))
              .toList();

      final income = filtered
          .where((t) => t.isIncome)
          .fold<double>(0, (s, t) => s + t.amount);
      final expense = filtered
          .where((t) => t.isExpense)
          .fold<double>(0, (s, t) => s + t.amount);

      return TransactionUiState(
        transactions: filtered,
        balance: income - expense,
        hasMore: transactions.length >= 20,
      );
    },
  );
}
