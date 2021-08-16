import 'package:flutter/cupertino.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';

class Validators {
  Validators._privateConstructor();

  static String Function(String) required(BuildContext context) => (String value) {
        if (value.isEmpty) return AppLocalizations.of(context).translate('field_must_not_be_blank');

        return null;
      };
}
