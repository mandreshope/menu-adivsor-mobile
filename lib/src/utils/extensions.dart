import 'package:firebase_mlkit_language/firebase_mlkit_language.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menu_advisor/src/models.dart';

extension FormatDate on DateTime {
  String dateToString(String format) {
    final DateFormat formatter = DateFormat(format);
    final String formatted = formatter.format(this);
    return formatted;
  }

  String get weekDayToString {
    final DateTime dateNow = DateTime.now();
    switch (dateNow.weekday) {
      case 1:
        return "lundi";
        break;
      case 2:
        return "mardi";
        break;
      case 3:
        return "mercredi";
        break;
      case 4:
        return "jeudi";
        break;
      case 5:
        return "vendredi";
        break;
      case 6:
        return "samedi";
        break;
      case 7:
        return "dimanche";
        break;
      default:
        return "lundi";
    }
  }
}

extension ExtensionString on String {
  isValidateEmail() => RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(this);

  Future<String> translator(lang) async {
    try {
      // var translate = await data.translate(to: "ko");
      var translate = await FirebaseLanguage.instance.languageTranslator(SupportedLanguages.French, lang).processText(this ?? " ");
      return translate ?? " ";
    } catch (e) {
      print("error transalator $e");
      return this ?? " ";
    }
  }

  String get codeCountry {
    switch (this) {
      case "en":
        return 'us';
      case 'ja':
        return 'jp';
      case 'zh':
        return 'cn';
      case 'ko':
        return 'kr';
      case 'ar':
        return "ae";
    }
    return this;
  }

  String get month {
    switch (this) {
      case "01":
        return "Janvier";
      case "02":
        return 'Février';
      case "03":
        return "Mars";
      case "04":
        return "Avril";
      case "05":
        return "Mai";
      case "06":
        return "Juin";
      case "07":
        return "Juillet";
      case "08":
        return "Août";
      case "09":
        return "Septembre";
      case "10":
        return "Octobre";
      case "11":
        return "Novembre";
      case "12":
        return "Décembre";
      default:
        return "Janvier";
    }
  }
}

extension Iterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(<K, List<E>>{}, (Map<K, List<E>> map, E element) => map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));
}

extension Type on MenuType {
  String get value => describeEnum(this);
}

extension Time on TimeOfDay {
  double get timeOfDayToDouble => this.hour + this.minute / 60.0;
}
