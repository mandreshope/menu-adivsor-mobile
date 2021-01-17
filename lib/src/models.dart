import 'package:copyable/copyable.dart';
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

class Food implements Copyable<Food>{
  final String id;
  final String name;
  final FoodCategory category;
  final double ratings;
  final Price price;
  final String imageURL;
  final dynamic restaurant;
  final String description;
  final dynamic type;
  final List<FoodAttribute> attributes;
  List<Option> options;
  final bool status;
  final String title;
  final int maxOptions;

  String message;

  List<Option> optionSelected = List();

  List<FoodAttribute> foodAttributes = List();

  bool isMenu = false;
  bool isFoodForMenu = false;

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
    this.optionSelected,
    this.status,
    this.title,
    this.maxOptions,
    this.message = "",
    this.foodAttributes,
    this.isFoodForMenu = false,
    this.isMenu = false
  });

  factory Food.fromJson(Map<String, dynamic> json,{bool fromCommande = false}) => Food(
        id: json['_id'],
        name: json['name'] is Map<String, dynamic> ? json['name']["fr"] : json['name'],
        imageURL: json['imageURL'],
        category: json.containsKey('category') && json['category'] != null && json['category'] is Map<String, dynamic> ? FoodCategory.fromJson(json['category']) : null,
        restaurant: json['restaurant'],
        price: json.containsKey('price') ? Price.fromJson(json['price']) : null,
        type: json['type'] == null ? null : json['type'] is  Map<String, dynamic> ?  FoodType.fromJson(json['type']) : json['type'] as String,
        attributes: fromCommande ? List() : (json['attributes'] as List).map((e) => (e is String) ? FoodAttribute() : FoodAttribute.fromJson(e)).toList(),
        options: (json['options'] as List).map((e) => Option.fromJson(e)).toList(),
        status: json['status'],
        title: json['title'],
        maxOptions:json['maxOptions'],
      );

  Map<String, dynamic> toJson() {
    return this.isMenu ?
    {
        "food": id,
        if (optionSelected != null)
        "options": this.optionSelected.map((v) => v.toJson()).toList()
      }
      :
      {
        "id": id,
        "name": name,
        "category": category.toJson(),
        if (optionSelected != null)
        "options": this.optionSelected.map((v) => v.toJson()).toList()
      };
  }

  @override
  Food copy() {
    // TODO: implement copy
    return Food(
      id: this.id, 
      name: this.name, 
      category: this.category,
     restaurant: this.restaurant, 
     price: this.price,
     attributes: this.attributes,
     description: this.description,
     foodAttributes: this.foodAttributes,
     imageURL: this.imageURL,
     isFoodForMenu: this.isFoodForMenu,
     isMenu: this.isMenu, 
     maxOptions: this.maxOptions,
     message: this.message,
     optionSelected: this.optionSelected,
     options: this.options,
     ratings: this.ratings,
     status: this.status,
     title: this.title,
     type: this.type);
  }

  @override
  Food copyWith() {
    // TODO: implement copyWith
    throw UnimplementedError();
  }

  @override
  Food copyWithMaster(Food master) {
    // TODO: implement copyWithMaster
    throw UnimplementedError();
  }

}

class Menu implements Copyable<Menu>{
  final String id;
  final String imageURL;
  final dynamic name;
  final dynamic description;
  final List<Food> foods;
  String restaurant;
  Price price;
  String type;

  bool isMenu = true;
  bool isFoodForMenu = false;

  String message;
  List<Option> options = List();

  List<Option> optionSelected = List();

  Menu({
    @required this.id,
    @required this.name,
    this.foods,
    this.imageURL,
    this.description,
    this.restaurant,
    this.type,
    this.isFoodForMenu = false,
    this.isMenu = true,
    this.message,
    this.optionSelected,
    this.price
  });

  _setPrice() {
    price = Price(amount: 0,currency: "€");
    this.foods?.forEach((f){
          f.isFoodForMenu = true;
         if (f.price != null && f.price.amount != null) price.amount += f.price.amount;
        });
        print("prince ${price.amount}");
        
  }


