/// Categoria de uma transação financeira.
///
/// O conjunto de categorias é fixo e deriva diretamente da regra de
/// negócio já existente, preservando os mesmos valores persistidos no
/// Firestore.
enum TransactionCategory {
  /// Alimentação.
  food,

  /// Transporte.
  transport,

  /// Saúde.
  health,

  /// Educação.
  education,

  /// Lazer.
  entertainment,

  /// Moradia.
  housing,

  /// Salário.
  salary,

  /// Investimento.
  investment,

  /// Transferência.
  transfer,

  /// Outros (categoria de fallback).
  other,
}

/// Extensões com metadados de UI e conversão segura para
/// [TransactionCategory].
extension TransactionCategoryExtension on TransactionCategory {
  /// Rótulo legível em português, exibido nas telas.
  String get label {
    switch (this) {
      case TransactionCategory.food:
        return 'Alimentação';
      case TransactionCategory.transport:
        return 'Transporte';
      case TransactionCategory.health:
        return 'Saúde';
      case TransactionCategory.education:
        return 'Educação';
      case TransactionCategory.entertainment:
        return 'Lazer';
      case TransactionCategory.housing:
        return 'Moradia';
      case TransactionCategory.salary:
        return 'Salário';
      case TransactionCategory.investment:
        return 'Investimento';
      case TransactionCategory.transfer:
        return 'Transferência';
      case TransactionCategory.other:
        return 'Outros';
    }
  }

  /// Pictograma associado à categoria, exibido nas telas. Os caracteres
  /// emoji fazem parte do conteúdo de UI já existente e são preservados
  /// para manter o visual original.
  String get icon {
    switch (this) {
      case TransactionCategory.food:
        return '🍔';
      case TransactionCategory.transport:
        return '🚌';
      case TransactionCategory.health:
        return '💊';
      case TransactionCategory.education:
        return '📚';
      case TransactionCategory.entertainment:
        return '🎭';
      case TransactionCategory.housing:
        return '🏠';
      case TransactionCategory.salary:
        return '💰';
      case TransactionCategory.investment:
        return '📈';
      case TransactionCategory.transfer:
        return '↔️';
      case TransactionCategory.other:
        return '📦';
    }
  }

  /// Converte uma [String] persistida em uma [TransactionCategory],
  /// retornando [TransactionCategory.other] como fallback seguro.
  static TransactionCategory fromString(String value) {
    return TransactionCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TransactionCategory.other,
    );
  }
}
