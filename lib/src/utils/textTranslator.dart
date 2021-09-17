import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:mlkit_translate/mlkit_translate.dart';
import 'package:provider/provider.dart';

class TextTranslator extends StatelessWidget {
  const TextTranslator(
    this.data, {
    Key key,
    this.locale,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
    this.softWrap,
    this.strutStyle,
    this.style,
    this.textAlign,
    this.textDirection,
    this.textHeightBehavior,
    this.textScaleFactor,
    this.textWidthBasis,
    this.isAutoSizeText = false,
  }) : super(key: key);
  // final Text child;
  final String data;
  final TextStyle style;
  final int maxLines;
  final TextOverflow overflow;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final Locale locale;
  final String semanticsLabel;
  final bool softWrap;
  final StrutStyle strutStyle;
  final TextHeightBehavior textHeightBehavior;
  final double textScaleFactor;
  final TextWidthBasis textWidthBasis;
  final bool isAutoSizeText;

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<SettingContext>(context, listen: false).languageCodeTranslate;
    final langRestaurant = Provider.of<SettingContext>(context, listen: false).languageCodeRestaurantTranslate ?? lang;
    final isRestaurantPage = Provider.of<SettingContext>(context, listen: true).isRestaurantPage;

    return FutureBuilder(
        future: _translate(isRestaurantPage ? langRestaurant : lang),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CupertinoActivityIndicator(
              animating: true,
            ));
          } else {
            return isAutoSizeText
                ? AutoSizeText(
                    snapshot.data,
                    style: this.style,
                    maxLines: this.maxLines,
                    overflow: this.overflow,
                    textAlign: this.textAlign,
                    textDirection: this.textDirection,
                    locale: this.locale,
                    semanticsLabel: this.semanticsLabel,
                    softWrap: this.softWrap,
                    strutStyle: this.strutStyle,
                  )
                : Text(
                    snapshot.data,
                    style: this.style,
                    maxLines: this.maxLines,
                    overflow: this.overflow,
                    textAlign: this.textAlign,
                    textDirection: this.textDirection,
                    locale: this.locale,
                    semanticsLabel: this.semanticsLabel,
                    softWrap: this.softWrap,
                    strutStyle: this.strutStyle,
                    textHeightBehavior: this.textHeightBehavior,
                    textScaleFactor: this.textScaleFactor,
                    textWidthBasis: this.textWidthBasis,
                  );
          }
        });
  }

  Future<dynamic> _translate(lang) async {
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
