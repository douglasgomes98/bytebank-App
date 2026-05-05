import 'transaction_category.dart';
import 'transaction_type.dart';

/// Entidade de domínio que representa uma transação financeira.
///
/// É renomeada para `TransactionEntity` (em vez de `Transaction`) para
/// eliminar a colisão com `cloud_firestore.Transaction`, que antes era
/// resolvida via `hide` no import. A classe é Dart pura, imutável e não
/// importa nenhum pacote de infraestrutura.
class TransactionEntity {
  /// Identificador único do documento.
  final String id;

  /// Identificador do usuário dono da transação.
  final String userId;

  /// Texto descritivo informado pelo usuário.
  final String description;

  /// Valor da transação em reais. Sempre positivo; o sinal é dado pelo
  /// [type].
  final double amount;

  /// Tipo da transação (receita, despesa, transferência).
  final TransactionType type;

  /// Categoria da transação.
  final TransactionCategory category;

  /// Data em que a transação ocorreu (informada pelo usuário).
  final DateTime date;

  /// URL pública do comprovante anexado, quando existente.
  final String? receiptUrl;

  /// Observações livres informadas pelo usuário.
  final String? notes;

  /// Data em que o registro foi criado.
  final DateTime createdAt;

  /// Cria uma instância imutável de [TransactionEntity].
  const TransactionEntity({
    required this.id,
    required this.userId,
    required this.description,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.receiptUrl,
    this.notes,
    required this.createdAt,
  });

  /// `true` quando a transação é do tipo [TransactionType.income].
  bool get isIncome => type == TransactionType.income;

  /// `true` quando a transação é do tipo [TransactionType.expense].
  bool get isExpense => type == TransactionType.expense;

  /// Retorna uma cópia desta entidade substituindo apenas os campos
  /// informados, preservando os demais.
  TransactionEntity copyWith({
    String? id,
    String? userId,
    String? description,
    double? amount,
    TransactionType? type,
    TransactionCategory? category,
    DateTime? date,
    String? receiptUrl,
    String? notes,
    DateTime? createdAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
