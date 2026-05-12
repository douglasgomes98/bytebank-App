import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bytebank_app/core/utils/constants.dart';
import 'package:bytebank_app/features/auth/presentation/controllers/auth_notifier.dart';
import 'package:bytebank_app/features/auth/providers/auth_providers.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_entity.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_ui_state.dart';
import 'package:bytebank_app/features/transactions/providers/transaction_providers.dart';

part 'transaction_notifier.g.dart';

@Riverpod(keepAlive: true)
class TransactionNotifier extends _$TransactionNotifier {
  bool _loadingMore = false;
  String? _lastFetchedId;

  @override
  FutureOr<TransactionUiState> build() async {
    final user = ref.watch(authStateStreamProvider).valueOrNull;
    if (user == null) {
      _lastFetchedId = null;
      return const TransactionUiState(
        transactions: [],
        balance: 0,
        hasMore: false,
      );
    }

    final watchUseCase = ref.watch(watchTransactionsProvider);
    final subscription = watchUseCase(user.id).listen((result) {
      result.fold(
        (failure) => state = AsyncError(failure, StackTrace.current),
        _mergeRealtime,
      );
    });
    ref.onDispose(subscription.cancel);

    final firstResult = await watchUseCase(user.id).first;
    return firstResult.fold(
      (failure) => throw failure,
      (list) {
        if (list.isNotEmpty) _lastFetchedId = list.last.id;
        return _buildUiState(
          list,
          hasMore: list.length >= AppConstants.transactionsPageSize,
        );
      },
    );
  }

  void _mergeRealtime(List<TransactionEntity> realtimeList) {
    final current = state.valueOrNull;
    if (current == null) {
      state = AsyncData(_buildUiState(
        realtimeList,
        hasMore: realtimeList.length >= AppConstants.transactionsPageSize,
      ));
      if (realtimeList.isNotEmpty) {
        _lastFetchedId = realtimeList.last.id;
      }
      return;
    }
    final realtimeIds = realtimeList.map((t) => t.id).toSet();
    final paginatedTail =
        current.transactions.where((t) => !realtimeIds.contains(t.id)).toList();
    final merged = [...realtimeList, ...paginatedTail];
    state = AsyncData(_buildUiState(
      merged,
      hasMore: current.hasMore,
      isLoadingMore: current.isLoadingMore,
    ));
  }

  TransactionUiState _buildUiState(
    List<TransactionEntity> txs, {
    required bool hasMore,
    bool isLoadingMore = false,
  }) {
    final income =
        txs.where((t) => t.isIncome).fold<double>(0, (s, t) => s + t.amount);
    final expense =
        txs.where((t) => t.isExpense).fold<double>(0, (s, t) => s + t.amount);
    return TransactionUiState(
      transactions: txs,
      balance: income - expense,
      hasMore: hasMore,
      isLoadingMore: isLoadingMore,
    );
  }

  Future<void> fetchNextPage() async {
    if (_loadingMore) return;
    final current = state.valueOrNull;
    if (current == null || !current.hasMore) return;
    if (_lastFetchedId == null) return;

    final user = ref.read(authStateStreamProvider).valueOrNull;
    if (user == null) return;

    _loadingMore = true;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final result = await ref.read(fetchNextPageProvider).call(
            userId: user.id,
            lastTransactionId: _lastFetchedId,
          );

      result.fold(
        (_) {
          state = AsyncData(current.copyWith(isLoadingMore: false));
        },
        (newItems) {
          if (newItems.isEmpty) {
            state = AsyncData(current.copyWith(
              hasMore: false,
              isLoadingMore: false,
            ));
            return;
          }
          _lastFetchedId = newItems.last.id;
          final merged = [...current.transactions, ...newItems];
          state = AsyncData(_buildUiState(
            merged,
            hasMore: newItems.length >= AppConstants.transactionsPageSize,
            isLoadingMore: false,
          ));
        },
      );
    } finally {
      _loadingMore = false;
    }
  }

  Future<void> createTransaction(TransactionEntity transaction) async {
    final userId = ref.read(authStateStreamProvider).valueOrNull?.id;
    if (userId == null) return;
    await ref.read(ensureFreshSessionProvider).call();
    await ref
        .read(createTransactionProvider)
        .call(transaction: transaction.copyWith(userId: userId));
  }

  Future<void> updateTransaction(TransactionEntity transaction) async {
    await ref.read(ensureFreshSessionProvider).call();
    await ref.read(updateTransactionProvider).call(transaction: transaction);
  }

  Future<void> deleteTransaction(String transactionId) async {
    await ref.read(ensureFreshSessionProvider).call();
    await ref
        .read(deleteTransactionProvider)
        .call(transactionId: transactionId);
  }
}
