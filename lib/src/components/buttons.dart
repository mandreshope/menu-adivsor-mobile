import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  /// The child of the rounded button
  final Widget child;

  final void Function() onPressed;

  final Color backgroundColor;

  final List<BoxShadow> boxShadow;

  const RoundedButton({
    Key key,
    @required this.child,
    this.onPressed,
    this.backgroundColor = Colors.white,
    this.boxShadow,
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              boxShadow: boxShadow,
            ),
            child: child,
          ),
          onTap: () {},
        ),
      ),
    );
  }
}
