import 'package:flutter/foundation.dart';

/// Logger que suprime mensagens em release e oferece utilidades para
/// redigir PII antes de qualquer escrita.
///
/// Em [kReleaseMode] todos os métodos são no-op, evitando vazamento de
/// dados e logs persistentes em dispositivos de produção. Em
/// desenvolvimento delega para [debugPrint], que respeita o limite de
/// taxa do Flutter.
class SecureLogger {
  const SecureLogger._();

  /// Emite uma mensagem informativa apenas em modo debug/profile.
  static void info(String message) {
    if (kReleaseMode) return;
    debugPrint('[INFO] $message');
  }

  /// Emite uma mensagem de aviso apenas em modo debug/profile.
  static void warning(String message) {
    if (kReleaseMode) return;
    debugPrint('[WARN] $message');
  }

  /// Emite uma mensagem de erro apenas em modo debug/profile.
  static void error(String message, [Object? error, StackTrace? stack]) {
    if (kReleaseMode) return;
    debugPrint('[ERROR] $message');
    if (error != null) debugPrint('  cause: $error');
    if (stack != null) debugPrint(stack.toString());
  }

  /// Substitui caracteres internos de [value] por `*`, preservando os
  /// dois primeiros e os dois últimos. Útil para logar identificadores
  /// sem expor o valor inteiro. Retorna `'***'` quando o valor é nulo
  /// ou muito curto para ser parcialmente exibido.
  static String redact(String? value) {
    if (value == null || value.length < 5) return '***';
    final start = value.substring(0, 2);
    final end = value.substring(value.length - 2);
    return '$start***$end';
  }
}
