import 'package:flutter/material.dart';

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width / 5, 0)
      ..quadraticBezierTo(0, 0, 0, 3 * size.height / 11)
      ..quadraticBezierTo(0, 7 * size.height / 9, size.width, size.height)
      ..lineTo(size.width, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return false;
  }
}
