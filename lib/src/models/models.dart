import 'package:flutter/material.dart';
import 'package:menu_advisor/src/constants/constant.dart';
import 'package:menu_advisor/src/models/restaurants/restaurant_discount_model.dart';
import 'package:menu_advisor/src/models/restaurants/restaurant_livraison_model.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/types/types.dart';
import 'package:menu_advisor/src/utils/extensions.dart';

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

  @override
  String toString() {
    return this.id;
  }
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
  final List<FoodAttribute> attributes;
  List<Option> options = [];
  final bool status;
  final bool statut;
  final String title;
  final int maxOptions;
  final bool imageNotContractual;
  final bool isAvailable;
  final int priority;

  String message;

  int quantity = 0;

  List<Option> optionSelected = [];

  //allergen
  List<FoodAttribute> allergens = [];

  bool isMenu = false;
  bool isFoodForMenu = false;
  String idMenu = "";
  bool isPopular = false;

  String idNewFood = "";

  Price additionalPrice;

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
    this.allergens,
    this.isFoodForMenu = false,
    this.isMenu = false,
    this.idMenu,
    this.statut,
    this.isPopular = false,
    this.imageNotContractual,
    this.isAvailable,
    this.priority,
  });

  factory Food.fromJson(Map<String, dynamic> json, {bool fromCommande = false, bool isPopular = false}) => Food(
        id: json['_id'],
        name: json['name'] is Map<String, dynamic> ? json['name']["fr"] : json['name'],
        imageURL: (json['imageURL'] as String)?.contains("localhost:8080") == null ? "" : json['imageURL'],
        category: json.containsKey('category') && json['category'] != null && json['category'] is Map<String, dynamic> ? FoodCategory.fromJson(json['category']) : null,
        restaurant: json['restaurant_object'] != null ? json['restaurant_object'] : json['restaurant'],
        price: json.containsKey('price') ? Price.fromJson(json['price']) : null,
        type: json['type'] == null
            ? null
            : json['type'] is Map<String, dynamic>
                ? FoodType.fromJson(json['type'])
                : json['type'] as String,
        attributes: fromCommande ? [] : (json['attributes'] as List).map((e) => (e is String) ? FoodAttribute() : FoodAttribute.fromJson(e)).toList(),
        allergens: fromCommande ? [] : (json['allergene'] as List).map((e) => (e is String) ? FoodAttribute() : FoodAttribute.fromJson(e)).toList(),
        options: (json['options'] as List).map((e) => Option.fromJson(e)).where((element) => element.maxOptions >= 0).toList(),
        status: json['status'] ?? true,
        title: json['title'],
        maxOptions: json['maxOptions'],
        description: json['description'],
        statut: json['statut'] ?? true,
        isPopular: isPopular,
        imageNotContractual: json['imageNotContractual'],
        isAvailable: json['isAvailable'],
        priority: json['priority'],
      );

  factory Food.copy(Food food) => Food(
        id: food.id,
        options: food.options.map((e) => Option.copy(e)).toList(),
        price: food.price,
        restaurant: food.restaurant,
        name: food.name,
        imageURL: food.imageURL,
        category: food.category,
        attributes: food.attributes,
        isFoodForMenu: food.isFoodForMenu,
        isMenu: food.isMenu,
        title: food.title,
        type: food.type,
        description: food.description,
        allergens: food.allergens,
        maxOptions: food.maxOptions,
        message: food.message,
        // optionSelected: food.optionSelected,
        ratings: food.ratings,
        status: food.status,
        idMenu: food.idMenu,
        statut: food.statut,
        imageNotContractual: food.imageNotContractual,
        isAvailable: food.isAvailable,
        priority: food.priority,
      );

  Map<String, dynamic> toJson() {
    return this.isMenu
        ? {"food": id, if (optionSelected != null) "options": this.optionSelected.map((v) => v.toJson()).toList()}
        : {"id": id, "name": name, "category": category.toJson(), if (optionSelected != null) "options": this.optionSelected.map((v) => v.toJson()).toList()};
  }

  void copyOptions(List<Option> options) {
    this.options = options.map((o) => Option.copy(o)).toList();
  }

  int get totalPrice {
    int price = (this.price.amount ?? 0);
    if (price == 0) return 0;
    if (this.optionSelected == null) {
      return price * quantity;
    }
    this.optionSelected.forEach((element) {
      element.itemOptionSelected.forEach((e) {
        price += (e.price.amount ?? 0) * e.quantity;
      });
    });

    return price * quantity;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Food && other.id == id && other.name == name && other.title == title && other.restaurant == restaurant;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ restaurant.hashCode ^ title.hashCode;
  }
}

