import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _numberFormat = NumberFormat('#,##0.##');
  static final _dateFormat = DateFormat('d MMM yyyy');

  static String money(num value) => '${_numberFormat.format(value)} ₪';

  static String number(num value) => _numberFormat.format(value);

  static String date(DateTime date) => _dateFormat.format(date);

  static String dateFromIso(String isoDate) {
    try {
      return _dateFormat.format(DateTime.parse(isoDate));
    } catch (_) {
      return isoDate;
    }
  }
}
