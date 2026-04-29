import 'package:intl/intl.dart';

class FormatHelper {
  static String date(String iso) {
    try {
      return DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  static String currency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(amount);
  }
}
