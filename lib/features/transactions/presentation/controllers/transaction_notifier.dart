import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bytebank_app/features/auth/presentation/controllers/auth_notifier.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_entity.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_ui_state.dart';
import 'package:bytebank_app/features/transactions/presentation/providers/filtered_transactions_provider.dart';
import 'package:bytebank_app/features/transactions/providers/transaction_providers.dart';

part 'transaction_notifier.g.dart';

@Riverpod(keepAlive: true)
class TransactionNotifier extends _$TransactionNotifier {
  @override
  FutureOr<TransactionUiState> build() async {
    final sub = ref.listen<AsyncValue<TransactionUiState>>(
      filteredTransactionsProvider,
      (_, next) => state = next,
    );
    ref.onDispose(sub.close);
    return ref.read(filteredTransactionsProvider.future);
  }

  Future<void> createTransaction(TransactionEntity transaction) async {
    final userId = ref.read(authStateStreamProvider).valueOrNull?.id;
    if (userId == null) return;
    await ref
        .read(createTransactionProvider)
        .call(transaction: transaction.copyWith(userId: userId));
  }

  Future<void> updateTransaction(TransactionEntity transaction) async {
    await ref.read(updateTransactionProvider).call(transaction: transaction);
  }

  Future<void> deleteTransaction(String transactionId) async {
    await ref
        .read(deleteTransactionProvider)
        .call(transactionId: transactionId);
  }

  Future<void> fetchNextPage() async {
    // Pagination implemented in Task 9
  }
}
