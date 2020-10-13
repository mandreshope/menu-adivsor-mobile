import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/pages/restaurant.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/types.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:provider/provider.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Position _currentPosition;
  MapController _mapController = MapControllerImpl();
  String _searchValue = '';
  Timer _updateLocationInterval;
  Timer _timer;
  List<SearchResult> _nearestRestaurants = [];
  bool _loading = false;
  Api _api = Api.instance;

  @override
  void initState() {
    super.initState();

    _checkForLocationPermission();

    _initSearch();

    _updateLocationInterval = Timer.periodic(
      Duration(
        seconds: 5,
      ),
      _updateLocation,
    );
  }

  void _updateLocation(Timer timer) async {
    if (!mounted) return;

    Position position = await getCurrentPosition();
    print('Current position: ${position.latitude},${position.longitude}');

    if (!mounted) return;

    setState(() {
      _currentPosition = position;
    });
  }

  void _checkForLocationPermission() async {
    LocationPermission result = await checkPermission();
    if (result == LocationPermission.denied) await requestPermission();

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
        _nearestRestaurants = await _api.search(
          _searchValue,
          Provider.of<SettingContext>(
            context,
            listen: false,
          ).languageCode,
          type: 'restaurant',
        );
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
      );
      setState(() {
        _nearestRestaurants = results;
      });
    } catch (error) {
      print(error.toString());
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translate('connection_issue'),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate("map_page_title"),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            _currentPosition != null
                ? FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      minZoom: 1.0,
                      maxZoom: 18.0,
                      zoom: 15.0,
                      interactive: true,
                      center: LatLng(
                        _currentPosition.latitude,
                        _currentPosition.longitude,
                      ),
                    ),
                    layers: [
                      TileLayerOptions(
                        urlTemplate:
                            'https://api.mapbox.com/styles/v1/darijavan/ckg69xpmk4eft19qhv1dhpe9k/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoiZGFyaWphdmFuIiwiYSI6ImNqb3diNXZ0eDBxMjkzdW9kc2F3aHh6M2EifQ.gTXds1mQoGDFQ5bhIeYvqA',
                        subdomains: ['a', 'b', 'c'],
                      ),
                      MarkerLayerOptions(
                        markers: [
                          ..._nearestRestaurants
                              .map(
                                (restaurant) => Marker(
                                  width: 80,
                                  height: 60,
                                  point: LatLng(
                                    restaurant.content['location']
                                        ['coordinates'][1],
                                    restaurant.content['location']
                                        ['coordinates'][0],
                                  ),
                                  builder: (BuildContext context) => Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          restaurant.content['name'],
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        FaIcon(
                                          FontAwesomeIcons.utensils,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          Marker(
                            width: 100,
                            height: 60,
                            point: LatLng(
                              _currentPosition.latitude,
                              _currentPosition.longitude,
                            ),
                            anchorPos: AnchorPos.align(AnchorAlign.top),
                            builder: (BuildContext context) => Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)
                                        .translate('you'),
                                    style: TextStyle(
                                      color: CRIMSON,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Icon(
                                    Icons.location_on,
                                    color: CRIMSON,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
                      child: TextFormField(
                        onChanged: _onChanged,
                        decoration: InputDecoration.collapsed(
                          hintText: AppLocalizations.of(context)
                              .translate("find_restaurant"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 90,
              left: 20,
              right: 20,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: 200,
                ),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.8),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      spreadRadius: 0,
                      color: Colors.black26,
                    ),
                  ],
                ),
                child: _loading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(CRIMSON),
                        ),
                      )
                    : SingleChildScrollView(
                        child: _nearestRestaurants.isNotEmpty
                            ? Column(
                                children: [
                                  ..._nearestRestaurants
                                      .map(
                                        (e) => Builder(
                                          builder: (_) {
                                            final Restaurant restaurant =
                                                Restaurant.fromJson(e.content);

                                            return Card(
                                              elevation: 4.0,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                onTap: () {
                                                  RouteUtil.goTo(
                                                    context: context,
                                                    child: RestaurantPage(
                                                      restaurant: restaurant.id,
                                                    ),
                                                    routeName: restaurantRoute,
                                                  );
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      FadeInImage.assetNetwork(
                                                        image:
                                                            restaurant.imageURL,
                                                        placeholder:
                                                            'assets/images/loading.gif',
                                                        height: 20,
                                                      ),
                                                      SizedBox(width: 20),
                                                      Text(
                                                        e.content['name'],
                                                      ),
                                                      Spacer(),
                                                      IconButton(
                                                        padding:
                                                            EdgeInsets.zero,
                                                        icon: Icon(
                                                          Icons
                                                              .remove_red_eye_outlined,
                                                        ),
                                                        constraints:
                                                            BoxConstraints(
                                                          maxHeight: 26,
                                                          maxWidth: 26,
                                                        ),
                                                        onPressed: () {
                                                          _mapController.move(
                                                            LatLng(
                                                              restaurant
                                                                  .location
                                                                  .coordinates[0],
                                                              restaurant
                                                                  .location
                                                                  .coordinates[1],
                                                            ),
                                                            15,
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                      .toList(),
                                ],
                              )
                            : Text(
                                AppLocalizations.of(context)
                                    .translate('no_result'),
                                textAlign: TextAlign.center,
                              ),
                      ),
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: () async {
                  _updateLocation(null);
                  _mapController.move(
                    LatLng(
                      _currentPosition.latitude,
                      _currentPosition.longitude,
                    ),
                    15,
                  );
                },
                child: Icon(Icons.my_location),
              ),
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
