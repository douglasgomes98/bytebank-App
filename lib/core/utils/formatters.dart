import 'package:intl/intl.dart';

/// Funções utilitárias centralizadas para formatação de moeda, datas e
/// entrada numérica.
///
/// Todos os formatadores são configurados para o locale `pt_BR` para manter
/// a renderização de moeda e datas consistente em toda a aplicação.
class Formatters {
  static final _currencyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static final _dateFormatter = DateFormat('dd/MM/yyyy', 'pt_BR');
  static final _dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
  static final _monthYearFormatter = DateFormat('MMMM yyyy', 'pt_BR');

  /// Formata [amount] como moeda brasileira (ex.: `R$ 1.234,56`).
  static String currency(double amount) => _currencyFormatter.format(amount);

  /// Formata [date] no padrão `dd/MM/yyyy`.
  static String date(DateTime date) => _dateFormatter.format(date);

  /// Formata [date] no padrão `dd/MM/yyyy HH:mm`.
  static String dateTime(DateTime date) => _dateTimeFormatter.format(date);

  /// Formata [date] como rótulo de mês/ano localizado (ex.: `maio 2026`).
  static String monthYear(DateTime date) => _monthYearFormatter.format(date);

  /// Converte uma string de valor digitada pelo usuário em [double].
  ///
  /// Símbolos de moeda, espaços e separadores de milhar brasileiros são
  /// removidos, e a vírgula decimal é normalizada para ponto. Valores
  /// inválidos retornam `0.0`.
  static double parseAmount(String value) {
    final cleaned = value
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0.0;
  }
}
