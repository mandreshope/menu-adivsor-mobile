import 'package:flutter/material.dart';

class MenuAdvisorTextLogo extends StatelessWidget {
  /// Color of the logo
  final Color color;

  /// The font size basis
  final double fontSize;

  final CrossAxisAlignment crossAxisAlignment;

  const MenuAdvisorTextLogo({
    Key key,
    this.color = Colors.white,
    this.fontSize = 36,
    this.crossAxisAlignment = CrossAxisAlignment.end,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Menu".toUpperCase(),
          style: TextStyle(
            fontSize: fontSize * 0.9,
            color: color,
            fontFamily: "Soft Elegance",
          ),
        ),
        RichText(
          text: TextSpan(children: [
            TextSpan(
              text: "Advis",
              style: TextStyle(
                fontSize: fontSize * 1.30,
                color: color,
                fontFamily: "Golden Ranger",
              ),
            ),
            WidgetSpan(
              child: Padding(
                padding: const EdgeInsets.only(right: 3.0),
                child: Image.asset(
                  "assets/images/round.png",
                  height: fontSize * 0.7,
                ),
              ),
            ),
            TextSpan(
              text: "r",
              style: TextStyle(
                fontSize: fontSize * 1.30,
                color: color,
                fontFamily: "Golden Ranger",
              ),
            ),
          ]),
        )
      ],
    );
  }
}

class MenuAdvisorLogo extends StatelessWidget {
  final double size;

  const MenuAdvisorLogo({
    Key key,
    @required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.asset(
        "assets/images/logo.png",
        width: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