class Menu {
  final String id;
  final String imageURL;
  final dynamic name;
  final dynamic description;
  final List<MenuFood> foods;
  bool status;
  bool statut;
  List<Food> foodSelected = [];
  dynamic restaurant;
  Price price;
  String type;
  int priority;

  bool isMenu = true;
  bool isFoodForMenu = false;

  int quantity = 1;

  String message;
  List<Option> options = [];

  List<Option> optionSelected = [];

  String idNewFood = "";

  Map<String, Food> _foodMenuSelected = Map();
  Map<String, List<Food>> selectedMenu = Map();
  int count = 1;

  Menu(
      {@required this.id,
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
      this.price,
      this.status,
      this.statut,
      this.priority});

  select(CartContext cartContext, String entry, food, Function onFinish) {
    if (this.selectedMenu[entry] != null && selectedMenu[entry].firstWhere((element) => element.id != food.id, orElse: () => null) != null) {
      foodMenuSelected[entry].optionSelected = [];
      selectedMenu[entry] = [food];
      cartContext.addOption(this, foodMenuSelected[entry].optionSelected);
      cartContext.refresh();
    } else
      selectedMenu[entry] = [food];
    onFinish();
  }

  setFoodMenuSelected(String key, value) {
    _foodMenuSelected[key] = value;
    _foodMenuSelected[key].isMenu = true;
  }

  List<Food> get foodMenuSelecteds {
    List<Food> foods = [];
    _foodMenuSelected.forEach((key, value) {
      foods.add(value);
    });

    return foods;
  }

  int get totalPrice {
    int price = 0;

    if (type == MenuType.priceless.value) return 0;

    this._foodMenuSelected.forEach((key, food) {
      food.quantity = 1;
      if (type == MenuType.fixed_price.value) {
        food.optionSelected?.forEach((option) {
          option?.itemOptionSelected?.forEach((item) {
            if (item.price?.amount != null) price += item.price.amount * item.quantity;
          });
        });
      } else {
        price += food.totalPrice * quantity;
      }
      if (type == MenuType.fixed_price.value) {
        if (food.additionalPrice != null) {
          price += food.additionalPrice.amount;
        }
      }
    });

    if (type == MenuType.fixed_price.value) {
      price += (this.price?.amount ?? 0);
    }

    price = price * quantity;

    return price;
  }

  Map<String, Food> get foodMenuSelected => _foodMenuSelected;

  factory Menu.clone(Menu menu) {
    Menu clone = Menu(
        name: menu.name,
        id: menu.id,
        optionSelected: menu.optionSelected.map((e) => Option.copy(e)).toList(),
        message: menu.message,
        description: menu.description,
        type: menu.type,
        isMenu: menu.isMenu,
        isFoodForMenu: menu.isFoodForMenu,
        imageURL: menu.imageURL,
        restaurant: menu.restaurant,
        price: menu.price,
        foods: menu.foods.map((f) => MenuFood.copy(f)).toList(),
        status: menu.status);

    clone.foodSelected = menu.foodSelected.map((e) => Food.copy(e)).toList();

    return clone;
  }

