import 'dart:convert';

import 'package:flutter/material.dart';

class RestaurantLivraisonMatrix {
  final String distance;
  final String price;
  final String duration;
  RestaurantLivraisonMatrix({
    @required this.distance,
    @required this.price,
    @required this.duration,
  });

  RestaurantLivraisonMatrix copyWith({
    String distance,
    String price,
    String duration,
  }) {
    return RestaurantLivraisonMatrix(
      distance: distance ?? this.distance,
      price: price ?? this.price,
      duration: duration ?? this.duration,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'distance': distance,
      'price': price,
      'duration': duration,
    };
  }

  factory RestaurantLivraisonMatrix.fromMap(Map<String, dynamic> map) {
    return RestaurantLivraisonMatrix(
      distance: map['distance'],
      price: map['price'],
      duration: map['duration'],
    );
  }

  String toJson() => json.encode(toMap());

  factory RestaurantLivraisonMatrix.fromJson(String source) => RestaurantLivraisonMatrix.fromMap(json.decode(source));

  @override
  String toString() => 'RestaurantLivraisonMatrix(distance: $distance, price: $price, duration: $duration)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RestaurantLivraisonMatrix && other.distance == distance && other.price == price && other.duration == duration;
  }

  @override
  int get hashCode => distance.hashCode ^ price.hashCode ^ duration.hashCode;
}
