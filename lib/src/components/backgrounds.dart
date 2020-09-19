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
