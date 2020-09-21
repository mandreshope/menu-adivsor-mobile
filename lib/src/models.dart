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

class UserName {
  final String first;
  final String last;

  const UserName({this.first, this.last});

  factory UserName.fromJson(Map<String, String> json) =>
      UserName(first: json['first'], last: json['last']);
}

class UserLocation {
  final String type;
  final List<double> coordinates;

  const UserLocation({
    this.type,
    this.coordinates,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) =>
      UserLocation(type: json['type'], coordinates: json['coordinates']);
}

class User {
  final UserName name;
  final String id;
  final String phoneNumber;
  final String photoURL;
  final String address;
  final String email;
  final UserLocation location;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      photoURL: json['photoURL'],
      name: UserName.fromJson(json['name']),
      location: UserLocation.fromJson(json['location']),
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
