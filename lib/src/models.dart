import 'package:flutter/material.dart';
import 'package:menu_advisor/src/types.dart';

class Food {
  final String name;

  final FoodType type;

  final Location location;

  final double ratings;

  Food({
    @required this.name,
    @required this.location,
    @required this.type,
    this.ratings = 0,
  });
}

class Restaurant {
  final String name;

  Restaurant({
    this.name,
  });
}
