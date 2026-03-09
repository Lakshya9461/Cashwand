import 'package:intl/intl.dart';

/// Currency formatting utility for INR.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final _formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final _compactFormatter = NumberFormat.compactCurrency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  /// Formats amount as ₹1,234.56
  static String format(double amount) => _formatter.format(amount);

  /// Formats amount as ₹1.2K for large numbers
  static String formatCompact(double amount) =>
      _compactFormatter.format(amount);

  /// Formats with sign: +₹5,000.00 or -₹250.00
  static String formatSigned(double amount) {
    final prefix = amount >= 0 ? '+' : '';
    return '$prefix${_formatter.format(amount)}';
  }
}
