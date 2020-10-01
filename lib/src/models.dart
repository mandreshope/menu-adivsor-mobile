import 'package:flutter/material.dart';
import 'package:menu_advisor/src/types.dart';

class FoodCategory {
  final String name;

  const FoodCategory({
    @required this.name,
  });

  factory FoodCategory.fromJson(Map<String, dynamic> json) => FoodCategory(
        name: json['name'],
      );
}

class Food {
  final String id;
  final String name;
  final FoodCategory category;
  final double ratings;
  final double price;
  final String imageURL;
  final Restaurant restaurant;
  final String description;
  final List<PaymentCard> paymentCards;

  Food({
    @required this.id,
    @required this.name,
    @required this.category,
    @required this.restaurant,
    @required this.price,
    this.ratings = 0,
    this.imageURL,
    this.description,
    this.paymentCards,
  });

  factory Food.fromJson(Map<String, dynamic> json) => Food(
        id: json['_id'],
        name: json['name'],
        category: json.containsKey('category') && json['category'] != null
            ? FoodCategory.fromJson(json['category'])
            : null,
        restaurant: json.containsKey('restaurant') && json['restaurant'] != null
            ? Restaurant.fromJson(json['restaurant'])
            : null,
        price: json['price'] / 100,
      );
}

class Restaurant {
  final String id;
  final String name;
  final String imageURL;
  final String type;
  final Location location;
  final String description;
  final List<Menu> menus;

  Restaurant({
    @required this.id,
    @required this.name,
    this.type = 'common_restaurant',
    this.imageURL,
    @required this.location,
    this.description = '',
    this.menus = const [],
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        id: json['_id'],
        name: json['name'],
        type: json['type'],
        imageURL: json['imageURL'],
        location: Location(
          type: 'point',
          coordinates: json['location'] ?? [0, 0],
        ),
        description: json['description'] ?? '',
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
  final List<Restaurant> favoriteRestaurants;
  final List<Food> favoriteFoods;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      email: json['email'],
      photoURL: json['photoURL'],
      name: UserName.fromJson(json['name']),
      favoriteRestaurants:
          json['favoriteRestaurants'] is List<Map<String, dynamic>>
              ? json['favoriteRestaurants']
                      ?.map((data) => Restaurant.fromJson(data))
                      ?.toList() ??
                  []
              : [],
      favoriteFoods: json['favoriteFoods'] is List<Map<String, dynamic>>
          ? json['favoriteFoods']
                  ?.map((data) => Food.fromJson(data))
                  ?.toList() ??
              []
          : [],
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
    this.favoriteRestaurants,
    this.favoriteFoods,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'phoneNumber': phoneNumber,
        'photoURL': photoURL,
        'address': address,
        'name': name.toJson()
      };
}
