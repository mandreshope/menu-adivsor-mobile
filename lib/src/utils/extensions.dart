import 'package:intl/intl.dart';


extension FormatDate on DateTime {
  String dateToString(String format) {
    final DateFormat formatter = DateFormat(format);
    final String formatted = formatter.format(this);
    return formatted;
  }
}

