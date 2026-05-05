/// Validadores de campos de formulário reutilizados em várias telas.
///
/// Cada método retorna `null` quando [value] é válido e uma mensagem de
/// erro localizada caso contrário, seguindo o contrato esperado por
/// [FormField.validator].
class Validators {
  /// Valida um endereço de e-mail.
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'E-mail é obrigatório';
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(value)) return 'E-mail inválido';
    return null;
  }

  /// Valida que a senha está presente e tem ao menos seis caracteres.
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Senha é obrigatória';
    if (value.length < 6) return 'Senha deve ter ao menos 6 caracteres';
    return null;
  }

  /// Valida o nome (não vazio e com ao menos dois caracteres).
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nome é obrigatório';
    if (value.trim().length < 2) return 'Nome muito curto';
    return null;
  }

  /// Valida a string de valor de uma transação.
  ///
  /// Aceita tanto o formato `1.234,56` quanto `1234.56`. Retorna uma
  /// mensagem de erro quando o valor não pode ser interpretado ou não é
  /// estritamente positivo.
  static String? amount(String? value) {
    if (value == null || value.isEmpty) return 'Valor é obrigatório';
    final cleaned = value.replaceAll(',', '.');
    final amount = double.tryParse(cleaned);
    if (amount == null) return 'Valor inválido';
    if (amount <= 0) return 'Valor deve ser maior que zero';
    return null;
  }

  /// Valida a descrição de uma transação (ao menos três caracteres).
  static String? description(String? value) {
    if (value == null || value.trim().isEmpty) return 'Descrição é obrigatória';
    if (value.trim().length < 3) return 'Descrição muito curta';
    return null;
  }
}
