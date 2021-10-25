import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

enum FadeAnimationType { opacity, translateY }

class FadeAnimation extends StatelessWidget {
  final double delay;
  final Widget child;
  final Curve curve;

  FadeAnimation(
    this.delay,
    this.child, {
    this.curve = Curves.linear,
  });

  final _tween = MultiTween<FadeAnimationType>()
    ..add(FadeAnimationType.opacity, Tween(begin: 0.0, end: 1.0), Duration(milliseconds: 500))
    ..add(FadeAnimationType.translateY, Tween(begin: 30.0, end: 0.0), Duration(milliseconds: 500));

  @override
  Widget build(BuildContext context) {
    return PlayAnimation<MultiTweenValues<FadeAnimationType>>(
      tween: _tween,
      duration: _tween.duration,
      delay: Duration(seconds: delay.toInt()),
      curve: curve,
      child: child,
      builder: (context, child, value) {
        return Opacity(
          opacity: value.get(FadeAnimationType.opacity),
          child: Transform.translate(
            offset: Offset(0.0, value.get(FadeAnimationType.translateY)),
            child: child,
          ),
        );
      },
    );
  }
}
