import 'package:intl/intl.dart';

/// Formats [amount] using [symbol] and [decimalPlaces].
/// Used everywhere amounts are displayed so currency+decimal prefs
/// apply globally without each widget knowing about the provider.
String formatAmount(double amount, String symbol, int decimalPlaces) {
  final pattern = decimalPlaces == 0
      ? '#,##0'
      : '#,##0.${'0' * decimalPlaces}';
  final fmt = NumberFormat(pattern, 'en_IN');
  return '$symbol${fmt.format(amount)}';
}

/// Returns a [NumberFormat] matching [decimalPlaces].
NumberFormat amountFormat(int decimalPlaces) {
  final pattern = decimalPlaces == 0
      ? '#,##0'
      : '#,##0.${'0' * decimalPlaces}';
  return NumberFormat(pattern, 'en_IN');
}
