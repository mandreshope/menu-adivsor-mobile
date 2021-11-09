/// _id : "6187967e87c9cf435dd9e6ed"
/// code : "PROMO"
/// date : "2021-11-08T09:03:00.000Z"
/// nbr : 3
/// value : 10
/// discountIsPrice : false
class CodeDiscount {
  CodeDiscount({
    this.id,
    this.code,
    this.date,
    this.nbr,
    this.value,
    this.discountIsPrice,
  });

  String id;
  String code;
  String date;
  int nbr;
  int value;
  bool discountIsPrice;

  CodeDiscount.fromJson(dynamic json) {
    id = json['_id'];
    code = json['code'];
    date = json['date'];
    nbr = json['nbr'];
    value = json['value'];
    discountIsPrice = json['discountIsPrice'];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeDiscount &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          code == other.code &&
          date == other.date &&
          nbr == other.nbr &&
          value == other.value &&
          discountIsPrice == other.discountIsPrice;

  @override
  int get hashCode =>
      id.hashCode ^
      code.hashCode ^
      date.hashCode ^
      nbr.hashCode ^
      value.hashCode ^
      discountIsPrice.hashCode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    map['code'] = code;
    map['date'] = date;
    map['nbr'] = nbr;
    map['value'] = value;
    map['discountIsPrice'] = discountIsPrice;
    return map;
  }

  @override
  String toString() {
    return 'CodeDiscount{id: $id, code: $code, date: $date, nbr: $nbr, value: $value, discountIsPrice: $discountIsPrice}';
  }

  CodeDiscount copyWith({
    String id,
    String code,
    String date,
    int nbr,
    int value,
    bool discountIsPrice,
  }) {
    return CodeDiscount(
      id: id ?? this.id,
      code: code ?? this.code,
      date: date ?? this.date,
      nbr: nbr ?? this.nbr,
      value: value ?? this.value,
      discountIsPrice: discountIsPrice ?? this.discountIsPrice,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'code': this.code,
      'date': this.date,
      'nbr': this.nbr,
      'value': this.value,
      'discountIsPrice': this.discountIsPrice,
    };
  }

  Map<String, dynamic> toAddCodePromo(String restaurantId) {
    return {
      'max': this.nbr,
      'dateFin': this..date,
      'id_restaurant': restaurantId,
      'code': this.code,
    };
  }

  factory CodeDiscount.fromMap(Map<String, dynamic> map) {
    return CodeDiscount(
      id: map['id'] as String,
      code: map['code'] as String,
      date: map['date'] as String,
      nbr: map['nbr'] as int,
      value: map['value'] as int,
      discountIsPrice: map['discountIsPrice'],
    );
  }
}
