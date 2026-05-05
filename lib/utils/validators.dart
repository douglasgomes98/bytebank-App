class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'E-mail é obrigatório';
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(value)) return 'E-mail inválido';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Senha é obrigatória';
    if (value.length < 6) return 'Senha deve ter ao menos 6 caracteres';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nome é obrigatório';
    if (value.trim().length < 2) return 'Nome muito curto';
    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.isEmpty) return 'Valor é obrigatório';
    final cleaned = value.replaceAll(',', '.');
    final amount = double.tryParse(cleaned);
    if (amount == null) return 'Valor inválido';
    if (amount <= 0) return 'Valor deve ser maior que zero';
    return null;
  }

  static String? description(String? value) {
    if (value == null || value.trim().isEmpty) return 'Descrição é obrigatória';
    if (value.trim().length < 3) return 'Descrição muito curta';
    return null;
  }
}
