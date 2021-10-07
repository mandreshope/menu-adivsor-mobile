import 'dart:convert';

import 'package:flutter/foundation.dart';

class RestaurantDiscount {
  final Delivery delivery;
  final AEmporter aEmporter;
  final CodeDiscount codeDiscount;
  RestaurantDiscount({
    this.delivery,
    this.aEmporter,
    this.codeDiscount,
  });

  RestaurantDiscount copyWith({
    Delivery delivery,
    AEmporter aEmporter,
    CodeDiscount codeDiscount,
  }) {
    return RestaurantDiscount(
      delivery: delivery ?? this.delivery,
      aEmporter: aEmporter ?? this.aEmporter,
      codeDiscount: codeDiscount ?? this.codeDiscount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'delivery': delivery.toMap(),
      'aEmporter': aEmporter.toMap(),
      'codeDiscount': codeDiscount.toMap(),
    };
  }

  factory RestaurantDiscount.fromMap(Map<String, dynamic> map) {
    return RestaurantDiscount(
      delivery: Delivery.fromMap(map['delivery']),
      aEmporter: AEmporter.fromMap(map['aEmporter']),
      codeDiscount: CodeDiscount.fromMap(map['codeDiscount']),
    );
  }

  String toJson() => json.encode(toMap());

  factory RestaurantDiscount.fromJson(String source) => RestaurantDiscount.fromMap(json.decode(source));

  @override
  String toString() => 'RestaurantDiscount(delivery: $delivery, aEmporter: $aEmporter, codeDiscount: $codeDiscount)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RestaurantDiscount && other.delivery == delivery && other.aEmporter == aEmporter && other.codeDiscount == codeDiscount;
  }

  @override
  int get hashCode => delivery.hashCode ^ aEmporter.hashCode ^ codeDiscount.hashCode;
}

class Delivery {
  final bool discountIsPrice;
  final String value;
  double get valueDouble => double.tryParse(value) ?? 0.0;
  Delivery({
    this.discountIsPrice,
    this.value,
  });

  Delivery copyWith({
    bool discountIsPrice,
    String value,
  }) {
    return Delivery(
      discountIsPrice: discountIsPrice ?? this.discountIsPrice,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'discountIsPrice': discountIsPrice,
      'value': value,
    };
  }

  factory Delivery.fromMap(Map<String, dynamic> map) {
    return Delivery(
      discountIsPrice: map['discountIsPrice'],
      value: map['value'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Delivery.fromJson(String source) => Delivery.fromMap(json.decode(source));

  @override
  String toString() => 'Delivery(discountIsPrice: $discountIsPrice, value: $value)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Delivery && other.discountIsPrice == discountIsPrice && other.value == value;
  }

  @override
  int get hashCode => discountIsPrice.hashCode ^ value.hashCode;
}

class AEmporter {
  final bool discountIsPrice;
  final String value;
  double get valueDouble => double.tryParse(value) ?? 0.0;
  AEmporter({
    this.discountIsPrice,
    this.value,
  });

  AEmporter copyWith({
    bool discountIsPrice,
    String value,
  }) {
    return AEmporter(
      discountIsPrice: discountIsPrice ?? this.discountIsPrice,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'discountIsPrice': discountIsPrice,
      'value': value,
    };
  }

  factory AEmporter.fromMap(Map<String, dynamic> map) {
    return AEmporter(
      discountIsPrice: map['discountIsPrice'],
      value: map['value'],
    );
  }

  String toJson() => json.encode(toMap());

  factory AEmporter.fromJson(String source) => AEmporter.fromMap(json.decode(source));

  @override
  String toString() => 'AEmporter(discountIsPrice: $discountIsPrice, value: $value)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AEmporter && other.discountIsPrice == discountIsPrice && other.value == value;
  }

  @override
  int get hashCode => discountIsPrice.hashCode ^ value.hashCode;
}

class CodeDiscount {
  final bool discountIsPrice;
  final String value;
  double get valueDouble => double.tryParse(value) ?? 0.0;
  final List<String> code;
  CodeDiscount({
    this.discountIsPrice,
    this.value,
    this.code,
  });

  CodeDiscount copyWith({
    bool discountIsPrice,
    String value,
    List<String> code,
  }) {
    return CodeDiscount(
      discountIsPrice: discountIsPrice ?? this.discountIsPrice,
      value: value ?? this.value,
      code: code ?? this.code,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'discountIsPrice': discountIsPrice,
      'value': value,
      'code': code,
    };
  }

  factory CodeDiscount.fromMap(Map<String, dynamic> map) {
    return CodeDiscount(
      discountIsPrice: map['discountIsPrice'],
      value: map['value'],
      code: List<String>.from(map['code']),
    );
  }

  String toJson() => json.encode(toMap());

  factory CodeDiscount.fromJson(String source) => CodeDiscount.fromMap(json.decode(source));

  @override
  String toString() => 'CodeDiscount(discountIsPrice: $discountIsPrice, value: $value, code: $code)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CodeDiscount && other.discountIsPrice == discountIsPrice && other.value == value && listEquals(other.code, code);
  }

  @override
  int get hashCode => discountIsPrice.hashCode ^ value.hashCode ^ code.hashCode;
}
