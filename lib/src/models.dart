import 'package:flutter/material.dart';
import 'package:menu_advisor/src/types.dart';

class FoodCategory {
  final String id;
  final dynamic name;
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
  final dynamic restaurant;
  final String description;
  final dynamic type;
  final List<String> attributes;
  final dynamic options;

  dynamic optionsSelected;

  List<FoodAttribute> foodAttributes = List();

  bool isMenu = false;

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
    this.options,
    this.optionsSelected
  });

  factory Food.fromJson(Map<String, dynamic> json) => Food(
        id: json['_id'],
        name: json['name'] is Map<String, dynamic> ? json['name']["fr"] : json['name'],
        imageURL: json['imageURL'],
        category: json.containsKey('category') && json['category'] != null && json['category'] is Map<String, dynamic> ? FoodCategory.fromJson(json['category']) : null,
        restaurant: json['restaurant'],
        price: json.containsKey('price') ? Price.fromJson(json['price']) : null,
        type: json['type'] == null ? null : json['type'] is  Map<String, dynamic> ?  FoodType.fromJson(json['type']) : json['type'] as String,
        attributes: (json['attributes'] as List).map((e) => e.toString()).toList(),
        options: json['options']
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "category": category.toJson(),
        "options": optionsSelected
      };
}

class Menu {
  final String id;
  final String imageURL;
  final dynamic name;
  final dynamic description;
  final List<Food> foods;
  String restaurant;
  Price price;

  bool isMenu = true;

  Menu({
    @required this.id,
    @required this.name,
    this.foods,
    this.imageURL,
    this.description,
    this.restaurant,
    
  });

  _setPrice() {
    price = Price(amount: 0,currency: "€");
    this.foods.forEach((f){
         if (f.price != null && f.price.amount != null) price.amount += f.price.amount;
        });
        print("prince ${price.amount}");
        
  }

  factory Menu.fromJson(Map<String, dynamic> json,{String resto}) {
    
    Menu _menu = Menu(
        id: json['_id'],
        name: json['name'] is Map<String, dynamic> ? json['name']["fr"] : json['name'],
        imageURL: json['imageURL'],
        foods: json['foods'] is List ? json['foods']?.map<Food>((data) => Food.fromJson(data))?.toList() ?? [] : [],
        description: json['description'] is Map<String, dynamic> ? json['description']["fr"] : json['description'],
        // restaurant: resto
      );
      _menu.isMenu = true;
      _menu._setPrice();
      return _menu;
    }

      toJson() => {
        "_id":this.id,
        "name":this.name,
        "imageURL":this.imageURL,
        "foods":this.foods.map((v) => v.toJson()).toList(),
        "description":this.description
      };
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
  final String phoneNumber;

  Restaurant({
    this.phoneNumber,
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
        phoneNumber: json['phoneNumber']
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
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'phoneNumber': phoneNumber,
        'photoURL': photoURL,
        'address': address,
        'name': name.toJson(),
      };

  @override
  String toString() {
    // TODO: implement toString
    return "${this.name.first} ${this.name.last}";
    
  }

}

class Command {
  final String id;
  final String relatedUser;
  final String commandType;
  final int totalPrice;
  final bool validated;
  final List<dynamic> items;
  final DateTime createdAt;
  final String shippingAddress;
  final DateTime shippingTime;
  final bool shipAsSoonAsPossible;
  final int code;

  Command({
    this.id,
    this.relatedUser,
    this.commandType,
    this.totalPrice,
    this.validated,
    this.items,
    this.createdAt,
    this.shippingAddress,
    this.shippingTime,
    this.shipAsSoonAsPossible,
    this.code,
  });

