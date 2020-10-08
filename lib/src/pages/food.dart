import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/components/buttons.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/pages/restaurant.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:provider/provider.dart';

class FoodPage extends StatefulWidget {
  final Food food;
  final String imageTag;

  FoodPage({
    this.food,
    this.imageTag,
  });

  @override
  _FoodPageState createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  bool isInFavorite = false;

  @override
  void initState() {
    super.initState();

    AuthContext authContext = Provider.of<AuthContext>(context, listen: false);
    isInFavorite = authContext.currentUser.favoriteFoods.firstWhere(
            (element) => element.id == widget.food.id,
            orElse: () => null) !=
        null;
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
                    widget.food.name,
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
                    '${widget.food.price.amount / 100}€',
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
                      GestureDetector(
                        onTap: () {
                          if (widget.food.restaurant != null)
                            RouteUtil.goTo(
                              context: context,
                              child: RestaurantPage(
                                restaurant: widget.food.restaurant,
                              ),
                              routeName: restaurantRoute,
                            );
                        },
                        child: Text(
                          widget.food.restaurant?.name ?? 'Aucun nom',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
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
                    onPressed: () {},
                    child: Text(
                      AppLocalizations.of(context).translate("your_feedback"),
                      style: TextStyle(
                        color: Colors.blue[300],
                        fontSize: 20,
                        decoration: TextDecoration.underline,
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
                          Fluttertoast.showToast(
                            msg: AppLocalizations.of(context).translate(
                              isInFavorite
                                  ? 'added_to_favorite'
                                  : 'removed_from_favorite',
                            ),
                          );
                        },
                        child: Icon(
                          isInFavorite ? Icons.favorite : Icons.favorite_border,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Consumer<BagContext>(
                          builder: (_, bagContext, __) => RaisedButton(
                            padding: EdgeInsets.all(20),
                            color: bagContext.contains(widget.food)
                                ? Colors.teal
                                : CRIMSON,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            onPressed: () async {
                              if (bagContext.contains(widget.food)) {
                                var result = await showDialog(
                                  context: context,
                                  builder: (_) => ConfirmationDialog(
                                    title: AppLocalizations.of(context)
                                        .translate(
                                            'confirm_remove_from_cart_title'),
                                    content: AppLocalizations.of(context)
                                        .translate(
                                            'confirm_remove_from_cart_content'),
                                  ),
                                );

                                if (result is bool && result) {
                                  bagContext.removeItem(widget.food);
                                }
                              } else {
                                bool result = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AddToBagDialog(
                                    food: widget.food,
                                  ),
                                );
                                if (result is bool && result) {}
                              }
                            },
                            child: Text(
                              bagContext.contains(widget.food)
                                  ? AppLocalizations.of(context)
                                      .translate('remove_from_cart')
                                  : AppLocalizations.of(context)
                                      .translate("add_to_cart"),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
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
              top: MediaQuery.of(context).size.height / 2 - 150,
              right: -50,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (BuildContext context) {
                        return new Scaffold(
                          appBar: AppBar(
                            iconTheme: IconThemeData(
                              color: Colors.black,
                            ),
                            title: Text(
                              widget.food.name,
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            elevation: 0.0,
                            backgroundColor: Colors.transparent,
                          ),
                          body: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              child: Center(
                                child: Hero(
                                  tag: widget.imageTag ??
                                      'foodImage${widget.food.id}',
                                  child: widget.food.imageURL != null
                                      ? Image.network(
                                          widget.food.imageURL,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              100,
                                        )
                                      : Icon(
                                          Icons.fastfood,
                                          size: 250,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                child: Hero(
                  tag: widget.imageTag ?? 'foodImage${widget.food.id}',
                  child: widget.food.imageURL != null
                      ? Image.network(
                          widget.food.imageURL,
                          width: 250,
                        )
                      : Icon(
                          Icons.fastfood,
                          size: 250,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddToBagDialog extends StatefulWidget {
  final Food food;

  const AddToBagDialog({
    Key key,
    this.food,
  }) : super(key: key);

  @override
  _AddToBagDialogState createState() => _AddToBagDialogState();
}

class _AddToBagDialogState extends State<AddToBagDialog> {
  int itemCount = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 25.0,
                left: 25.0,
                right: 25.0,
              ),
              child: Text(
                AppLocalizations.of(context).translate('add_to_cart'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Text(
                AppLocalizations.of(context).translate('item_count'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                children: [
                  CircleButton(
                    backgroundColor: Colors.transparent,
                    border: Border.all(
                      width: 1,
                      color: Colors.grey,
                    ),
                    child: FaIcon(
                      FontAwesomeIcons.minus,
                      color: Colors.black,
                    ),
                    onPressed: itemCount > 1
                        ? () {
                            setState(() {
                              itemCount--;
                            });
                          }
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      itemCount.toString(),
                    ),
                  ),
                  CircleButton(
                    backgroundColor: Colors.transparent,
                    border: Border.all(
                      width: 1,
                      color: Colors.grey,
                    ),
                    child: FaIcon(
                      FontAwesomeIcons.plus,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        itemCount++;
                      });
                    },
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 10.0,
                  bottom: 10.0,
                ),
                child: RaisedButton(
                  color: CRIMSON,
                  child: Text(
                    AppLocalizations.of(context).translate('add'),
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    BagContext bagContext =
                        Provider.of<BagContext>(context, listen: false);

                    bagContext.addItem(widget.food, itemCount);
                    Navigator.of(context).pop(true);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
