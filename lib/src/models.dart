import 'package:flutter/material.dart';
import 'package:menu_advisor/src/types.dart';

class FoodCategory {
  final String id;
  final String name;
  final String imageURL;

  const FoodCategory({
    @required this.id,
    @required this.name,
    @required this.imageURL,
  });

  factory FoodCategory.fromJson(Map<String, dynamic> json) => FoodCategory(
        id: json['_id'],
        name: json['name'],
        imageURL: json['imageURL'],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
      };
}

class Food {
  final String id;
  final String name;
  final FoodCategory category;
  final double ratings;
  final Price price;
  final String imageURL;
  final Restaurant restaurant;
  final String description;

  Food({
    @required this.id,
    @required this.name,
    @required this.category,
    @required this.restaurant,
    @required this.price,
    this.ratings = 0,
    this.imageURL,
    this.description,
  });

  factory Food.fromJson(Map<String, dynamic> json) => Food(
        id: json['_id'],
        name: json['name'],
        imageURL: json['imageURL'],
        category: json.containsKey('category') &&
                json['category'] != null &&
                json['category'] is Map<String, dynamic>
            ? FoodCategory.fromJson(json['category'])
            : null,
        restaurant: json.containsKey('restaurant') && json['restaurant'] != null
            ? Restaurant.fromJson(json['restaurant'])
            : null,
        price: Price.fromJson(json['price']),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "category": category.toJson(),
      };
}

class Menu {
  final String imageURL;
  final String name;
  final List<String> allergens;
  final List<Food> foods;

  Menu({
    @required this.name,
    this.foods,
    this.imageURL,
    this.allergens = const [],
  });

  factory Menu.fromJson(Map<String, dynamic> json) => Menu(
        name: json['name'],
        imageURL: json['imageURL'],
        allergens: json['allergens'] ?? [],
        foods: json['foods'] is List<Map<String, dynamic>>
            ? json['foods']?.map((data) => Food.fromJson(data))?.toList() ?? []
            : [],
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
  final List<Food> foods;

  Restaurant({
    @required this.id,
    @required this.name,
    this.type = 'common_restaurant',
    this.imageURL,
    @required this.location,
    this.description = '',
    this.menus = const [],
    this.foods = const [],
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        id: json['_id'],
        name: json['name'],
        type: json['type'],
        imageURL: json['imageURL'],
        location: Location.fromJson(
          json['location'],
        ),
        description: json['description'] ?? '',
        menus: (json['menus'] is List<Map<String, dynamic>>)
            ? json['menus'].map((e) => Menu.fromJson(e))
            : [],
        foods: (json['foods'] is List<Map<String, dynamic>>)
            ? json['foods'].map((e) => Food.fromJson(e))
            : [],
      );
}

class User {
  final UserName name;
  final String id;
  final String phoneNumber;
  final String photoURL;
  final String address;
  final String email;
  final List<Restaurant> favoriteRestaurants;
  final List<Food> favoriteFoods;
  final List<PaymentCard> paymentCards;

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
      paymentCards: json['paymentCards'] is List<Map<String, dynamic>>
          ? json['paymentCards']
                  ?.map(
                    (data) => PaymentCard.fromJson(data),
                  )
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
    this.favoriteRestaurants = const [],
    this.favoriteFoods = const [],
    this.paymentCards = const [],
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
