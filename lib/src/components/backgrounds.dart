import 'package:flutter/material.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/utils/clippers.dart';

class WaveBackground extends StatelessWidget {
  /// Size of the wave background
  final Size size;

  /// The child widget
  final Widget child;

  /// The color of the background
  final Color color;

  const WaveBackground({
    Key key,
    @required this.child,
    this.size = const Size(300, 200),
    this.color = CRIMSON,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              color: color,
            ),
          ),
          Transform.translate(
            offset: Offset(
              0,
              -size.height / 5,
            ),
            child: child,
          )
        ],
      ),
    );
  }
}

class PlaceholderBackground extends StatelessWidget {
  final String title;
  final double width;
  final double height;
  PlaceholderBackground({
    this.title,
    this.width,
    this.height,
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[100],
      child: Center(
        child: Text(
          title ?? "P",
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.headline1.fontSize,
            color: Colors.grey[300],
          ),
        ),
      ),
    );
  }
}