  factory Command.fromJson(Map<String, dynamic> json) => Command(
        id: json['_id'] ?? "",
        relatedUser: json['relatedUser'],
        commandType: json['commandType'],
        totalPrice: json['totalPrice'],
        validated: json['validated'],
        items: json['items'],
        createdAt: json['createdAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['createdAt']) : null,
        shippingAddress: json['shippingAddress'],
        shippingTime: json['shippingTime'] != null ? DateTime.fromMillisecondsSinceEpoch(json['shippingTime']) : null,
        shipAsSoonAsPossible: json['shipAsSoonAsPossible'] ?? false,
        code: json['code'],
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

//command model
class CommandModel {
  List<CommandItem> items;
  List<CommandItem> menus;
  Restaurant restaurant;
  int totalPrice;
  String commandType;
  int code;
  DateTime shippingTime;

  CommandModel({this.items,this.commandType,this.code});

  CommandModel.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = List<CommandItem>();
      json['items'].forEach((v) {
        items.add(CommandItem.fromJson(v));
      });
    }
    if (json['menus'] != null) {
      menus = List<CommandItem>();
      json['menus'].forEach((v) {
        menus.add(CommandItem.fromJson(v));
      });
    }
    totalPrice = json['totalPrice'];
    commandType = json['commandType'];
    code = json['code'];
    restaurant = json['restaurant'] != null ? Restaurant.fromJson(json['restaurant']) : null;
    shippingTime = json['shippingTime'] != null ? DateTime.fromMillisecondsSinceEpoch(json['shippingTime']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.items != null) {
      data['items'] = this.items.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CommandItem {
  String sId;
  int quantity;
  Food food;
  Menu menu;

  CommandItem({this.sId, this.quantity, this.food,this.menu});

  CommandItem.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    if (json['item']['foods'] == null)
      food = json['item'] != null ? Food.fromJson(json['item']) : null;
    else
      menu = json['item'] != null ? Menu.fromJson(json['item']) : null;
    quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = this.sId;
    data['quantity'] = this.quantity;
    if (this.food != null) {
      data['item'] = this.food.toJson();
    }
    return data;
  }
}

class FoodType {
  String id;
  dynamic tag;
  dynamic name;

  FoodType({this.tag,this.name,this.id});

  FoodType.fromJson(Map<String, dynamic> json) {
    tag = json['tag'];
    name = json['name'];
    id = json["_id"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tag'] = this.tag;
    data['name'] = this.name;
    data["_id"] = this.id;
    return data;
  }

}

class FoodAttribute {
  dynamic tag;
  dynamic locales;
  dynamic imageUrl;

    FoodAttribute({this.imageUrl,this.locales,this.tag});

    FoodAttribute.fromJson(Map<String, dynamic> json) {
       tag = json['tag'];
       locales = json['locales'];
       imageUrl = json['imageURL'];
    }

}

//placemark
class Placemark {
  String type;
  String licence;
  List<Features> features;

  Placemark({this.type, this.licence, this.features});

  Placemark.fromJson(var json) {
    type = json['type'];
    licence = json['licence'];
    if (json['features'] != null) {
      features = new List<Features>();
      json['features'].forEach((v) {
        features.add(new Features.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['licence'] = this.licence;
    if (this.features != null) {
      data['features'] = this.features.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Features {
  String type;
  Properties properties;
  List<double> bbox;
  Geometry geometry;

  Features({this.type, this.properties, this.bbox, this.geometry});

  Features.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    properties = json['properties'] != null
        ? new Properties.fromJson(json['properties'])
        : null;
    bbox = json['bbox'].cast<double>();
    geometry = json['geometry'] != null
        ? new Geometry.fromJson(json['geometry'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    if (this.properties != null) {
      data['properties'] = this.properties.toJson();
    }
    data['bbox'] = this.bbox;
    if (this.geometry != null) {
      data['geometry'] = this.geometry.toJson();
    }
    return data;
  }
}

class Properties {
  int placeId;
  String osmType;
  int osmId;
  int placeRank;
  String category;
  String type;
  dynamic importance;
  String addresstype;
  dynamic name;
  String displayName;
  Address address;

  Properties(
      {this.placeId,
        this.osmType,
        this.osmId,
        this.placeRank,
        this.category,
        this.type,
        this.importance,
        this.addresstype,
        this.name,
        this.displayName,
        this.address});

  Properties.fromJson(Map<String, dynamic> json) {
    placeId = json['place_id'];
    osmType = json['osm_type'];
    osmId = json['osm_id'];
    placeRank = json['place_rank'];
    category = json['category'];
    type = json['type'];
    importance = json['importance'];
    addresstype = json['addresstype'];
    name = json['name'];
    displayName = json['display_name'];
    address =
    json['address'] != null ? new Address.fromJson(json['address']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['place_id'] = this.placeId;
    data['osm_type'] = this.osmType;
    data['osm_id'] = this.osmId;
    data['place_rank'] = this.placeRank;
    data['category'] = this.category;
    data['type'] = this.type;
    data['importance'] = this.importance;
    data['addresstype'] = this.addresstype;
    data['name'] = this.name;
    data['display_name'] = this.displayName;
    if (this.address != null) {
      data['address'] = this.address.toJson();
    }
    return data;
  }
}

class Address {
  String houseNumber;
  String road;
  String neighbourhood;
  String suburb;
  String cityDistrict;
  String city;
  String municipality;
  String county;
  String state;
  String country;
  String postcode;
  String countryCode;

  Address(
      {this.houseNumber,
        this.road,
        this.neighbourhood,
        this.suburb,
        this.cityDistrict,
        this.city,
        this.municipality,
        this.county,
        this.state,
        this.country,
        this.postcode,
        this.countryCode});

  Address.fromJson(Map<String, dynamic> json) {
    houseNumber = json['house_number'];
    road = json['road'];
    neighbourhood = json['neighbourhood'];
    suburb = json['suburb'];
    cityDistrict = json['city_district'];
    city = json['city'];
    municipality = json['municipality'];
    county = json['county'];
    state = json['state'];
    country = json['country'];
    postcode = json['postcode'];
    countryCode = json['country_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['house_number'] = this.houseNumber;
    data['road'] = this.road;
    data['neighbourhood'] = this.neighbourhood;
    data['suburb'] = this.suburb;
    data['city_district'] = this.cityDistrict;
    data['city'] = this.city;
    data['municipality'] = this.municipality;
    data['county'] = this.county;
    data['state'] = this.state;
    data['country'] = this.country;
    data['postcode'] = this.postcode;
    data['country_code'] = this.countryCode;
    return data;
  }
}

class Geometry {
  String type;
  List<double> coordinates;

  Geometry({this.type, this.coordinates});

  Geometry.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    coordinates = json['coordinates'].cast<double>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['coordinates'] = this.coordinates;
    return data;
  }
}

class Language {
  String code;
  String name;
  String nativeName;

  Language({this.code, this.name, this.nativeName});

  Language.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'];
    nativeName = json['nativeName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['name'] = this.name;
    data['nativeName'] = this.nativeName;
    return data;
  }
}