  factory Menu.fromJson(Map<String, dynamic> json, {String resto, bool fromCommand = false}) {
    Menu _menu = Menu(
      id: json['_id'],
      name: json['name'],
      imageURL: json['imageURL'] ?? "",
      foods: json['foods'] is List ? json['foods']?.map<MenuFood>((data) => MenuFood.fromJson(data))?.toList() ?? [] : [],
      description: json['description'],
      restaurant: json['restaurant'] is String ? json['restaurant'] : Restaurant.fromJson(json["restaurant"]),
      type: json['type'],
      priority: json['priority'],
      price: Price.fromJson(json['price']),
      // status :json["status"] ?? true,
      optionSelected: json['options'] != null ? (json['options'] as List).map((e) => Option.fromJson(e)).where((element) => element.maxOptions > 0).toList() : [],
    );
    _menu.isMenu = true;
    return _menu;
  }

  toJson() => {"_id": this.id, "name": this.name, "imageURL": this.imageURL, "foods": this.foods.map((v) => v.toJson()).toList(), "description": this.description};
}

class MenuFood {
  String sId;
  List<Food> foods;
  String title;
  int maxOptions;
  bool isObligatory;

  List<ItemsOption> itemOptionSelected = [];

  MenuFood({
    this.sId,
    this.foods,
    this.title,
    this.maxOptions,
    this.itemOptionSelected,
    this.isObligatory,
  });

  factory MenuFood.copy(MenuFood o) => MenuFood(
        itemOptionSelected: o.itemOptionSelected?.map((e) => ItemsOption.copy(e))?.toList(),
        foods: o.foods,
        maxOptions: o.maxOptions,
        sId: o.sId,
        title: o.title,
        isObligatory: o.isObligatory,
      );

  MenuFood.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    if (json['items'] != null) {
      foods = <Food>[];
      json['items'].forEach((v) {
        if (!(v is String)) foods.add(Food.fromJson(v));
      });
    }
    title = json['title'];
    maxOptions = json['maxOptions'];
    isObligatory = json['isObligatory'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.itemOptionSelected != null) {
      data['items'] = this.itemOptionSelected.map((v) => v.toJson()).toList();
    }
    data['title'] = this.title;
    data['maxOptions'] = this.maxOptions;
    data['isObligatory'] = this.isObligatory;
    return data;
  }
}

class Restaurant {
  final String id;
  final String name;
  final String logo;
  final String type;
  final Location location;
  final String address;
  final String description;
  final List<String> menus;
  final List<String> foods;
  final List<FoodType> foodTypes;
  final String fixPhoneNumber;
  final String phoneNumber;
  bool status;
  final String admin;
  final bool delivery;
  final List<OpeningTimes> openingTimes;
  final bool surPlace;
  final bool aEmporter;
  final String url;
  final dynamic category;
  final int priority;
  final bool accessible;
  final bool paiementLivraison;
  final bool paiementCB;
  final bool cbDirectToAdvisor;
  final bool isMenuActive;
  final bool isBoissonActive;
  final String city;
  final String postalCode;
  final String fixedLinePhoneNumber;
  final RestaurantDiscount discount;
  final bool discountIsPrice;
  final String discountType;
  final String qrcodeLink;
  final String qrcodePricelessLink;
  final String customerStripeKey;
  final String customerSectretStripeKey;
  final String createdAt;
  DateTime get creatAtDateTime => DateTime.tryParse(createdAt);
  final String updatedAt;
  DateTime get updatedAtDateTime => DateTime.tryParse(updatedAt);
  final RestaurantLivraison livraison;
  final String minPriceIsDelivery;
  double get minPriceIsDeliveryDouble => double.tryParse(minPriceIsDelivery ?? "0.0") ?? 0;
  int priceDelevery;
  final bool deliveryFixed;
  final double priceByMiles;
  String optionLivraison = "";
  String appartement = "";
  String codeappartement = "";
  int etage = 0;

  bool isFreeCP(String cp) {
    final v = livraison?.freeCP?.contains(cp) == true;
    if (v) {
      print("$logTrace free CP");
    }
    return v;
  }

