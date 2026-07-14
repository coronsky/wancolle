import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat _dateFormat = DateFormat('yyyy/MM/dd');

  static String formatDate(DateTime? date) {
    if (date == null) {
      return '未設定';
    }
    return _dateFormat.format(date);
  }
}
