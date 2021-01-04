import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/pages/restaurant.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/types.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textFormFieldTranslator.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';

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
  bool _loading = false;
  Api _api = Api.instance;

  //google maps 
  Completer<GoogleMapController> _mapController = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final _center = LatLng(37.43296265331129, -122.08832357078792);

  final Set<Marker> _markers = {};
  
  LatLng _lastMapPosition = _center;

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  Future<void> addMyPosMarker() async {
    setState(() {
      String myPosMarkerId = 'myPos';
      _markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId(myPosMarkerId),
        position: LatLng(_currentPosition.latitude, _currentPosition.longitude,),
        infoWindow: InfoWindow(
          title: AppLocalizations.of(context).translate('you'),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    });
    // var map = await _mapController.future;
    // map.animateCamera(
    //   CameraUpdate.newCameraPosition(
    //     CameraPosition( target: LatLng(
    //       _currentPosition.latitude,
    //       _currentPosition.longitude,
    //     ), zoom: 15)
    //   ))
    // .catchError((onError) {

    // });
  }

  void addAllRestaurantsMarkers() {
    setState(() {
      for (var restaurant in _nearestRestaurants) {
        String markerId = restaurant.content['location']['coordinates'][1].toString()+restaurant.content['location']['coordinates'][0].toString();
        _markers.add(Marker(
          // This marker id can be anything that uniquely identifies each marker.
          markerId: MarkerId(markerId),
          position: LatLng(
            restaurant.content['location']['coordinates'][1],
            restaurant.content['location']['coordinates'][0],
          ),
          infoWindow: InfoWindow(
            title: restaurant.content['name'],
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

    addMyPosMarker();
    addAllRestaurantsMarkers();
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
          filters: filters,
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
                    initialCameraPosition: _kGooglePlex,
                    zoomControlsEnabled: false,
                    onCameraMove: _onCameraMove,
                    markers:_markers,
                    onMapCreated: (GoogleMapController controller) {
                      _mapController.complete(controller);
                    },
                  )
                // FlutterMap(
                //     mapController: _mapController,
                //     options: MapOptions(
                //       minZoom: 1.0,
                //       maxZoom: 18.0,
                //       zoom: 15.0,
                //       interactive: true,
                //       center: LatLng(
                //         _currentPosition.latitude,
                //         _currentPosition.longitude,
                //       ),
                //     ),
                //     layers: [
                //       TileLayerOptions(
                //         urlTemplate:
                //             'https://api.mapbox.com/styles/v1/darijavan/ckg69xpmk4eft19qhv1dhpe9k/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoiZGFyaWphdmFuIiwiYSI6ImNqb3diNXZ0eDBxMjkzdW9kc2F3aHh6M2EifQ.gTXds1mQoGDFQ5bhIeYvqA',
                //         subdomains: ['a', 'b', 'c'],
                //       ),
                //       MarkerLayerOptions(
                //         markers: [
                //           ..._nearestRestaurants
                //               .map(
                //                 (restaurant) => Marker(
                //                   width: 80,
                //                   height: 60,
                //                   point: LatLng(
                //                     restaurant.content['location']['coordinates'][1],
                //                     restaurant.content['location']['coordinates'][0],
                //                   ),
                //                   builder: (BuildContext context) => Container(
                //                     child: Column(
                //                       crossAxisAlignment: CrossAxisAlignment.center,
                //                       children: [
                //                         TextTranslator(
                //                           restaurant.content['name'],
                //                         ),
                //                         SizedBox(
                //                           height: 5,
                //                         ),
                //                         FaIcon(
                //                           FontAwesomeIcons.utensils,
                //                         ),
                //                       ],
                //                     ),
                //                   ),
                //                 ),
                //               )
                //               .toList(),
                //           Marker(
                //             width: 100,
                //             height: 60,
                //             point: LatLng(
                //               _currentPosition.latitude,
                //               _currentPosition.longitude,
                //             ),
                //             anchorPos: AnchorPos.align(AnchorAlign.top),
                //             builder: (BuildContext context) => Container(
                //               child: Column(
                //                 crossAxisAlignment: CrossAxisAlignment.center,
                //                 children: [
                //                   TextTranslator(
                //                     AppLocalizations.of(context).translate('you'),
                //                     style: TextStyle(
                //                       color: CRIMSON,
                //                       fontWeight: FontWeight.bold,
                //                       fontSize: 20,
                //                     ),
                //                   ),
                //                   SizedBox(
                //                     height: 5,
                //                   ),
                //                   Icon(
                //                     Icons.location_on,
                //                     color: CRIMSON,
                //                   ),
                //                 ],
                //               ),
                //             ),
                //           ),
                //         ],
                //       ),
                //     ],
                //   )
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
                              filters: filters,
                              type: 'restaurant',
                            ),
                          );
                          if (result != null && result['filters'] is Map) {
                            setState(() {
                              filters = result['filters'];
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
                                            final Restaurant restaurant = Restaurant.fromJson(e.content);

                                            return Card(
                                              elevation: 4.0,
                                              child: InkWell(
                                                borderRadius: BorderRadius.circular(10),
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
                                                  padding: const EdgeInsets.all(10),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.max,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      FadeInImage.assetNetwork(
                                                        image: restaurant.imageURL,
                                                        placeholder: 'assets/images/loading.gif',
                                                        height: 20,
                                                      ),
                                                      SizedBox(width: 20),
                                                      TextTranslator(
                                                        e.content['name'],
                                                      ),
                                                      Spacer(),
                                                      IconButton(
                                                        padding: EdgeInsets.zero,
                                                        icon: Icon(
                                                          Icons.remove_red_eye_outlined,
                                                        ),
                                                        constraints: BoxConstraints(
                                                          maxHeight: 26,
                                                          maxWidth: 26,
                                                        ),
                                                        onPressed: () async {
                                                          var map = await _mapController.future;
                                                          map.animateCamera(
                                                            CameraUpdate.newCameraPosition(
                                                              CameraPosition( target: LatLng(
                                                                restaurant.location.coordinates[1],
                                                                restaurant.location.coordinates[0],
                                                              ), zoom: 15)
                                                            ))
                                                          .catchError((onError) {

                                                          });
                                                          // _mapController.move(
                                                          //   LatLng(
                                                          //     restaurant.location.coordinates[0],
                                                          //     restaurant.location.coordinates[1],
                                                          //   ),
                                                          //   15,
                                                          // );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                      .toList(),
                                ],
                              )
                            : TextTranslator(
                                AppLocalizations.of(context).translate('no_result'),
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
                  var map = await _mapController.future;
                  map.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition( target: LatLng(_currentPosition.latitude,_currentPosition.longitude),zoom: 15))
                    )
                  .catchError((onError) {

                  });
                  // _mapController.move(
                  //   LatLng(
                  //     _currentPosition.latitude,
                  //     _currentPosition.longitude,
                  //   ),
                  //   15,
                  // );
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
