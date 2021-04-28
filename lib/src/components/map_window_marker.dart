import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/pages/map_polyline.dart';
import 'package:menu_advisor/src/pages/restaurant.dart';
import 'package:menu_advisor/src/utils/map_utils.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';

class MapWindowMarker extends StatelessWidget {
  final Restaurant restaurant;
  final Position position;
  final bool fromMapItineraire;
  const MapWindowMarker({Key key, this.restaurant,this.position,this.fromMapItineraire = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        RouteUtil.goTo(
                            context: context,
                            child: RestaurantPage(
                              restaurant: this.restaurant.id,
                            ),
                            routeName: "",
                          );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15))
        ),
        child: Card(
          elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))
        ),
          child: Row(
            children: [
              /*Container(
                width: 75,
                height: 125,
                color: Colors.white,
                child: */
                // Hero(
                //   tag: 'tag:${restaurant.imageURL}',
                //   child: 
                  FadeInImage.assetNetwork(
                    placeholder: 'assets/images/loading.gif',
                    image: this.restaurant.imageURL,
                    height: 125,
                    width: 75,
                    fit: BoxFit.contain,
                    imageErrorBuilder: (_, __, ___) => Container(
                      height: 125,
                    width: 75,
                    ),
                  ),
                // ),
              // ),
              SizedBox(
                width: 10,
              ),
            
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextTranslator(this.restaurant.name),
                  SizedBox(
                    width: 5,
                  ),
                  TextTranslator(restaurant.category['name'] is String ?  this.restaurant.category['name'] : this.restaurant.category['name']["fr"] ?? "",),
                  SizedBox(
                    width: 5,
                  ),
                  TextTranslator(this.restaurant.address),
                  SizedBox(
                    width: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextTranslator(
                            "Livraison",
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Icon(restaurant.delivery ? Icons.check_circle_outline_outlined : Icons.close, color: restaurant.delivery ? TEAL : CRIMSON)
                        ],
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextTranslator(
                            "Sur place",
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Icon(restaurant.surPlace ? Icons.check_circle_outline_outlined : Icons.close, color: restaurant.surPlace ? TEAL : CRIMSON)
                        ],
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextTranslator(
                            "A emporter",
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Icon(restaurant.aEmporter ? Icons.check_circle_outline_outlined : Icons.close, color: restaurant.aEmporter ? TEAL : CRIMSON)
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(color: restaurant.isOpen ? TEAL : CRIMSON, borderRadius: BorderRadius.circular(25)),
                        child: Text(restaurant.isOpen ? "Ouvert" : "Fermé",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12
                            )),
                      ),
                      SizedBox(width: 10,),
                      InkWell(
                        onTap: (){
                          showDialog(context: context,
                                    builder: (_){
                                      return SheduleDialog(openingTimes: restaurant.openingTimes,);
                                    }
                                  );
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(25)),
                          child: Text("Horaire",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12
                              )),
                        ),
                      ),
                      SizedBox(width: 10,),
                      Visibility(
                        visible: !this.fromMapItineraire,
                                              child: InkWell(
                                                            onTap: () {
                                                              showModalBottomSheet(
                                                                backgroundColor: Colors.transparent,
                                                                  context: context,
                                                                  builder: (_) {
                                                                    return Container(
                                                                      // height: 80,
                                                                      decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.only(
                                                                          topRight: Radius.circular(50),
                                                                          topLeft: Radius.circular(50),
                                                                          
                                                                        ),
                                                                        color: Colors.white
                                                                      ),
                                                                      child: Column(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        children: [
                                                                          SizedBox(height: 15,),
                                                                          TextTranslator("Voir l'itineraire sur Google Map : ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                                                          SizedBox(height: 15,),
                                                                          Row(
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            children: [
                                                                              InkWell(
                                                                                onTap: () async {
                                                                                  var coordinates = restaurant.location.coordinates;
                                                                                  RouteUtil.goTo(
                                                                                      context: context,
                                                                                      child: MapPolylinePage(
                                                                                        restaurant: restaurant,
                                                                                        initialPosition: LatLng(position.latitude, position.longitude),
                                                                                        destinationPosition: LatLng(coordinates.last, coordinates.first),
                                                                                      ),

                                                                                      routeName: "",
                                                                                    );
                                                                                },
                                                                                child: Container(
                                                                                  padding: EdgeInsets.all(8),
                                                                                  decoration: BoxDecoration(color: BRIGHT_RED, borderRadius: BorderRadius.circular(5)),
                                                                                  child: Text("Map interne", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                                                                                ),
                                                                              ),
                                                                              SizedBox(width: 15,),
                                                                              InkWell(
                                                                                onTap: () async {
                                                                                  var coordinates = restaurant.location.coordinates;
                                                                                  MapUtils.openMap(position.latitude, position.longitude,
                                                                                  coordinates.last,coordinates.first);
                                                                                },
                                                                                child: Container(
                                                                                  padding: EdgeInsets.all(8),
                                                                                  decoration: BoxDecoration(color: DARK_BLUE, borderRadius: BorderRadius.circular(5)),
                                                                                  child: Text("Map externe", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          )
                                                                          ,SizedBox(height: 25,),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  });
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets.all(8),
                                                              decoration: BoxDecoration(color: BRIGHT_RED, borderRadius: BorderRadius.circular(50)),
                                                              child: Text("Itineraire", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                                                            ),
                                                          ),
                      ),
                    ],
                  )
                ],
              )
            
            ],
          ),
        ),
      ),
    );
  }
}
