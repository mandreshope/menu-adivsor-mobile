import 'package:intl/intl.dart';


extension FormatDate on DateTime {
  String dateToString(String format) {
    final DateFormat formatter = DateFormat(format);
    final String formatted = formatter.format(this);
    return formatted;
  }
}

extension ExtensionString on String {
  isValidateEmail() => RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(this);
}