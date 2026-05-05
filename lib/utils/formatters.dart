import 'package:intl/intl.dart';

class Formatters {
  static final _currencyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static final _dateFormatter = DateFormat('dd/MM/yyyy', 'pt_BR');
  static final _dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
  static final _monthYearFormatter = DateFormat('MMMM yyyy', 'pt_BR');

  static String currency(double amount) => _currencyFormatter.format(amount);

  static String date(DateTime date) => _dateFormatter.format(date);

  static String dateTime(DateTime date) => _dateTimeFormatter.format(date);

  static String monthYear(DateTime date) => _monthYearFormatter.format(date);

  static double parseAmount(String value) {
    final cleaned = value
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0.0;
  }
}
