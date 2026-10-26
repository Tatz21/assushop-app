import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static String formatCurrency(num amount) {
    return _currencyFormat.format(amount).replaceAll('₹', '₹ ');
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatHeaderDate(DateTime date) {
    return DateFormat('EEE, d MMM yyyy').format(date);
  }

  static String formatDistance(double km) {
    return '${km.toStringAsFixed(1)} km';
  }
}
