import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:menu_advisor/src/models/restaurants/restaurant_code_discount_model.dart';
import 'package:menu_advisor/src/models/restaurants/restaurant_plage_discount_model.dart';

enum DiscountType {
  SurTransport,
  SurCommande,
  SurTotalite,
}

class RestaurantDiscount {
  final Delivery delivery;
  final AEmporter aEmporter;
  final List<CodeDiscount> codeDiscount;

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
      'delivery': delivery?.toMap(),
      'aEmporter': aEmporter?.toMap(),
      'codeDiscount': codeDiscount?.map((x) => x.toMap())?.toList()
    };
  }

  factory RestaurantDiscount.fromMap(Map<String, dynamic> map) {
    return RestaurantDiscount(
        delivery: Delivery.fromMap(map['delivery']),
        aEmporter: AEmporter.fromMap(map['aEmporter']),
        codeDiscount: map['codeDiscount'] != null
            ? List<CodeDiscount>.from(
                map['codeDiscount']?.map((x) => CodeDiscount.fromMap(x)))
            : []);
  }

  String toJson() => json.encode(toMap());

  factory RestaurantDiscount.fromJson(String source) =>
      RestaurantDiscount.fromMap(json.decode(source));

  @override
  String toString() =>
      'RestaurantDiscount(delivery: $delivery, aEmporter: $aEmporter, codeDiscount: $codeDiscount)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RestaurantDiscount &&
        other.delivery == delivery &&
        other.aEmporter == aEmporter &&
        listEquals(other.codeDiscount, codeDiscount);
  }

  @override
  int get hashCode =>
      delivery.hashCode ^ aEmporter.hashCode ^ codeDiscount.hashCode;
}

class Delivery {
  final bool discountIsPrice;
  final String value;
  final List<PlageDiscount> plageDiscount;

  double get valueDouble => double.tryParse(value) ?? 0.0;
  final DiscountType discountType;
  String get discountTypeExplainText => discountType == DiscountType.SurCommande
      ? "commande"
      : discountType == DiscountType.SurTransport
          ? "livraison"
          : "totalité";

  Delivery({
    this.discountIsPrice,
    this.value,
    this.discountType,
    this.plageDiscount,
  });

  Delivery copyWith({
    bool discountIsPrice,
    String value,
    DiscountType discountType,
    List<PlageDiscount> plageDiscount,
  }) {
    return Delivery(
      discountIsPrice: discountIsPrice ?? this.discountIsPrice,
      value: value ?? this.value,
      discountType: discountType ?? this.discountType,
      plageDiscount: plageDiscount ?? this.plageDiscount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'discountIsPrice': discountIsPrice,
      'value': value,
      'discountType': discountType == DiscountType.SurTotalite
          ? "SurTotalité"
          : describeEnum(discountType),
      'plageDiscount': plageDiscount?.map((x) => x.toMap())?.toList()
    };
  }

  factory Delivery.fromMap(Map<String, dynamic> map) {
    return Delivery(
        discountIsPrice: map['discountIsPrice'],
        value: map['value']?.toString(),
        discountType: map['discountType'] == "SurTransport"
            ? DiscountType.SurTransport
            : map['discountType'] == "SurCommande"
                ? DiscountType.SurCommande
                : DiscountType.SurTotalite,
        plageDiscount: map['plageDiscount'] != null
            ? List<PlageDiscount>.from(
                map['plageDiscount']?.map((x) => PlageDiscount.fromMap(x)))
            : []);
  }

  String toJson() => json.encode(toMap());

  factory Delivery.fromJson(String source) =>
      Delivery.fromMap(json.decode(source));

  @override
  String toString() =>
      'Delivery(discountIsPrice: $discountIsPrice, value: $value, discountType: $discountType, plageDiscount: $plageDiscount)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Delivery &&
        other.discountIsPrice == discountIsPrice &&
        other.value == value &&
        other.discountType == discountType &&
        listEquals(other.plageDiscount, plageDiscount);
  }

  @override
  int get hashCode =>
      discountIsPrice.hashCode ^
      value.hashCode ^
      discountType.hashCode ^
      plageDiscount.hashCode;
}

class AEmporter {
  final bool discountIsPrice;
  final String value;
  final List<PlageDiscount> plageDiscount;

  double get valueDouble => double.tryParse(value) ?? 0.0;
  final DiscountType discountType;

  AEmporter({
    this.discountIsPrice,
    this.value,
    this.discountType,
    this.plageDiscount,
  });

  AEmporter copyWith({
    bool discountIsPrice,
    String value,
    DiscountType discountType,
    List<PlageDiscount> plageDiscount,
  }) {
    return AEmporter(
      discountIsPrice: discountIsPrice ?? this.discountIsPrice,
      value: value ?? this.value,
      discountType: discountType ?? this.discountType,
      plageDiscount: plageDiscount ?? this.plageDiscount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'discountIsPrice': discountIsPrice,
      'value': value,
      'discountType': discountType == DiscountType.SurTotalite
          ? "SurTotalité"
          : describeEnum(discountType),
      'plageDiscount': plageDiscount?.map((x) => x.toMap())?.toList()
    };
  }

  factory AEmporter.fromMap(Map<String, dynamic> map) {
    return AEmporter(
        discountIsPrice: map['discountIsPrice'],
        value: map['value'],
        discountType: map['discountType'] == "SurTransport"
            ? DiscountType.SurTransport
            : map['discountType'] == "SurCommande"
                ? DiscountType.SurCommande
                : DiscountType.SurTotalite,
        plageDiscount: map['plageDiscount'] != null
            ? List<PlageDiscount>.from(
                map['plageDiscount']?.map((x) => PlageDiscount.fromMap(x)))
            : []);
  }

  String toJson() => json.encode(toMap());

  factory AEmporter.fromJson(String source) =>
      AEmporter.fromMap(json.decode(source));

  @override
  String toString() =>
      'AEmporter(discountIsPrice: $discountIsPrice, value: $value, discountType: $discountType, plageDiscount: $plageDiscount)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AEmporter &&
        other.discountIsPrice == discountIsPrice &&
        other.value == value &&
        other.discountType == discountType &&
        listEquals(other.plageDiscount, plageDiscount);
  }

  @override
  int get hashCode =>
      discountIsPrice.hashCode ^
      value.hashCode ^
      discountType.hashCode ^
      plageDiscount.hashCode;
}
