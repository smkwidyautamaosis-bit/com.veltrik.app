import 'package:intl/intl.dart';

class AppDateUtils {
  /// Converts a UTC DateTime to WIB (Waktu Indonesia Barat - UTC+7) and formats it.
  static String toWIB(DateTime utcDate, {String format = 'dd MMM yyyy, HH:mm'}) {
    // Ensure the date is in UTC first, then add 7 hours for WIB
    final wibDate = utcDate.isUtc ? utcDate.add(const Duration(hours: 7)) : utcDate.toUtc().add(const Duration(hours: 7));
    return '${DateFormat(format).format(wibDate)} WIB';
  }

  /// Converts a DateTime to WIB date only (e.g. 26 Mei 2026)
  static String toWIBDateOnly(DateTime utcDate) {
    return toWIB(utcDate, format: 'dd MMM yyyy');
  }
}
