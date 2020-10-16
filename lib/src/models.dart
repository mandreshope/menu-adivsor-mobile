import 'package:flutter/material.dart';
import 'package:menu_advisor/src/types.dart';

class FoodCategory {
  final String id;
  final Map<String, dynamic> name;
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
        "imageURL": imageURL,
      };
}

class Food {
  final String id;
  final String name;
  final FoodCategory category;
  final double ratings;
  final Price price;
  final String imageURL;
  final String restaurant;
  final String description;
  final String type;
  final List<String> attributes;

  Food({
    @required this.id,
    @required this.name,
    @required this.category,
    @required this.restaurant,
    @required this.price,
    this.ratings = 0,
    this.imageURL,
    this.description,
    this.type,
    this.attributes,
  });

  factory Food.fromJson(Map<String, dynamic> json) => Food(
        id: json['_id'],
        name: json['name'],
        imageURL: json['imageURL'],
        category: json.containsKey('category') && json['category'] != null && json['category'] is Map<String, dynamic> ? FoodCategory.fromJson(json['category']) : null,
        restaurant: json['restaurant'],
        price: Price.fromJson(json['price']),
        type: json['type'],
        attributes: (json['attributes'] as List).map((e) => e.toString()).toList(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "category": category.toJson(),
      };
}

class Menu {
  final String imageURL;
  final Map<String, dynamic> name;
  final Map<String, dynamic> description;
  final List<Food> foods;

  Menu({
    @required this.name,
    this.foods,
    this.imageURL,
    this.description,
  });

  factory Menu.fromJson(Map<String, dynamic> json) => Menu(
        name: json['name'],
        imageURL: json['imageURL'],
        foods: json['foods'] is List ? json['foods']?.map<Food>((data) => Food.fromJson(data))?.toList() ?? [] : [],
        description: json['description'],
      );
}

class Restaurant {
  final String id;
  final String name;
  final String imageURL;
  final String type;
  final Location location;
  final String address;
  final String description;
  final List<String> menus;
  final List<String> foods;
  final List<dynamic> foodTypes;

  Restaurant({
    @required this.id,
    @required this.name,
    this.type = 'common_restaurant',
    this.imageURL,
    @required this.location,
    this.address = '',
    this.description = '',
    this.menus = const [],
    this.foods = const [],
    this.foodTypes = const [],
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        id: json['_id'],
        name: json['name'],
        type: json['type'],
        imageURL: json['imageURL'],
        location: Location.fromJson(
          json['location'],
        ),
        address: json['address'] ?? '',
        description: json['description'] ?? '',
        menus: (json['menus'] as List).map<String>((e) => e).toList(),
        foods: (json['foods'] as List).map<String>((e) => e).toList(),
        foodTypes: json['foodTypes'] ?? [],
      );
}

class User {
  final UserName name;
  final String id;
  final String phoneNumber;
  final String photoURL;
  final String address;
  final String email;
  final List<String> favoriteRestaurants;
  final List<String> favoriteFoods;
  final List<PaymentCard> paymentCards;
  final List<Command> commands;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['_id'],
        email: json['email'],
        photoURL: json['photoURL'],
        name: UserName.fromJson(json['name']),
        favoriteRestaurants: (json['favoriteRestaurants'] as List).map<String>((e) => e).toList(),
        favoriteFoods: (json['favoriteFoods'] as List).map<String>((e) => e).toList(),
        paymentCards: json['paymentCards'] is List
            ? json['paymentCards']
                    ?.map<PaymentCard>(
                      (data) => PaymentCard.fromJson(data),
                    )
                    ?.toList() ??
                []
            : [],
        address: json['address'],
        commands: (json['commands'] as List).map<Command>((e) => Command.fromJson(e)).toList(),
      );

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
    this.commands,
  });

  Map<String, dynamic> toJson() => {'id': id, 'email': email, 'phoneNumber': phoneNumber, 'photoURL': photoURL, 'address': address, 'name': name.toJson()};
}

class Command {
  final String relatedUser;
  final String commandType;
  final int totalPrice;
  final bool validated;
  final List<Food> items;
  final DateTime createdAt;

  Command({
    this.relatedUser,
    this.commandType,
    this.totalPrice,
    this.validated,
    this.items,
    this.createdAt,
  });

  factory Command.fromJson(Map<String, dynamic> json) => Command(
        relatedUser: json['relatedUser'],
        commandType: json['commandType'],
        totalPrice: json['totalPrice'],
        validated: json['validated'],
        items: (json['items'] as List).map<Food>((e) => Food.fromJson(e)).toList(),
        createdAt: json['createdAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['createdAt']) : null,
      );
}

class PaymentCard {
  final String id;
  final String cardNumber;
  final String expiryMonth;
  final String expiryYear;
  final String securityCode;
  final String owner;
  final String zipCode;

  PaymentCard({
    this.id,
    @required this.cardNumber,
    @required this.expiryMonth,
    @required this.expiryYear,
    @required this.securityCode,
    @required this.owner,
    @required this.zipCode,
  });

  factory PaymentCard.fromJson(Map<String, dynamic> data) => PaymentCard(
        id: data['_id'],
        cardNumber: data['cardNumber'],
        expiryMonth: data['expiryMonth'].toString(),
        expiryYear: data['expiryYear'].toString(),
        securityCode: data['securityCode'].toString(),
        owner: data['owner'],
        zipCode: data['zipCode'],
      );

  Map<String, dynamic> toJson() => {
        'cardNumber': cardNumber,
        'expiryMonth': expiryMonth,
        'expiryYear': expiryYear,
        'securityCode': securityCode,
        'owner': owner,
        'zipCode': zipCode,
      };
}
