import 'package:flutter/material.dart';

class Location {
  final double latitude;
  final double longitude;

  Location({
    @required this.latitude,
    @required this.longitude,
  });
}

class FoodType {
  final String type;

  FoodType({
    @required this.type,
  });
}
