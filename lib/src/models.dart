import 'package:flutter/material.dart';
import 'package:menu_advisor/src/types.dart';

class Food {
  final String id;
  final String name;
  final String type;
  final double ratings;
  final double price;
  final String imageURL;
  final Restaurant restaurant;
  final String description;

  Food({
    @required this.id,
    @required this.name,
    @required this.type,
    @required this.restaurant,
    @required this.price,
    this.ratings = 0,
    this.imageURL,
    this.description,
  });

  factory Food.fromJson(Map<String, dynamic> json) => Food(
        id: json['id'],
        name: json['name'],
        type: json['type'],
        restaurant: Restaurant.fromJson(json['restaurant']),
        price: json['price'],
      );
}

class Restaurant {
  final String id;
  final String name;
  final String imageURL;
  final String type;
  final Location location;

  Restaurant({
    @required this.id,
    @required this.name,
    this.type = 'common_restaurant',
    this.imageURL,
    @required this.location,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        id: json['id'],
        name: json['name'],
        type: json['type'],
        location: Location(
          type: 'point',
          coordinates: json['location'] ?? [0, 0],
        ),
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
}

class User {
  final UserName name;
  final String id;
  final String phoneNumber;
  final String photoURL;
  final String address;
  final String email;
  final Location location;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      photoURL: json['photoURL'],
      name: UserName.fromJson(json['name']),
    );
  }

  User({
    this.id,
    this.email,
    this.name,
    this.phoneNumber,
    this.photoURL,
    this.address,
    this.location,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'phoneNumber': phoneNumber,
      };
}
