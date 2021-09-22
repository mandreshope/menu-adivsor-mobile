import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  static Future<BitmapDescriptor> createCustomMarkerBitmap(BuildContext context, String title) async {
    TextSpan span = new TextSpan(
      style: new TextStyle(
        color: Colors.white,
        fontSize: 35.0,
        fontWeight: FontWeight.bold,
      ),
      text: title,
    );

    TextPainter tp = new TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.text = TextSpan(
      text: title,
      style: TextStyle(
        fontSize: 35.0,
        color: Theme.of(context).colorScheme.secondary,
        letterSpacing: 1.0,
      ),
    );

    PictureRecorder recorder = new PictureRecorder();
    Canvas c = new Canvas(recorder);

    tp.layout();
    tp.paint(c, new Offset(20.0, 10.0));

    /* Do your painting of the custom icon here, including drawing text, shapes, etc. */

    Picture p = recorder.endRecording();
    ByteData pngBytes = await (await p.toImage(tp.width.toInt() + 40, tp.height.toInt() + 20)).toByteData(format: ImageByteFormat.png);

    Uint8List data = Uint8List.view(pngBytes.buffer);

    return BitmapDescriptor.fromBytes(data);
  }
}
