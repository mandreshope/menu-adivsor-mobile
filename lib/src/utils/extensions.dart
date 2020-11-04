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

extension Iterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(
      <K, List<E>>{},
      (Map<K, List<E>> map, E element) =>
          map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));
}