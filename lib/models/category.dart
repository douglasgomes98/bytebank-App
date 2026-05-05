enum TransactionCategory {
  food,
  transport,
  health,
  education,
  entertainment,
  housing,
  salary,
  investment,
  transfer,
  other,
}

extension TransactionCategoryExtension on TransactionCategory {
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

  static TransactionCategory fromString(String value) {
    return TransactionCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TransactionCategory.other,
    );
  }
}
