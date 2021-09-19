import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:menu_advisor/src/models/restaurants/restaurant_livraison_matrix_model.dart';

class RestaurantLivraison {
  final List<String> freeCity;
  final List<String> freeCP;
  final List<String> matrix;
  RestaurantLivraison({
    this.freeCity,
    this.freeCP,
    this.matrix,
  });

  RestaurantLivraison copyWith({
    List<String> freeCity,
    List<String> freeCP,
    List<String> matrix,
  }) {
    return RestaurantLivraison(
      freeCity: freeCity ?? this.freeCity,
      freeCP: freeCP ?? this.freeCP,
      matrix: matrix ?? this.matrix,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'freeCity': freeCity,
      'freeCP': freeCP,
      'MATRIX': matrix?.map((e) => e)?.toList(),
    };
  }

  factory RestaurantLivraison.fromMap(Map<String, dynamic> map) {
    return RestaurantLivraison(
      freeCity: map['freeCity'] != null ? List<String>.from(map['freeCity']) : [],
      freeCP: map['freeCP'] != null ? List<String>.from(map['freeCP']) : [],
      matrix: map['MATRIX'] != null ? List<String>.from(map['MATRIX']) : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory RestaurantLivraison.fromJson(String source) => RestaurantLivraison.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Livraison(freeCity: $freeCity, freeCP: $freeCP, matrix: $matrix)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RestaurantLivraison && listEquals(other.freeCity, freeCity) && listEquals(other.freeCP, freeCP) && other.matrix == matrix;
  }

  @override
  int get hashCode {
    return freeCity.hashCode ^ freeCP.hashCode ^ matrix.hashCode;
  }
}
