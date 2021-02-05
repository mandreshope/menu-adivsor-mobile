import 'package:flutter/material.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';

class DetailMenu extends StatefulWidget {
  Menu menu;
  DetailMenu({@required this.menu});


  @override
  _DetailMenuState createState() => _DetailMenuState();
}

class _DetailMenuState extends State<DetailMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        // backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left,
            color: Colors.white,
          ),
          onPressed: () => RouteUtil.goBack(context: context),
        ),
        centerTitle: true,
        title: TextTranslator(widget.menu.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _renderHeaderPicture(),
          ],
        ),
      ),
    );
  }


  Widget _renderHeaderPicture() => Stack(
    children: [
      Hero(
        tag: widget.menu.id,
        child: widget.menu.imageURL != null
            ? Image.network(
          widget.menu.imageURL,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.contain,
        )
            : Icon(
          Icons.fastfood,
          size: 250,
        ),
      ),
      Positioned.fill(
          bottom: 0,
          left: 0,
          child: Container(
            height: 50,
            width: double.infinity,
            // color: Colors.black.withAlpha(150),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 50,
                width: double.infinity,
                color: Colors.black.withAlpha(150),
                child: Center(
                  child: TextTranslator(
                    widget.menu.name,
                    style: TextStyle(
                        color:Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            ),

          ))
    ],
  );

}
