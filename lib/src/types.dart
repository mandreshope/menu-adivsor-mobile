import 'package:flutter/material.dart';

class Location {
  final String type;
  final List<double> coordinates;

  const Location({
    this.type,
    this.coordinates,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        type: json['type'],
        coordinates: [json['coordinates'][0], json['coordinates'][1]],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "coordinates": coordinates.toString(),
      };

  @override
  String toString() {
    return '{"type": "$type", "coordinates": ${coordinates.toString()}}';
  }
}

class Price {
  final int amount;
  final String currency;

  const Price({
    @required this.amount,
    @required this.currency,
  });

  factory Price.fromJson(Map<String, dynamic> json) => Price(
        amount: json['amount'],
        currency: json['currency'],
      );
}

class UserName {
  final String first;
  final String last;

  const UserName({
    this.first,
    this.last,
  });

  factory UserName.fromJson(Map<String, dynamic> json) => UserName(
        first: json['first'],
        last: json['last'],
      );

  Map<String, dynamic> toJson() => {
        'first': first,
        'last': last,
      };
}

class PaymentCard {
  final int cardNumber;
  final DateTime expirationDate;
  final int securityCode;
  final String owner;
  final String zipCode;

  PaymentCard({
    @required this.cardNumber,
    @required this.expirationDate,
    @required this.securityCode,
    @required this.owner,
    @required this.zipCode,
  });

  factory PaymentCard.fromJson(Map<String, dynamic> data) => PaymentCard(
        cardNumber: data['cardNumber'],
        expirationDate:
            DateTime.fromMillisecondsSinceEpoch(data['expirationDate']),
        securityCode: data['securityCode'],
        owner: data['owner'],
        zipCode: data['zipCode'],
      );

  Map<String, dynamic> toJson() => {
        'cardNumber': cardNumber,
        'expirationDate': expirationDate.millisecondsSinceEpoch,
        'securityCode': securityCode,
        'owner': owner,
        'zipCode': zipCode,
      };
}

enum SearchResultType { food, menu, restaurant }

class SearchResult {
  final SearchResultType type;
  final Map<String, dynamic> content;

  SearchResult({@required this.type, @required this.content});

  factory SearchResult.fromJson(Map<String, dynamic> json) => SearchResult(
        type: SearchResultType.values.firstWhere(
          (e) => e.toString() == 'SearchResultType.${json['type']}',
        ),
        content: json['content'],
      );
}
