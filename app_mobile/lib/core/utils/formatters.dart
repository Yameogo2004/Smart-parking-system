import 'package:intl/intl.dart';

class Formatters {
  static String currency(double value) {
    final format = NumberFormat.currency(locale: 'fr_FR', symbol: 'MAD ');
    return format.format(value);
  }

  static String date(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String time(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
}