  factory Menu. fromJson(Map<String, dynamic> json,{String resto,bool fromCommand = false}) {
    
    Menu _menu = Menu(
        id: json['_id'],
        name: json['name'] == null ? "" : json['name'] is Map<String, dynamic> ? json['name']["fr"] : json['name'],
        imageURL: json['imageURL'],
        foods: json['foods'] is List ? json['foods']?.map<Food>((data) => Food.fromJson(data,fromCommande: fromCommand))?.toList() ?? [] : [],
        description: json['description'] is Map<String, dynamic> ? json['description']["fr"] : json['description'],
        // restaurant: resto
        type: json['type'],
        optionSelected: json['options'] != null ? (json['options'] as List).map((e) => Option.fromJson(e)).toList() : [],
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

  @override
  Menu copy() {
    // TODO: implement copy
    return this;
  }

  @override
  Menu copyWith() {
    // TODO: implement copyWith
    throw UnimplementedError();
  }

  @override
  Menu copyWithMaster(Menu master) {
    // TODO: implement copyWithMaster
    throw UnimplementedError();
  }
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
  final bool status;
  final String admin;
  final bool delivery;
  final List<OpeningTimes> openingTimes;

  int priceDelevery;

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
    this.status,
    this.admin,
    this.priceDelevery,
    this.delivery,
    this.openingTimes
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
        phoneNumber: json['phoneNumber'] ?? [],
        status: json['status'],
        admin: json['admin'],
        priceDelevery:json['deliveryPrice']['amount'],
        delivery:json['delivery'] ?? true,
        openingTimes: (json['openingTimes'] != null) ? (json['openingTimes'] as List).map<OpeningTimes>((e) => OpeningTimes.fromJson(e)).toList() : List() 
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
  final dynamic relatedUser;
  final String commandType;
  final int totalPrice;
  final bool validated;
  final bool revoked;
  List<CommandItem> items;
  List<CommandItem> menus;
  final DateTime createdAt;
  final String shippingAddress;
  final DateTime shippingTime;
  final bool shipAsSoonAsPossible;
  final int code;
  dynamic restaurant;
  String comment;
  final bool priceless;

  Command({
    this.id,
    this.relatedUser,
    this.commandType,
    this.totalPrice,
    this.validated,
    this.revoked,
    this.items,
    this.menus,
    this.createdAt,
    this.shippingAddress,
    this.shippingTime,
    this.shipAsSoonAsPossible,
    this.code,
    this.restaurant,
    this.comment,
    this.priceless
  });

  factory Command.fromJson(Map<String, dynamic> json) => Command(
        id: json['_id'] ?? "",
        relatedUser: json['relatedUser'],
        commandType: json['commandType'],
        totalPrice: json['totalPrice'],
        validated: json['validated'],
        revoked: json['revoked'],
        items: json['items'] != null ? (json['items'] as List).map((e) => CommandItem.fromJson(e)).toList() : List(),
        menus: json['menus'] != null ? (json['menus'] as List).map((e) => CommandItem.fromJson(e,isMenu: true)).toList() : List(),
        createdAt: json['createdAt'] != null ? (json['createdAt'] is String) ? DateTime.parse(json['createdAt']) : DateTime.fromMillisecondsSinceEpoch(json['createdAt']) : null,
        shippingAddress: json['shippingAddress'],
        shippingTime: json['shippingTime'] != null ? ( json['shippingTime'] is String) ? DateTime.parse( json['shippingTime']) : DateTime.fromMillisecondsSinceEpoch(json['shippingTime']) : null,
        shipAsSoonAsPossible: json['shipAsSoonAsPossible'] ?? false,
        code: json['code'],
        comment: json['comment'] ?? " ",
        restaurant: json['restaurant'] is String ? json['restaurant'] : Restaurant.fromJson(json['restaurant']
        ),
        priceless: json['priceless'] ?? false
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
  int quantity = 0;
  dynamic food;
  Menu menu;
  List<Option> options;
  List<Food> foods;

  List<FoodSelectedFromCommandMenu> foodMenuSelected;

  CommandItem({this.sId, this.quantity, this.food,this.menu,this.options,this.foods});

  CommandItem.fromJson(Map<String, dynamic> json,{bool isMenu = false}) {
    sId = json['_id'];
    if (json['item'] is String)
      food = json['item'];
    if (isMenu){
 menu = json['item'] != null ? Menu.fromJson(json['item'],fromCommand: true) : null;
 /*if (json['foods'] != null)
          foods = json['foods'] is List ? json['foods']?.map<Food>((data)
            {
              Food food = menu.foods.firstWhere((f) => f.id == data["_id"],orElse: ()=>null);
              food.options = data['options'];
          //  Food.fromJson(data);
          return food;
           }
           )?.toList() ?? [] : [];
      */
      foodMenuSelected = json['foods'] is List ? json['foods']?.map<FoodSelectedFromCommandMenu>((data) => FoodSelectedFromCommandMenu.fromJson(data))?.toList() ?? [] : [];

    }else{

          food = json['item'] != null ? Food.fromJson(json['item'],fromCommande: true) : null;
        if (json['foods'] != null)
          foods = json['foods'] is List ? json['foods']?.map<Food>((data) => Food.fromJson(data,fromCommande: true))?.toList() ?? [] : [];
options = json['options'] == null ? List() : (json['options'] as List).map((e) => Option.fromJson(e)).toList();

    }
            quantity = json['quantity'] ?? 0;
        
    
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

class FoodSelectedFromCommandMenu {
String id;
List<Option> options;
Food food;

FoodSelectedFromCommandMenu({this.id,this.options,this.food});

factory FoodSelectedFromCommandMenu.fromJson(var json) => FoodSelectedFromCommandMenu(
 id: json['_id'],
 food: Food.fromJson(json['food']),
 options: json['options'] == null ? List() : (json['options'] as List).map((e) => Option.fromJson(e)).toList()
);

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
    String sId;
  String tag;
  String locales;
  String imageURL;
  int iV;

  bool isChecked = false;

  FoodAttribute({this.sId, this.tag, this.locales, this.imageURL, this.iV});

  FoodAttribute.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    tag = json['tag'];
    locales = json['locales']['fr'];
    imageURL = json['imageURL'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['tag'] = this.tag;
    data['locales'] = this.locales;
    data['imageURL'] = this.imageURL;
    data['__v'] = this.iV;
    return data;
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
class Option {
  String sId;
  List<ItemsOption> items;
  String title;
  int maxOptions;

  List<ItemsOption> itemOptionSelected;

  Option({this.sId, this.items, this.title, this.maxOptions,this.itemOptionSelected});

  factory Option.copy(Option o) => Option(
    itemOptionSelected: o.itemOptionSelected,
    items: o.items,
    maxOptions: o.maxOptions,
    sId: o.sId,
    title: o.title
  );

  Option.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    if (json['items'] != null) {
      items = new List<ItemsOption>();
      json['items'].forEach((v) {
        if (!(v is String))
        items.add(ItemsOption.fromJson(v));
      });
    }
    title = json['title'];
    maxOptions = json['maxOptions'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.itemOptionSelected != null) {
      data['items'] = this.itemOptionSelected.map((v) => v.toJson()).toList();
    }
    data['title'] = this.title;
    data['maxOptions'] = this.maxOptions;
    return data;
  }
}

class ItemsOption {
  String sId;
  String name;
  Price price;
  String imageUrl;
  int quantity = 0;
  ItemsOption item;

  ItemsOption({this.sId, this.name, this.price,this.imageUrl,this.quantity,this.item});

  ItemsOption.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'] ?? "";
    price = Price.fromJson(json);
    imageUrl = json['imageURL'];
    quantity = json['quantity'];
    if (json['item'] != null)
    item = ItemsOption.fromJson(json['item']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    // data['_id'] = this.sId;
    // data['name'] = this.name;
    // data['price'] = this.price.toJson();
    data['quantity'] = this.quantity;
   data['item'] =
   {
      "_id": this.sId,
      'name': this.name,
      'price': this.price.toJson(),
    };
    return data;
  }
}

class Message {
  String name;
  String phoneNumber;
  String email;
  String message;
  bool read;
  String target;

  Message(
      {
      @required this.name,
      @required this.phoneNumber,
      @required this.email,
      @required this.message,
      this.read,
      this.target});

  Message.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    phoneNumber = json['phoneNumber'];
    email = json['email'];
    message = json['message'];
    read = json['read'];
    target = json['target'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['phoneNumber'] = this.phoneNumber;
    data['email'] = this.email;
    data['message'] = this.message;
    data['read'] = this.read;
    data['target'] = this.target;
    return data;
  }
}

enum MenuType {
  per_food,
  priceless,
  fixed_price
}

class Blog {
  String sId;
  String title;
  String description;
  String url;
  String imageURL;
  String postedAt;
  String updatedAt;
  int iV;

  Blog(
      {this.sId,
        this.title,
        this.description,
        this.url,
        this.imageURL,
        this.postedAt,
        this.updatedAt,
        this.iV});

  Blog.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    description = json['description'];
    url = json['url'];
    imageURL = json['imageURL'];
    postedAt = json['postedAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['title'] = this.title;
    data['description'] = this.description;
    data['url'] = this.url;
    data['imageURL'] = this.imageURL;
    data['postedAt'] = this.postedAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }


  
}

// schedule restaurant
class OpeningTimes {
  String sId;
  String day;
  List<Openings> openings;

  OpeningTimes({this.sId, this.day, this.openings});

  OpeningTimes.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    day = json['day'];
    if (json['openings'] != null) {
      openings = new List<Openings>();
      json['openings'].forEach((v) {
        openings.add(new Openings.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['day'] = this.day;
    if (this.openings != null) {
      data['openings'] = this.openings.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Openings {
  Begin begin;
  Begin end;
  String sId;

  Openings({this.begin, this.end, this.sId});

  Openings.fromJson(Map<String, dynamic> json) {
    begin = json['begin'] != null ? new Begin.fromJson(json['begin']) : null;
    end = json['end'] != null ? new Begin.fromJson(json['end']) : null;
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.begin != null) {
      data['begin'] = this.begin.toJson();
    }
    if (this.end != null) {
      data['end'] = this.end.toJson();
    }
    data['_id'] = this.sId;
    return data;
  }
}

class Begin {
  int hour;
  int minute;

  Begin({this.hour, this.minute});

  Begin.fromJson(Map<String, dynamic> json) {
    hour = json['hour'];
    minute = json['minute'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['hour'] = this.hour;
    data['minute'] = this.minute;
    return data;
  }
}
// end schedule 