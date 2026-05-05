/// Tipo de uma transação financeira no domínio.
///
/// Mantém os três valores já presentes na regra de negócio existente:
/// receita, despesa e transferência.
enum TransactionType {
  /// Entrada de dinheiro (salário, recebimento, etc.).
  income,

  /// Saída de dinheiro (compra, conta, etc.).
  expense,

  /// Transferência entre contas/destinos.
  transfer,
}

/// Extensões com metadados de UI e conversão segura para [TransactionType].
extension TransactionTypeExtension on TransactionType {
  /// Rótulo legível em português, usado nas telas.
  String get label {
    switch (this) {
      case TransactionType.income:
        return 'Receita';
      case TransactionType.expense:
        return 'Despesa';
      case TransactionType.transfer:
        return 'Transferência';
    }
  }

  /// Converte uma [String] persistida em um [TransactionType], retornando
  /// [TransactionType.expense] caso o valor seja desconhecido (defesa
  /// contra dados de Firestore corrompidos).
  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TransactionType.expense,
    );
  }
}
