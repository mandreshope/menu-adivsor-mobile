import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:menu_advisor/src/constants/constant.dart';
import 'package:menu_advisor/src/models/models.dart';
import 'package:menu_advisor/src/models/restaurants/restaurant_code_discount_model.dart';

class CommandContext extends ChangeNotifier {
  PaymentCard _paymentCard;
  String _commandType;
  String _deliveryAddress;
  LatLng _deliveryLatLng;
  DateTime _deliveryDate;
  TimeOfDay _deliveryTime;
  List<Food> _items;
  CodeDiscount withCodeDiscount;

  set paymentCard(PaymentCard paymentCard) {
    _paymentCard = paymentCard;
    notifyListeners();
  }

  PaymentCard get paymentCard => _paymentCard;

  set commandType(String commandType) {
    _commandType = commandType;
    notifyListeners();
  }

  set deliveryLatLng(LatLng deliveryLatLng) {
    _deliveryLatLng = deliveryLatLng;
    notifyListeners();
  }

  LatLng get deliveryLatLng => _deliveryLatLng;

  String get commandType => _commandType;

  set deliveryAddress(String deliveryAddress) {
    _deliveryAddress = deliveryAddress;
    notifyListeners();
  }

  String get deliveryAddress => _deliveryAddress;

  set deliveryDate(DateTime deliveryDate) {
    _deliveryDate = deliveryDate;
    notifyListeners();
  }

  DateTime get deliveryDate => _deliveryDate;

  set deliveryTime(TimeOfDay deliveryTime) {
    _deliveryTime = deliveryTime;
    notifyListeners();
  }

  TimeOfDay get deliveryTime => _deliveryTime;

  Future<PlacesSearchResult> getLatLngFromAddress(String address) async {
    // final geocoding = GoogleMapsGeocoding(apiKey: GOOGLE_API_KEY);
    final places = new GoogleMapsPlaces(apiKey: GOOGLE_API_KEY);

    PlacesSearchResponse response = await places.searchByText(address);
    print(response.results);
    if (response.results.isNotEmpty) {
      return response.results.first;
    }
    return null;
  }

  double getDeliveryDistanceByMiles(Restaurant restaurant) {
    if (restaurant == null || deliveryLatLng == null) {
      return 0.0;
    }
    final distance = Geolocator.distanceBetween(
      restaurant.location.coordinates.last,
      restaurant.location.coordinates.first,
      deliveryLatLng.latitude,
      deliveryLatLng.longitude,
    );

    final inKm = distance / 1000;
    return double.parse(inKm.toStringAsFixed(2));
  }

  /// return (distance per km * Restaurant.priceByMiles) (€);
  ///
  double getDeliveryPriceByMiles(Restaurant restaurant) {
    if (restaurant == null || deliveryLatLng == null) {
      return 0.0;
    }
    final double priceByMiles = restaurant.priceByMiles; //5; // 5€ par km
    final distance = Geolocator.distanceBetween(
      restaurant.location.coordinates.last,
      restaurant.location.coordinates.first,
      deliveryLatLng.latitude,
      deliveryLatLng.longitude,
    );

    final inKm = distance / 1000;
    final result = inKm * priceByMiles;
    return double.parse(result.toStringAsFixed(2));
  }

  set items(List<Food> items) {
    _items = items;
    notifyListeners();
  }

  List<Food> get items => _items;

  clear() {
    _paymentCard = null;
    _commandType = null;
    _deliveryAddress = null;
    _deliveryDate = null;
    _deliveryTime = null;
    _items = null;
    _deliveryLatLng = null;
    withCodeDiscount = null;
    notifyListeners();
  }
}
