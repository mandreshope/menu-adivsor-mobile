import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:menu_advisor/src/components/map_window_marker.dart';
import 'package:menu_advisor/src/constants/constant.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';

import '../models/models.dart';

class MapPolylinePage extends StatefulWidget {
  final LatLng initialPosition;
  final LatLng destinationPosition;
  final Restaurant restaurant;
  MapPolylinePage({
    Key key,
    @required this.initialPosition,
    @required this.restaurant,
    @required this.destinationPosition,
  }) : super(key: key);

  @override
  _MapPolylinePageState createState() => _MapPolylinePageState();
}

class _MapPolylinePageState extends State<MapPolylinePage> {
  Position _currentPosition;
  LatLng _initialPosition;
  LatLng _destinationPosition;

  //google maps
  static final _googleMapsApiKey = "AIzaSyCL8_ZHnuPxDiElzyy4CCZEbJBv4ankXVc";
  Completer<GoogleMapController> _mapController = Completer();
  final PolylinePoints _polylinePoints = PolylinePoints();

  StreamSubscription<Position> _positionStream;

  static final _center = LatLng(37.43296265331129, -122.08832357078792);

  final Set<Marker> _markers = {};
  final Map<PolylineId, Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = <LatLng>[];

  bool showInfo = true;

  // ignore: unused_field
  LatLng _lastMapPosition = _center;

  void init() {
    setState(() {
      _initialPosition = widget.initialPosition;
      _currentPosition = Position(
        longitude: _initialPosition.longitude,
        latitude: _initialPosition.latitude,
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        timestamp: null,
      );
      _destinationPosition = widget.destinationPosition;
    });
    addInitPosAndDestPosMarker();
    getPolyline();
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  Future<void> addMyPosMarker() async {
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
      ));
    });
  }

  Future<void> addInitPosAndDestPosMarker() async {
    setState(() {
      String destPosMarkerId = 'destPos';
      _markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId(destPosMarkerId),
        position: LatLng(
          _destinationPosition.latitude,
          _destinationPosition.longitude,
        ),
        infoWindow: InfoWindow(
          title: "${widget.restaurant.name}",
        ),
        onTap: () {
          setState(() {
            showInfo = true;
          });
        },
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
      ));
    });
  }

  void _checkForLocationPermission() async {
    LocationPermission result = await Geolocator.checkPermission();
    if (result == LocationPermission.denied) await Geolocator.requestPermission();
  }

  void _listenLocation() async {
    if (!mounted) return;
    _positionStream = Geolocator.getPositionStream().listen((Position position) {
      print('$logTrace Current position stream: ${position.latitude},${position.longitude}');
      setState(() {
        _currentPosition = position;
      });
      addMyPosMarker();
    });
  }

  Future getPolyline() async {
    polylineCoordinates.clear();
    try {
      PolylineResult result = await _polylinePoints.getRouteBetweenCoordinates(
        _googleMapsApiKey,
        PointLatLng(_initialPosition.latitude, _initialPosition.longitude),
        PointLatLng(_destinationPosition.latitude, _destinationPosition.longitude),
      );
      if (result.points.isNotEmpty) {
        result.points.forEach((PointLatLng point) {
          setState(() {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          });
        });
      }
      addPolyLine();
    } catch (e) {
      throw e;
    }
    return;
  }

  addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      jointType: JointType.round,
      geodesic: true,
      polylineId: id,
      width: 5,
      color: const Color(0xffda143c),
      points: polylineCoordinates,
    );
    setState(() {
      _polylines[id] = polyline;
    });
  }

  //google maps

  @override
  void initState() {
    _checkForLocationPermission();
    init();
    _listenLocation();
    super.initState();
  }

  @override
  void dispose() {
    _positionStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          _currentPosition != null
              ? GoogleMap(
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  ].toSet(),
                  onTap: (latlong) {
                    setState(() {
                      showInfo = false;
                    });
                  },
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(_currentPosition.latitude, _currentPosition.longitude),
                    zoom: 14.4746,
                  ),
                  zoomControlsEnabled: false,
                  onCameraMove: _onCameraMove,
                  polylines: Set<Polyline>.of(_polylines.values),
                  markers: _markers,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController.complete(controller);
                    controller.showMarkerInfoWindow(MarkerId('destPos'));
                  },
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () async {
                var map = await _mapController.future;
                map.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(_currentPosition.latitude, _currentPosition.longitude), zoom: 15))).catchError((onError) {});
                map.showMarkerInfoWindow(MarkerId('destPos'));
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
          Visibility(
            visible: showInfo,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: MapWindowMarker(
                position: this._currentPosition,
                restaurant: widget.restaurant,
                fromMapItineraire: true,
              ),
            ),
          )
        ],
      ),
    );
  }
}
