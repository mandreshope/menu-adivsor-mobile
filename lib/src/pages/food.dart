import 'package:flutter/material.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';

class FoodPage extends StatefulWidget {
  final Food food;

  FoodPage({
    this.food,
  });

  @override
  _FoodPageState createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  bool isInFavorite = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left,
            color: Colors.black,
          ),
          onPressed: () => RouteUtil.goBack(context: context),
        ),
      ),
      body: Container(
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    right: 100.0,
                  ),
                  child: Text(
                    "Pizza de qualité",
                    style: TextStyle(
                      fontFamily: 'Soft Elegance',
                      fontSize: 50,
                      fontWeight: FontWeight.w400,
                      color: DARK_BLUE,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    right: 100.0,
                  ),
                  child: Text(
                    '${widget.food.price}€',
                    style: TextStyle(
                      fontSize: 40,
                      color: BRIGHT_RED,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    right: 100.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).translate('product_of'),
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        widget.food.restaurant.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    right: 200.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).translate('description'),
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        widget.food.description ??
                            AppLocalizations.of(context)
                                .translate('no_description'),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Align(
                  alignment: Alignment.center,
                  child: FlatButton(
                    child: Text(
                      AppLocalizations.of(context).translate("your_feedback"),
                      style: TextStyle(
                        color: Colors.blue[300],
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 20,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            isInFavorite = !isInFavorite;
                          });
                        },
                        child: Icon(
                          isInFavorite ? Icons.favorite : Icons.favorite_border,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: RaisedButton(
                          padding: EdgeInsets.all(20),
                          color: CRIMSON,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          onPressed: () {},
                          child: Text(
                            AppLocalizations.of(context)
                                .translate("add_to_bag"),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: MediaQuery.of(context).size.height / 2 - 200,
              right: -50,
              child: widget.food.imageURL != null
                  ? Image.network(
                      widget.food.imageURL,
                      height: 250,
                    )
                  : Image.asset(
                      "assets/images/pizza.png",
                      height: 250,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
