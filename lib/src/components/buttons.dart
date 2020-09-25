import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  /// The child of the rounded button
  final Widget child;

  final VoidCallback onPressed;

  final Color backgroundColor;

  final List<BoxShadow> boxShadow;

  final EdgeInsets padding;

  const RoundedButton({
    Key key,
    @required this.child,
    @required this.onPressed,
    this.backgroundColor = Colors.white,
    this.boxShadow,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50.0),
      child: Material(
        type: MaterialType.button,
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: InkWell(
          child: Container(
            padding: padding ??
                const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              boxShadow: boxShadow,
            ),
            child: Center(
              child: child,
            ),
          ),
          onTap: onPressed,
        ),
      ),
    );
  }
}

class CircleButton extends StatelessWidget {
  final Color backgroundColor;

  final EdgeInsets padding;

  final Widget child;

  final VoidCallback onPressed;

  const CircleButton({
    Key key,
    this.backgroundColor,
    this.padding,
    @required this.child,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.button,
      color: backgroundColor,
      shape: CircleBorder(),
      child: InkWell(
        child: Container(
          padding: padding ?? const EdgeInsets.all(10),
          decoration: BoxDecoration(),
          child: Center(
            child: child,
          ),
        ),
        onTap: onPressed,
      ),
    );
  }
}
