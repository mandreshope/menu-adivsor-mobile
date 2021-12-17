import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/utils/extensions.dart';
import 'package:mlkit_translate/mlkit_translate.dart';
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
    this.prefixIcon,
    this.maxLines,
    this.showCursor,
  }) : super(key: key);
  final bool showCursor;
  final int maxLines;
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
  final Widget prefixIcon;

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<SettingContext>(context, listen: false)
        .languageCodeTranslate;
    final langRestaurant = Provider.of<SettingContext>(context, listen: false)
            .languageCodeRestaurantTranslate ??
        lang;
    final isRestaurantPage =
        Provider.of<SettingContext>(context, listen: true).isRestaurantPage;
    return FutureBuilder(
        future: decoration.labelText != null
            ? _translate(
                decoration.labelText, isRestaurantPage ? langRestaurant : lang)
            : _translate(
                decoration.hintText, isRestaurantPage ? langRestaurant : lang),
        builder: (context, snapshot) {
          return TextFormField(
              enabled: enabled,
              focusNode: focusNode,
              controller: controller,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              obscureText: obscureText ?? false,
              maxLines: maxLines,
              showCursor: showCursor,
              decoration: decoration.labelText != null
                  ? InputDecoration(
                      labelText: snapshot.data,
                      suffixIcon: suffixIcon,
                      prefixIcon: prefixIcon,
                      border: border,
                      prefixText: decoration.prefixText ?? "",
                    )
                  : InputDecoration(
                      hintText: snapshot.data,
                      suffixIcon: decoration.suffixIcon,
                      prefixIcon: decoration.prefixIcon,
                      border: decoration.border,
                      prefixText: decoration.prefixText ?? "",
                      focusedErrorBorder: decoration.focusedErrorBorder,
                      focusedBorder: decoration.focusedBorder,
                      enabledBorder: decoration.enabledBorder,
                      errorBorder: decoration.errorBorder,
                      disabledBorder: decoration.disabledBorder,
                    ),
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

  Future<dynamic> _translate(String data, lang) async {
    try {
      // var translate = await FirebaseLanguage.instance.languageTranslator(SupportedLanguages.French, lang).processText(data ?? " ");
      var translate = await MlkitTranslate.translateText(
        source: "fr",
        text: data ?? "",
        target: lang,
      );
      return translate.isEmpty ? data : translate;
    } catch (e) {
      print("error transalator $e");
      return data ?? " ";
    }
  }
}
