import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/components/map_window_marker.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/constants/constant.dart';
import 'package:menu_advisor/src/models/models.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/types/types.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/textFormFieldTranslator.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Position _currentPosition;
  // MapController _mapController = MapControllerImpl();
  String _searchValue = '';
  Timer _updateLocationInterval;
  Timer _timer;
  List<SearchResult> _nearestRestaurants = [];
  Map<String, dynamic> filters = Map();
  bool _loading = true;
  Api _api = Api.instance;

  //google maps
  Completer<GoogleMapController> _mapController = Completer();

  static final _center = LatLng(37.43296265331129, -122.08832357078792);

  final Set<Marker> _markers = {};

  // ignore: unused_field
  LatLng _lastMapPosition = _center;

  bool showInfo = false;
  Restaurant restaurant;

  int range;
  PanelController _panelController;
  String isopen = "Tous";

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  Future<void> addMyPosMarker() async {
    // BitmapDescriptor bitmapDescriptor = await MapUtils.createCustomMarkerBitmap(context,"2");
    setState(() {
      String myPosMarkerId = 'myPos';
      _markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId(myPosMarkerId),
        position: LatLng(
          _currentPosition.latitude,
          _currentPosition.longitude,
        ),
        infoWindow: InfoWindow(
          title: AppLocalizations.of(context).translate('you'),
        ),

        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        // icon: bitmapDescriptor
      ));
    });
  }

  void addAllRestaurantsMarkers() {
    setState(() {
      for (var restaurant in _nearestRestaurants) {
        String markerId = restaurant.content['name'] + restaurant.content['location']['coordinates'][1].toString() + restaurant.content['location']['coordinates'][0].toString();
        _markers.add(Marker(
          // This marker id can be anything that uniquely identifies each marker.
          markerId: MarkerId(markerId),
          position: LatLng(
            restaurant.content['location']['coordinates'][1],
            restaurant.content['location']['coordinates'][0],
          ),
          onTap: () {
            setState(() {
              this.restaurant = Restaurant.fromJson(restaurant.content);
              this.showInfo = true;
            });
          },

          infoWindow: InfoWindow(
            title: "${restaurant.content['name']}",
            /*onTap: (){
              RouteUtil.goTo(
                context: context,
                child: RestaurantPage(
                  restaurant: restaurant.content['id'],
                ),
                routeName: restaurantRoute,
              );
            }*/
          ),

          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ));
      }
    });
  }

  // google maps

  @override
  void initState() {
    super.initState();

    _panelController = PanelController();

    range = Provider.of<SettingContext>(context, listen: false).range;
    _checkForLocationPermission();

    _updateLocation(null).then((value) => _initSearch());

    _updateLocationInterval = Timer.periodic(
      Duration(
        seconds: 5,
      ),
      _updateLocation,
    );

    Timer.periodic(Duration(milliseconds: 80), (timer) {
      _panelController.open();
      timer.cancel();
    });
  }

  Future<void> _updateLocation(Timer timer) async {
    if (!mounted) return;

    Position position = await Geolocator.getCurrentPosition();
    print('$logTrace Current position: ${position.latitude},${position.longitude}');

    // if (!mounted) return;

    setState(() {
      _currentPosition = position;
    });

    addMyPosMarker();
    addAllRestaurantsMarkers();
    return;
  }

  void _checkForLocationPermission() async {
    LocationPermission result = await Geolocator.checkPermission();
    if (result == LocationPermission.denied) await Geolocator.requestPermission();

    _updateLocation(_updateLocationInterval);
  }

  void _onChanged(String value) {
    setState(() {
      _loading = true;
      _searchValue = value;
    });

    if (_timer?.isActive ?? false) {
      _timer.cancel();
    }

    _timer = Timer(
      Duration(seconds: 1),
      _initSearch,
    );
  }

  Future _initSearch() async {
    if (_searchValue == '') {
      _timer?.cancel();
      if (mounted)
        setState(() {
          _loading = true;
        });
      try {
        List<SearchResult> res = await _api.search(
          _searchValue,
          Provider.of<SettingContext>(
            context,
            listen: false,
          ).languageCode,
          type: 'restaurant',
          filters: filters,
          location: {
            "coordinates": [_currentPosition?.longitude ?? 0, _currentPosition?.latitude ?? 0] ?? [0, 0]
          },
        );

        _nearestRestaurants = res.where((element) {
          Restaurant restaurant = Restaurant.fromJson(element.content);
          if (isopen == "Tous") {
            return restaurant.status && restaurant.accessible;
          } else if (isopen == "ouvert") {
            return restaurant.isOpen && restaurant.status && restaurant.accessible;
          } else {
            return !restaurant.isOpen && restaurant.status && restaurant.accessible;
          }
          // return (restaurant.isOpen == (isopen == "Ouvert" ? true : false)) && restaurant.status;
        }).toList();
      } catch (error) {} finally {
        if (mounted)
          setState(() {
            _loading = false;
          });
      }
      return;
    }

    setState(() {
      _loading = true;
    });
    try {
      var results = await _api.search(
        _searchValue,
        Provider.of<SettingContext>(
          context,
          listen: false,
        ).languageCode,
        type: 'restaurant',
        location: {
          "coordinates": [_currentPosition?.longitude ?? 0, _currentPosition?.latitude ?? 0] ?? [0, 0]
        },
      );
      setState(() {
        _nearestRestaurants = results.where((element) {
          Restaurant restaurant = Restaurant.fromJson(element.content);
          if (isopen == "Tous") {
            return true;
          } else if (isopen == "ouvert") {
            return restaurant.isOpen;
          }
          return !restaurant.isOpen;
        }).toList();
      });
    } catch (error) {
      print(error.toString());
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translate('connection_issue'),
      );
    } finally {
      setState(() {
        _markers.clear();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextTranslator(
          AppLocalizations.of(context).translate("map_page_title"),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            _currentPosition != null
                ? GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(_currentPosition.latitude, _currentPosition.longitude),
                      zoom: 14.4746,
                    ),
                    zoomControlsEnabled: false,
                    onCameraMove: _onCameraMove,
                    markers: _markers,
                    onMapCreated: (GoogleMapController controller) {
                      _mapController.complete(controller);
                    },
                    onTap: (latlong) {
                      setState(() {
                        _panelController.close();
                        showInfo = false;
                      });
                    },
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  ),
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.8),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      spreadRadius: 0,
                      color: Colors.black26,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.search,
                      size: 16,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormFieldTranslator(
                        onChanged: _onChanged,
                        decoration: InputDecoration.collapsed(
                          hintText: AppLocalizations.of(context).translate("find_restaurant"),
                        ),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.contain,
                      child: IconButton(
                        onPressed: () async {
                          var result = await showDialog<Map<String, dynamic>>(
                            context: context,
                            builder: (_) => SearchSettingDialog(
                              languageCode: Provider.of<SettingContext>(context).languageCode,
                              fromMap: true,
                              filters: filters,
                              type: 'all',
                              shedule: isopen,
                              range: Provider.of<SettingContext>(context).range,
                            ),
                          );
                          if (result != null && result['filters'] is Map && result['shedule'] != null) {
                            setState(() {
                              filters = result['filters'];
                              range = result['range'];
                              isopen = result['shedule'];
                            });
                            _initSearch();
                          }
                        },
                        icon: FaIcon(
                          FontAwesomeIcons.slidersH,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: () async {
                  _updateLocation(null);
                  var map = await _mapController.future;
                  map.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(_currentPosition.latitude, _currentPosition.longitude), zoom: 15))).catchError((onError) {});
                  // _mapController.move(
                  //   LatLng(
                  //     _currentPosition.latitude,
                  //     _currentPosition.longitude,
                  //   ),
                  //   15,
                  // );
                  map.showMarkerInfoWindow(MarkerId('myPos'));
                  setState(() {
                    this.restaurant = restaurant;
                    this.showInfo = true;
                  });
                },
                child: Icon(Icons.my_location),
              ),
            ),
            // showinfo
            if (restaurant != null && showInfo)
              Positioned(
                  bottom: 120,
                  left: 0,
                  right: 0,
                  child: MapWindowMarker(
                    position: this._currentPosition,
                    restaurant: this.restaurant,
                  )),

            SlidingUpPanel(
              controller: _panelController,
              panel: _loading
                  ? Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(CRIMSON),
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      child: //_nearestRestaurants.isNotEmpty
                          // ?
                          Column(
                      children: [
                        Container(
                          width: 90,
                          height: 5,
                          margin: EdgeInsets.only(top: 15),
                          color: Colors.black.withAlpha(90),
                        ),
                        Container(
                            height: 80,
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                _nearestRestaurants.isNotEmpty ? "Voir les restaurants" : "Aucun restaurant trouvé",
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            )),
                        ..._nearestRestaurants
                            .map(
                              (e) => Builder(
                                builder: (_) {
                                  final Restaurant restaurant = Restaurant.fromJson(e.content);
                                  return Card(
                                    elevation: 4.0,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(0),
                                      onTap: () async {
                                        var map = await _mapController.future;
                                        map
                                            .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                                                target: LatLng(
                                                  restaurant.location.coordinates[1],
                                                  restaurant.location.coordinates[0],
                                                ),
                                                zoom: 25)))
                                            .catchError((onError) {});
                                        String markerId = e.content['name'] + e.content['location']['coordinates'][1].toString() + e.content['location']['coordinates'][0].toString();
                                        map.showMarkerInfoWindow(MarkerId(markerId));
                                        _panelController.close();
                                        setState(() {
                                          this.restaurant = restaurant;
                                          showInfo = true;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            FadeInImage.assetNetwork(
                                              image: restaurant.logo,
                                              placeholder: 'assets/images/loading.gif',
                                              height: 50,
                                              imageErrorBuilder: (_, __, ___) => Container(
                                                width: 50,
                                                height: 50,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(width: 20),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                TextTranslator(
                                                  e.content['name'],
                                                  style: TextStyle(fontSize: 16),
                                                ),
                                                Container(
                                                  width: MediaQuery.of(context).size.width - 150.0,
                                                  child: TextTranslator(
                                                    e.content['address'],
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, fontSize: 16),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () async {
                                                    if (e.content['phoneNumber'] != null) await launch("tel:${e.content['phoneNumber']}");
                                                  },
                                                  child: TextTranslator(
                                                    e.content['phoneNumber'],
                                                    style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, fontSize: 16),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 15,
                                                ),
                                              ],
                                            ),
                                            Spacer(),
                                            Column(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(color: restaurant.isOpen ? TEAL : CRIMSON, borderRadius: BorderRadius.circular(25)),
                                                  child: Text(restaurant.isOpen ? "Ouvert" : "Fermé", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 10)),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  );
                                },
                              ),
                            )
                            .toList(),
                      ],
                    )),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _updateLocationInterval?.cancel();

    super.dispose();
  }
}
