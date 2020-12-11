import 'package:url_launcher/url_launcher.dart';

class MapUtils {

  MapUtils._();

  static Future<void> openMap(double latitude, double longitude, double destinationLat, double destinationLong) async {
    //http://maps.google.com/maps?f=d&hl=en&saddr=43.7967876,-79.533161&daddr=43.5184049,-79.8473993
    String googleUrl = 'http://maps.google.com/maps?f=d&hl=en&saddr=$latitude,$longitude&daddr=$destinationLat,$destinationLong';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }
}