import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewPage extends StatelessWidget {
  final String tag;
  final String img;
  PhotoViewPage({Key key, this.tag, this.img}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
          body: Hero(
        child: PhotoView(
          maxScale: 2.0,
          minScale: 0.5,
          imageProvider: NetworkImage(img),
        ),
        tag: tag,
      ),
    );
  }
}