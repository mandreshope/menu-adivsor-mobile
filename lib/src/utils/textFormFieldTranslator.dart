import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/utils/extensions.dart';
import 'package:provider/provider.dart';

class TextFormFieldTranslator extends StatelessWidget {
  const TextFormFieldTranslator({
    Key key,
    this.controller,
    this.enabled = true,
    this.focusNode,
    this.decoration,
    this.onChanged,
    this.onFieldSubmitted,
    this.textInputAction,
    this.keyboardType,
    this.obscureText,
    this.validator,
    this.inputFormatters,
    this.maxLength,
    this.autofocus,
    this.textAlign,
    this.suffixIcon,
    this.border,
    this.onTap,
  }) : super(key: key);

  final FocusNode focusNode;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final InputDecoration decoration;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onFieldSubmitted;
  final bool obscureText;
  final bool autofocus;
  final FormFieldValidator<String> validator;
  final List<TextInputFormatter> inputFormatters;
  final int maxLength;
  final TextAlign textAlign;
  final Widget suffixIcon;
  final InputBorder border;
  final void Function() onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<SettingContext>(context, listen: false).languageCodeTranslate;
    return FutureBuilder<String>(
        future: decoration.labelText != null ? decoration.labelText.translator(lang) : decoration.hintText.translator(lang),
        builder: (context, snapshot) {
          return TextFormField(
              enabled: enabled,
              focusNode: focusNode,
              controller: controller,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              obscureText: obscureText ?? false,
              decoration: decoration.labelText != null
                  ? InputDecoration(
                      labelText: snapshot.data,
                      suffixIcon: suffixIcon,
                      border: border,
                      prefixText: decoration.prefixText ?? "",
                    )
                  : decoration,
              onTap: onTap,
              onChanged: onChanged,
              onFieldSubmitted: onFieldSubmitted,
              validator: validator,
              inputFormatters: inputFormatters,
              maxLength: maxLength,
              autofocus: autofocus ?? false,
              textAlign: textAlign ?? TextAlign.start);
        });
  }
}
