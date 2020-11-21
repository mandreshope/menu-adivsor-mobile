import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';

class TextTranslator extends StatelessWidget {
  const TextTranslator(this.data,{Key key,this.locale,
  this.maxLines,this.overflow,this.semanticsLabel,this.softWrap,
  this.strutStyle,this.style,this.textAlign,this.textDirection,
  this.textHeightBehavior,this.textScaleFactor,this.textWidthBasis}) : super(key: key);
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


  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<SettingContext>(context).languageCode;
    return FutureBuilder(
      future: data.translate(to: 'en'),
      builder: (_,data){
        if (!data.hasData){
          return Center(child: CupertinoActivityIndicator(animating: true,));
        }else{
          return Text(
            data.data.toString(),
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
      }
    );
  }
}