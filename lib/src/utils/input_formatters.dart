import 'package:flutter/services.dart';

class NumberCardInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) return newValue;

    if (newValue.selection.baseOffset > 8) return oldValue;

    String newText = "";

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText;

    if (newValue.selection.baseOffset < 2)
      newText = newValue.text;
    else if (newValue.selection.baseOffset == 2)
      newText = newValue.text + '/';
    else
      newText = newValue.text;

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