  bool isFreeCity(String city) {
    final v = livraison?.freeCity?.contains(city) == true;
    if (v) {
      print("$logTrace free City");
    }
    return v;
  }

  /// unit: km
  double get deleveryDistanceMax {
    final String distanceMax = livraison?.matrix?.length != 0 ? livraison?.matrix?.first : "0";
    final res = (double.tryParse(distanceMax ?? '0.0') ?? 0.0);
    return res;
  }

  Restaurant({
    this.phoneNumber,
    @required this.id,
    @required this.name,
    this.type = 'common_restaurant',
    this.logo,
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
    this.openingTimes,
    this.aEmporter,
    this.surPlace,
    this.url,
    this.category,
    this.priority,
    this.accessible,
    this.etage,
    this.fixPhoneNumber,
    this.paiementLivraison,
    this.paiementCB,
    this.appartement,
    this.cbDirectToAdvisor,
    this.city,
    this.codeappartement,
    this.discount,
    this.discountIsPrice,
    this.discountType,
    this.fixedLinePhoneNumber,
    this.isBoissonActive,
    this.isMenuActive,
    this.optionLivraison,
    this.postalCode,
    this.qrcodeLink,
    this.qrcodePricelessLink,
    this.customerSectretStripeKey,
    this.customerStripeKey,
    this.createdAt,
    this.updatedAt,
    this.livraison,
    this.minPriceIsDelivery,
    this.deliveryFixed,
    this.priceByMiles,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    Restaurant res = Restaurant(
      id: json['_id'],
      name: json['name'],
      type: json['categorie'],
      logo: json['logo'] ?? "",
      location: Location.fromJson(
        json['location'],
      ),
      address: json['address'] ?? '',
      description: json['description'] ?? '',
      menus: (json['menus'] as List).map<String>((e) => e).toList(),
      foods: (json['foods'] as List).map<String>((e) => e).toList(),
      foodTypes: (json['foodTypes'] as List).map<FoodType>((e) => FoodType.fromJson(e)).toList() ?? [],
      phoneNumber: json['phoneNumber'] ?? "",
      status: json['referencement'],
      accessible: json['status'],
      admin: json['admin'] is String ? json['admin'] : json['admin']['_id'],
      priceDelevery: json['deliveryPrice']['amount'],
      delivery: json['delivery'] ?? true,
      aEmporter: json['aEmporter'] ?? true,
      surPlace: json['surPlace'] ?? true,
      url: json['url'] != null ? json['url'] as String : "Menu advisor",
      category: json['category'],
      priority: json['priority'],
      openingTimes: (json['openingTimes'] != null) ? (json['openingTimes'] as List).map<OpeningTimes>((e) => OpeningTimes.fromJson(e)).toList() : [],
      paiementLivraison: json['paiementLivraison'],
      paiementCB: json['paiementCB'],
      appartement: json['appartement'],
      cbDirectToAdvisor: json['cbDirectToAdvisor'],
      codeappartement: json['codeappartement'],
      city: json['city'],
      discount: RestaurantDiscount.fromMap(json['discount']),
      discountIsPrice: json['discountIsPrice'],
      discountType: json['discountType'],
      fixedLinePhoneNumber: json['fixedLinePhoneNumber'],
      isBoissonActive: json['isBoissonActive'],
      isMenuActive: json['isMenuActive'],
      optionLivraison: json['optionLivraison'],
      postalCode: json['postalCode'],
      qrcodeLink: json['qrcodeLink'],
      qrcodePricelessLink: json['qrcodePricelessLink'],
      customerSectretStripeKey: json['customerSectretStripeKey'],
      customerStripeKey: json['customerStripeKey'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      livraison: json['livraison'] != null ? RestaurantLivraison.fromMap(json['livraison']) : null,
      minPriceIsDelivery: json['minPriceIsDelivery'],
      deliveryFixed: json['deliveryFixed'],
      priceByMiles: json['priceByMiles']?.toDouble(),
    );

    if (!res.accessible) {
      res.status = false;
    }

    return res;
  }

  bool get isOpen {
    bool open = false;
    DateTime dateNow = DateTime.now();
    TimeOfDay timeNow = TimeOfDay.now();
    TimeOfDay timeBegin;
    TimeOfDay timeEnd;

    this.openingTimes.forEach((element) {
      if (element.day == dateNow.weekDayToString) {
        //AM
        int hourAM = element.openings[0].begin.hour;
        int minAM = element.openings[0].begin.minute;

        int endhourAM = element.openings[0].end.hour;
        int endminAM = element.openings[0].end.minute;

        // if (dateNow.hour <= 12){
        timeBegin = TimeOfDay(hour: hourAM, minute: minAM);
        timeEnd = TimeOfDay(hour: endhourAM, minute: endminAM);

        if (timeNow.timeOfDayToDouble > timeBegin.timeOfDayToDouble && timeNow.timeOfDayToDouble < timeEnd.timeOfDayToDouble) {
          open = true;
          return;
        }
        // }else{
        if (element.openings.length > 1) {
          //PM
          int hourPM = element.openings[1].begin.hour;
          int minPM = element.openings[1].begin.minute;

          int bhourPM = element.openings[1].end.hour;
          int eminPM = element.openings[1].end.minute;
          timeBegin = TimeOfDay(hour: hourPM, minute: minPM);
          timeEnd = TimeOfDay(hour: bhourPM, minute: eminPM);

          if (timeNow.timeOfDayToDouble > timeBegin.timeOfDayToDouble && timeNow.timeOfDayToDouble < timeEnd.timeOfDayToDouble) {
            open = true;
            return;
          }
          // }else{
          //   open = false;
          //   return;
          // }

        }
      } else {
        print("other day...");
      }
    });
    return open;
  }

  int getFirstOpeningHour(DateTime date, {bool force = false}) {
    int hour = 0;

    bool open = false;
    DateTime dateNow = date;
    TimeOfDay timeNow = TimeOfDay.fromDateTime(date);
    TimeOfDay timeBegin;
    TimeOfDay timeEnd;

    if (force) {
      OpeningTimes time = this.openingTimes.firstWhere((element) => element.day == date.weekDayToString);
      hour = time.openings.first.begin.hour;
      return hour;
    }

    this.openingTimes.forEach((element) {
      if (element.day == dateNow.weekDayToString) {
        //AM
        int hourAM = element.openings[0].begin.hour;
        int minAM = element.openings[0].begin.minute;

        int endhourAM = element.openings[0].end.hour;
        int endminAM = element.openings[0].end.minute;

        if (dateNow.hour <= 12) {
          timeBegin = TimeOfDay(hour: hourAM, minute: minAM);
          timeEnd = TimeOfDay(hour: endhourAM, minute: endminAM);

          if (timeNow.timeOfDayToDouble > timeBegin.timeOfDayToDouble) {
            OpeningTimes time = this.openingTimes.firstWhere((element) => element.day == date.weekDayToString);
            hour = time.openings.first.begin.hour;
            return;
          } else if (timeNow.timeOfDayToDouble < timeEnd.timeOfDayToDouble) {
            OpeningTimes time = this.openingTimes.firstWhere((element) => element.day == date.weekDayToString);
            hour = time.openings.first.end.hour;
            return;
          }
        } else {
          if (element.openings.length > 1) {
            //PM
            int hourPM = element.openings[1].begin.hour;
            int minPM = element.openings[1].begin.minute;

            int bhourPM = element.openings[1].end.hour;
            int eminPM = element.openings[1].end.minute;
            timeBegin = TimeOfDay(hour: hourPM, minute: minPM);
            timeEnd = TimeOfDay(hour: bhourPM, minute: eminPM);

            if (timeNow.timeOfDayToDouble > timeBegin.timeOfDayToDouble) {
              OpeningTimes time = this.openingTimes.firstWhere((element) => element.day == date.weekDayToString);
              hour = time.openings.first.begin.hour;
              return;
            } else if (timeNow.timeOfDayToDouble < timeEnd.timeOfDayToDouble) {
              OpeningTimes time = this.openingTimes.firstWhere((element) => element.day == date.weekDayToString);
              hour = time.openings.first.end.hour;
              return;
            }
          } else {
            open = false;
            return;
          }
        }
      } else {
        print("other day...");
      }
    });

    return hour;
  }

  bool isOpenByDate(DateTime date, TimeOfDay t) {
    bool open = false;
    DateTime dateNow = date;
    TimeOfDay timeNow = t;
    TimeOfDay timeBegin;
    TimeOfDay timeEnd;

    if (timeNow == null) {
      throw "$logTrace timeNow is null";
    }

    this.openingTimes.forEach((element) {
      if (element.day.toLowerCase() == dateNow.weekDayToString.toLowerCase()) {
        //AM
        int hourAM = element.openings[0].begin.hour;
        int minAM = element.openings[0].begin.minute;

        int endhourAM = element.openings[0].end.hour;
        int endminAM = element.openings[0].end.minute;

        // if (dateNow.hour <= 12){
        timeBegin = TimeOfDay(hour: hourAM, minute: minAM);
        timeEnd = TimeOfDay(hour: endhourAM, minute: endminAM);

        if (timeNow.timeOfDayToDouble > timeBegin.timeOfDayToDouble && timeNow.timeOfDayToDouble < timeEnd.timeOfDayToDouble) {
          open = true;
          return;
        }
        // }else{
        if (element.openings.length > 1) {
          //PM
          int hourPM = element.openings[1].begin.hour;
          int minPM = element.openings[1].begin.minute;

          int bhourPM = element.openings[1].end.hour;
          int eminPM = element.openings[1].end.minute;
          timeBegin = TimeOfDay(hour: hourPM, minute: minPM);
          timeEnd = TimeOfDay(hour: bhourPM, minute: eminPM);

          if (timeNow.timeOfDayToDouble > timeBegin.timeOfDayToDouble && timeNow.timeOfDayToDouble < timeEnd.timeOfDayToDouble) {
            open = true;
            return;
          }
          // }else{
          //   open = false;
          //   return;
          // }

        }
      } else {
        print("$logTrace other day...");
      }
    });
    return open;
  }

  String get categories {
    final categories = category;
    (categories as List).sort((a, b) => a["priority"].compareTo(b["priority"]));
    String cat = "";
    categories?.forEach((element) {
      cat += "${(categories as List).indexOf(element) == 0 ? "" : " - "}${element['name'] is String ? element['name'] : element['name']['fr']}";
    });
    return cat;
  }
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
  // final List<PaymentCard> paymentCards;
  final List<dynamic> paymentCards;

  factory User.fromJson(Map<String, dynamic> json) => User(
      id: json['_id'],
      email: json['email'],
      photoURL: json['photoURL'],
      name: UserName.fromJson(json['name']),
      favoriteRestaurants: (json['favoriteRestaurants'] as List).map<String>((e) => e).toList(),
      favoriteFoods: (json['favoriteFoods'] as List).map<String>((e) => e).toList(),
      paymentCards: json['paymentCards'] is List ? (json['paymentCards'] as List).map((e) => e).toList() ?? [] : [],
      address: json['address'],
      phoneNumber: json['phoneNumber']);

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
    return "${this.name.first} ${this.name.last}";
  }
}

class Command {
  final String id;
  final dynamic relatedUser;
  final String commandType;
  final bool discountIsPrice;
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
  final String optionLivraison;
  final String codeappartement;
  final String appartement;
  final bool payed;
  final String priceLivraison;
  int etage;
  dynamic paiementLivraison;
  dynamic customer;
  bool withCodeDiscount = false;

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
    this.priceless,
    this.payed,
    this.optionLivraison,
    this.codeappartement,
    this.etage,
    this.appartement,
    this.paiementLivraison,
    this.customer,
    this.priceLivraison,
    this.discountIsPrice,
  });

  factory Command.fromJson(Map<String, dynamic> json) => Command(
        id: json['_id'] ?? "",
        relatedUser: json['relatedUser'],
        commandType: json['commandType'],
        totalPrice: json['totalPrice'],
        discountIsPrice: json['discountIsPrice'],
        validated: json['validated'],
        revoked: json['revoked'],
        items: json['items'] != null ? (json['items'] as List).map((e) => CommandItem.fromJson(e)).toList() : [],
        menus: json['menus'] != null ? (json['menus'] as List).map((e) => CommandItem.fromJson(e, isMenu: true)).toList() : [],
        createdAt: json['createdAt'] != null
            ? (json['createdAt'] is String)
                ? DateTime.parse(json['createdAt'])
                : DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
            : null,
        shippingAddress: json['shippingAddress'],
        shippingTime: json['shippingTime'] != null
            ? (json['shippingTime'] is String)
                ? DateTime.parse(json['shippingTime'])
                : DateTime.fromMillisecondsSinceEpoch(json['shippingTime'])
            : null,
        shipAsSoonAsPossible: json['shipAsSoonAsPossible'] ?? false,
        code: json['code'],
        comment: json['comment'] ?? " ",
        restaurant: json['restaurant'] is String ? json['restaurant'] : Restaurant.fromJson(json['restaurant']),
        priceless: json['priceless'] ?? false,
        optionLivraison: json['optionLivraison'],
        codeappartement: json['codeAppartement'] ?? "",
        appartement: json['appartement'] ?? "",
        payed: json["payed"]["status"],
        etage: json['etage'] ?? 0,
        paiementLivraison: json['paiementLivraison'] ?? false,
        customer: json['customer'],
        priceLivraison: json['priceLivraison'],
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

  CommandModel({this.items, this.commandType, this.code});

  CommandModel.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <CommandItem>[];
      json['items'].forEach((v) {
        items.add(CommandItem.fromJson(v));
      });
    }
    if (json['menus'] != null) {
      menus = <CommandItem>[];
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

  CommandItem({this.sId, this.quantity, this.food, this.menu, this.options, this.foods});

  CommandItem.fromJson(Map<String, dynamic> json, {bool isMenu = false}) {
    sId = json['_id'];
    if (json['item'] is String) food = json['item'];
    if (isMenu) {
      menu = json['item'] != null ? Menu.fromJson(json['item'], fromCommand: true) : null;
      foodMenuSelected = json['foods'] is List ? json['foods']?.map<FoodSelectedFromCommandMenu>((data) => FoodSelectedFromCommandMenu.fromJson(data))?.toList() ?? [] : [];
    } else {
      food = json['item'] != null ? Food.fromJson(json['item'], fromCommande: true) : null;
      if (json['foods'] != null) foods = json['foods'] is List ? json['foods']?.map<Food>((data) => Food.fromJson(data, fromCommande: true))?.toList() ?? [] : [];
      options = json['options'] == null ? [] : (json['options'] as List).map((e) => Option.fromJson(e)).toList();
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

  FoodSelectedFromCommandMenu({this.id, this.options, this.food});

  factory FoodSelectedFromCommandMenu.fromJson(var json) =>
      FoodSelectedFromCommandMenu(id: json['_id'], food: Food.fromJson(json['food']), options: json['options'] == null ? [] : (json['options'] as List).map((e) => Option.fromJson(e)).toList());
}

class FoodType {
  String id;
  dynamic tag;
  dynamic name;
  int priority;
  dynamic restaurant;

  FoodType({
    this.tag,
    this.name,
    this.id,
    this.restaurant,
  });

  FoodType.fromJson(var json) {
    if (json is String)
      id = json;
    else {
      tag = json['tag'];
      name = (json['name'] is String) ? json['name'] : json['name']["fr"];
      id = json["_id"];
      priority = json["priority"];
      restaurant = json["restaurant"] != null
          ? (json["restaurant"] is String)
              ? json["restaurant"]
              : Restaurant.fromJson(json["restaurant"])
          : null;
    }
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

  @override
  String toString() {
    return this.sId;
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
      features = <Features>[];
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
    properties = json['properties'] != null ? new Properties.fromJson(json['properties']) : null;
    bbox = json['bbox'].cast<double>();
    geometry = json['geometry'] != null ? new Geometry.fromJson(json['geometry']) : null;
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

  Properties({this.placeId, this.osmType, this.osmId, this.placeRank, this.category, this.type, this.importance, this.addresstype, this.name, this.displayName, this.address});

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
    address = json['address'] != null ? new Address.fromJson(json['address']) : null;
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

  Address({this.houseNumber, this.road, this.neighbourhood, this.suburb, this.cityDistrict, this.city, this.municipality, this.county, this.state, this.country, this.postcode, this.countryCode});

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
  bool isObligatory;

  List<ItemsOption> itemOptionSelected = [];

  Option({
    this.sId,
    this.items,
    this.title,
    this.maxOptions,
    this.itemOptionSelected,
    this.isObligatory,
  });

  factory Option.copy(Option o) => Option(
        itemOptionSelected: o.itemOptionSelected?.map((e) => ItemsOption.copy(e))?.toList(),
        items: o.items,
        maxOptions: o.maxOptions,
        sId: o.sId,
        title: o.title,
        isObligatory: o.isObligatory,
      );

  Option.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    if (json['items'] != null) {
      items = <ItemsOption>[];
      json['items'].forEach((v) {
        if (!(v is String)) items.add(ItemsOption.fromJson(v));
      });
    }
    title = json['title'];
    maxOptions = json['maxOptions'];
    isObligatory = json['isObligatory'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.itemOptionSelected != null) {
      data['items'] = this.itemOptionSelected.map((v) => v.toJson()).toList();
    }
    data['title'] = this.title;
    data['maxOptions'] = this.maxOptions;
    data['isObligatory'] = this.isObligatory;
    return data;
  }

  bool get isMaxOptions {
    int val = 0;
    for (ItemsOption itemsOption in itemOptionSelected) {
      val += itemsOption.quantity;
    }
    return this.maxOptions > val;
  }

  int get quantityOptions {
    int val = 0;
    for (ItemsOption itemsOption in items) {
      val += itemsOption.quantity;
    }
    return val;
  }
}

class ItemsOption {
  String sId;
  String name;
  Price price;
  String imageUrl;
  int quantity = 0;
  ItemsOption item;
  bool isObligatory;
  int priority;
  bool isSelected = false;
  bool isSingle = false;

  ItemsOption({
    this.sId,
    this.name,
    this.price,
    this.imageUrl,
    this.quantity,
    this.item,
    this.isSelected,
    this.isObligatory,
    this.priority,
  });

  ItemsOption.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'] ?? "";
    if (json['price'] != null) price = Price.fromJson(json['price']);
    imageUrl = json['imageURL'];
    quantity = json['quantity'];
    isObligatory = json['isObligatory'];
    priority = json['priority'];
    if (json['item'] != null) item = ItemsOption.fromJson(json['item']);
  }

  factory ItemsOption.copy(ItemsOption item) => ItemsOption(
        name: item.name,
        imageUrl: item.imageUrl,
        item: item.item,
        price: Price.copy(item.price),
        quantity: item.quantity,
        sId: item.sId,
        isSelected: item.isSelected,
        isObligatory: item.isObligatory,
        priority: item.priority,
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['quantity'] = this.quantity;
    data['item'] = {
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

  Message({@required this.name, @required this.phoneNumber, @required this.email, @required this.message, this.read, this.target});

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

enum MenuType { per_food, priceless, fixed_price }

class Blog {
  String sId;
  String title;
  String description;
  String url;
  String imageURL;
  String postedAt;
  String updatedAt;
  int iV;

  Blog({this.sId, this.title, this.description, this.url, this.imageURL, this.postedAt, this.updatedAt, this.iV});

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
      openings = <Openings>[];
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