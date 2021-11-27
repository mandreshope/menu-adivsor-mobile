import 'dart:convert';

class PlageDiscount {
  final String id;
  final String min;
  final String value;
  final String max;
  PlageDiscount({
    this.id,
    this.min,
    this.value,
    this.max,
  });

  PlageDiscount copyWith({
    String id,
    String min,
    String value,
    String max,
  }) {
    return PlageDiscount(
      id: id ?? this.id,
      min: min ?? this.min,
      value: value ?? this.value,
      max: max ?? this.max,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'min': min,
      'value': value,
      'max': max,
    };
  }

  factory PlageDiscount.fromMap(Map<String, dynamic> map) {
    return PlageDiscount(
      id: map['id'],
      min: map['min'],
      value: map['value'],
      max: map['max'],
    );
  }

  String toJson() => json.encode(toMap());

  factory PlageDiscount.fromJson(String source) =>
      PlageDiscount.fromMap(json.decode(source));

  @override
  String toString() {
    return 'RestaurantPlageDiscount(id: $id, min: $min, value: $value, max: $max)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PlageDiscount &&
        other.id == id &&
        other.min == min &&
        other.value == value &&
        other.max == max;
  }

  @override
  int get hashCode {
    return id.hashCode ^ min.hashCode ^ value.hashCode ^ max.hashCode;
  }
}
