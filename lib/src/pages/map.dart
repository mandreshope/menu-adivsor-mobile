import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Position _currentPosition;
  MapController _mapController = MapControllerImpl();

  @override
  void initState() {
    super.initState();

    _checkForLocationPermission();
  }

  void _checkForLocationPermission() async {
    LocationPermission result = await checkPermission();
    if (result == LocationPermission.denied) await requestPermission();

    Position position = await getCurrentPosition();
    setState(() {
      _currentPosition = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
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
                      center: LatLng(
                        _currentPosition.latitude,
                        _currentPosition.longitude,
                      ),
                    ),
                    layers: [
                      TileLayerOptions(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: ['a', 'b', 'c'],
                      ),
                      MarkerLayerOptions(
                        markers: [
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: LatLng(
                              _currentPosition.latitude,
                              _currentPosition.longitude,
                            ),
                            builder: (BuildContext context) => Container(
                              child: Icon(
                                Icons.location_on,
                                color: CRIMSON,
                                size: 30,
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
              top: 30,
              left: 30,
              right: 30,
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
                    ]),
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
              bottom: 30,
              right: 30,
              child: FloatingActionButton(
                onPressed: () async {
                  Position position = await getCurrentPosition();
                  _mapController.move(
                      LatLng(position.latitude, position.longitude), 15.0);
                },
                child: Icon(Icons.my_location),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
