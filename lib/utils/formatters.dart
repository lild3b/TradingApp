import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static final _currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  static final _percent = NumberFormat('0.0');
  static final _dateDisplay = DateFormat('dd MMM yyyy');
  static final _dateTimeDisplay = DateFormat('dd MMM yyyy • HH:mm');
  static final _monthYear = DateFormat('MMMM yyyy');
  static final _timeOnly = DateFormat('HH:mm');
  static final _shortDate = DateFormat('MMM d');

  static String currency(double value) => _currency.format(value);

  static String pnl(double value) {
    final formatted = _currency.format(value.abs());
    return value >= 0 ? '+$formatted' : '-$formatted';
  }

  static String percent(double value) => '${_percent.format(value)}%';

  static String date(DateTime dt) => _dateDisplay.format(dt);

  static String dateTime(DateTime dt) => _dateTimeDisplay.format(dt);

  static String monthYear(DateTime dt) => _monthYear.format(dt);

  static String timeOnly(DateTime dt) => _timeOnly.format(dt);

  static String shortDate(DateTime dt) => _shortDate.format(dt);

  static String rrRatio(double rr) => '${rr.toStringAsFixed(2)}R';

  static String fileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
