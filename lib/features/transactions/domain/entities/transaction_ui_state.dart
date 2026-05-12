import 'package:bytebank_app/features/transactions/domain/entities/transaction_entity.dart';

class TransactionUiState {
  const TransactionUiState({
    required this.transactions,
    required this.balance,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  final List<TransactionEntity> transactions;
  final double balance;
  final bool hasMore;
  final bool isLoadingMore;

  double get totalIncome => transactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => transactions
      .where((t) => t.isExpense)
      .fold(0.0, (sum, t) => sum + t.amount);

  TransactionUiState copyWith({
    List<TransactionEntity>? transactions,
    double? balance,
    bool? hasMore,
    bool? isLoadingMore,
  }) =>
      TransactionUiState(
        transactions: transactions ?? this.transactions,
        balance: balance ?? this.balance,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}
