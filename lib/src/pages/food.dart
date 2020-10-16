import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/pages/restaurant.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/providers/DataContext.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:provider/provider.dart';

class FoodPage extends StatefulWidget {
  final Food food;
  final String imageTag;
  final String restaurantName;

  FoodPage({
    this.food,
    this.imageTag,
    this.restaurantName,
  });

  @override
  _FoodPageState createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  bool isInFavorite = false;
  bool showFavorite = true;
  Api api = Api.instance;
  bool loading = true;
  String restaurantName;
  bool switchingFavorite = false;

  @override
  void initState() {
    super.initState();

    api
        .getRestaurant(
      id: widget.food.restaurant,
      lang: Provider.of<SettingContext>(
        context,
        listen: false,
      ).languageCode,
    )
        .then((res) {
      if (!mounted) return;

      setState(() {
        restaurantName = res.name;
        loading = false;
      });
    }).catchError((error) {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translate('connection_error'),
      );
    });

    AuthContext authContext = Provider.of<AuthContext>(context, listen: false);
    if (authContext.currentUser == null) showFavorite = false;
    isInFavorite = authContext.currentUser != null &&
        authContext.currentUser.favoriteFoods.firstWhere(
              (element) => element == widget.food.id,
              orElse: () => null,
            ) !=
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
                if (widget.food.price != null && widget.food.price.amount != null) ...[
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
                ],
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    right: 100.0,
                  ),
                  child: Column(
                    crossAxisAlignment: loading ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).translate('product_of'),
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 5),
                      !loading
                          ? GestureDetector(
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
                                restaurantName ?? 'Aucun nom',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            )
                          : SizedBox(
                              height: 22,
                              child: FittedBox(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(CRIMSON),
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
                        widget.food.description ?? AppLocalizations.of(context).translate('no_description'),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 3 * MediaQuery.of(context).size.width / 7,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20.0,
                        ),
                        child: Text(
                          'Attributs',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      widget.food.attributes.length > 0
                          ? Consumer<DataContext>(
                              builder: (_, dataContext, __) => Padding(
                                padding: const EdgeInsets.only(
                                  left: 5.0,
                                ),
                                child: Wrap(
                                  spacing: 5,
                                  children: widget.food.attributes
                                      .map(
                                        (e) => FittedBox(
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            margin: EdgeInsets.zero,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Builder(
                                                builder: (_) {
                                                  var attribute = dataContext.attributes.firstWhere(
                                                    (element) => element['tag'] == e,
                                                    orElse: null,
                                                  );

                                                  return Row(
                                                    children: [
                                                      if (attribute != null) ...[
                                                        FadeInImage.assetNetwork(
                                                          placeholder: 'assets/images/loading.gif',
                                                          image: attribute['imageURL'],
                                                          height: 14,
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                      ],
                                                      Text(
                                                        attribute[Provider.of<SettingContext>(context).languageCode],
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(
                                left: 20.0,
                              ),
                              child: Text(
                                AppLocalizations.of(context).translate('no_attribute'),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.normal,
                                ),
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
                      if (showFavorite) ...[
                        FloatingActionButton(
                          onPressed: !switchingFavorite
                              ? () async {
                                  AuthContext authContext = Provider.of<AuthContext>(
                                    context,
                                    listen: false,
                                  );

                                  setState(() {
                                    switchingFavorite = true;
                                  });
                                  if (!isInFavorite)
                                    await authContext.addToFavoriteFoods(widget.food);
                                  else
                                    await authContext.removeFromFavoriteFoods(widget.food);
                                  setState(() {
                                    switchingFavorite = false;
                                    isInFavorite = !isInFavorite;
                                  });
                                  Fluttertoast.showToast(
                                    msg: AppLocalizations.of(context).translate(
                                      isInFavorite ? 'added_to_favorite' : 'removed_from_favorite',
                                    ),
                                  );
                                }
                              : null,
                          child: !switchingFavorite
                              ? Icon(
                                  isInFavorite ? Icons.favorite : Icons.favorite_border,
                                )
                              : SizedBox(
                                  width: 15,
                                  height: 15,
                                  child: FittedBox(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                      ],
                      Expanded(
                        child: Consumer<BagContext>(
                          builder: (_, bagContext, __) => RaisedButton(
                            padding: EdgeInsets.all(20),
                            color: bagContext.contains(widget.food) ? Colors.teal : CRIMSON,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            onPressed:
                                (bagContext.itemCount == 0) || (bagContext.pricelessItems && widget.food.price.amount == null) || (!bagContext.pricelessItems && widget.food.price.amount != null)
                                    ? () async {
                                        if (bagContext.contains(widget.food)) {
                                          var result = await showDialog(
                                            context: context,
                                            builder: (_) => ConfirmationDialog(
                                              title: AppLocalizations.of(context).translate('confirm_remove_from_cart_title'),
                                              content: AppLocalizations.of(context).translate('confirm_remove_from_cart_content'),
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
                                      }
                                    : null,
                            child: Text(
                              bagContext.contains(widget.food) ? AppLocalizations.of(context).translate('remove_from_cart') : AppLocalizations.of(context).translate("add_to_cart"),
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
                                  tag: widget.imageTag ?? 'foodImage${widget.food.id}',
                                  child: widget.food.imageURL != null
                                      ? Image.network(
                                          widget.food.imageURL,
                                          width: MediaQuery.of(context).size.width - 100,
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
                          width: 4 * MediaQuery.of(context).size.width / 7,
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
