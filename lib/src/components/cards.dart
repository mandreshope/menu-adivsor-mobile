import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/components/buttons.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/pages/food.dart';
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

class CategoryCard extends StatelessWidget {
  final String imageURL;

  final String name;

  final void Function() onPressed;

  const CategoryCard({
    Key key,
    @required this.imageURL,
    @required this.name,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: EdgeInsets.symmetric(horizontal: 3),
      child: AspectRatio(
        aspectRatio: 3 / 5,
        child: Card(
          elevation: 4.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10.0),
                  // decoration: BoxDecoration(
                  //   shape: BoxShape.circle,
                  //   border: Border.all(
                  //     color: DARK_BLUE,
                  //     width: 2,
                  //   ),
                  // ),
                  child: imageURL == null
                      ? SvgPicture.asset(
                          'assets/images/foodCategory-dietetic.svg',
                          height: 40,
                          color: DARK_BLUE,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: FadeInImage.assetNetwork(
                            placeholder: 'assets/images/loading.gif',
                            image: imageURL,
                            height: 40,
                          ),
                        ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  name,
                  style: TextStyle(
                    color: DARK_BLUE,
                    fontFamily: 'Golden Ranger',
                    fontSize: 18,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: DARK_BLUE,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_right,
                      color: Colors.white,
                    ),
                  ),
                  onTap: onPressed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FoodCard extends StatefulWidget {
  final Food food;
  final bool minified;
  final String imageTag;

  const FoodCard({
    Key key,
    @required this.food,
    this.minified = false,
    this.imageTag,
  }) : super(key: key);

  @override
  _FoodCardState createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> {
  bool loadingRestaurantName = true;
  String restaurantName;
  Api api = Api.instance;

  @override
  void initState() {
    super.initState();

    api.getRestaurantName(id: widget.food.restaurant).then((res) {
      if (mounted)
        setState(() {
          restaurantName = res.replaceAll('"', '');
          loadingRestaurantName = false;
        });
    }).catchError((error) {
      restaurantName = AppLocalizations.of(context).translate('no_associated_restaurant');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.minified ? 340 : 300,
      child: AspectRatio(
        aspectRatio: widget.minified ? 2.5 : 1.5,
        child: Card(
          elevation: 4.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                RouteUtil.goTo(
                  context: context,
                  child: FoodPage(
                    food: widget.food,
                    imageTag: widget.imageTag,
                    restaurantName: restaurantName,
                  ),
                  routeName: foodRoute,
                );
              },
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 50,
                          child: Row(
                            children: [],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 30.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  widget.food.name,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                loadingRestaurantName
                                    ? SizedBox(
                                        height: 10,
                                        child: FittedBox(
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              CRIMSON,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Text(
                                        restaurantName ?? AppLocalizations.of(context).translate('no_associated_restaurant'),
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                if (widget.food.price != null && widget.food.price.amount != null) ...[
                                  SizedBox(height: 5),
                                  Text(
                                    "${widget.food.price.amount / 100}€",
                                    style: TextStyle(
                                      fontSize: 21,
                                      color: Colors.yellow[700],
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Consumer<BagContext>(
                              builder: (_, bagContext, __) => RawMaterialButton(
                                fillColor: DARK_BLUE,
                                padding: const EdgeInsets.all(15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(30),
                                    topRight: Radius.circular(30),
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  padding: const EdgeInsets.all(5.0),
                                  child: FaIcon(
                                    bagContext.contains(widget.food) ? FontAwesomeIcons.minus : FontAwesomeIcons.plus,
                                    size: 10,
                                  ),
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
                                            } else
                                              showDialog(
                                                context: context,
                                                builder: (_) => AddToBagDialog(
                                                  food: widget.food,
                                                ),
                                              );
                                          }
                                        : () {
                                            Fluttertoast.showToast(msg: 'Vous ne pouvez pas à la fois commander des articles sans prix et avec prix');
                                          },
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            // _renderNotes(food.ratings)
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 30,
                    top: 0,
                    bottom: 0,
                    child: Hero(
                      tag: widget.imageTag ?? 'foodImage${widget.food.id}',
                      child: widget.food.imageURL != null
                          ? FadeInImage.assetNetwork(
                              image: widget.food.imageURL,
                              placeholder: 'assets/images/loading.gif',
                              width: 100,
                            )
                          : Icon(
                              Icons.fastfood,
                              size: 60,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderNotes(double ratings) {
    return Row(
      children: [
        for (int i = 0; i < 5; i++)
          if (ratings - i > 0)
            if ((ratings - i) % 1 < 1)
              Icon(
                Icons.star_half,
                color: CRIMSON,
                size: 15,
              )
            else
              Icon(
                Icons.star,
                color: CRIMSON,
                size: 15,
              )
          else
            Icon(
              Icons.star_border,
              color: CRIMSON,
              size: 15,
            )
      ],
    );
  }
}

class RestaurantFoodCard extends StatefulWidget {
  final Food food;

  const RestaurantFoodCard({
    Key key,
    this.food,
  }) : super(key: key);

  @override
  _RestaurantFoodCardState createState() => _RestaurantFoodCardState();
}

class _RestaurantFoodCardState extends State<RestaurantFoodCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (!expanded)
          setState(() {
            expanded = true;
          });
        else {
          BagContext bagContext = Provider.of<BagContext>(
            context,
            listen: false,
          );
          if ((bagContext.itemCount == 0) ||
              (bagContext.contains(widget.food)) ||
              (bagContext.pricelessItems && widget.food.price.amount == null) ||
              (!bagContext.pricelessItems && widget.food.price.amount != null)) {
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
            } else
              showDialog(
                context: context,
                builder: (_) => AddToBagDialog(
                  food: widget.food,
                ),
              );
          } else {
            Fluttertoast.showToast(
              msg: AppLocalizations.of(context).translate('priceless_and_not_priceless_not_allowed'),
            );
          }
        }
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FadeInImage.assetNetwork(
                placeholder: 'assets/images/loading.gif',
                image: widget.food.imageURL,
                width: 50,
                height: 50,
                fit: BoxFit.contain,
                imageErrorBuilder: (_, __, ___) => Icon(
                  Icons.food_bank_outlined,
                ),
              ),
              SizedBox(
                width: 15.0,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.food.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      widget.food.description ?? AppLocalizations.of(context).translate('no_description'),
                    ),
                    if (widget.food.attributes.length > 0) ...[
                      SizedBox(
                        height: 5,
                      ),
                      Consumer<DataContext>(
                        builder: (_, dataContext, __) => Wrap(
                          spacing: expanded ? 5 : 0,
                          children: widget.food.attributes
                              .map(
                                (e) => FittedBox(
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        20,
                                      ),
                                    ),
                                    elevation: expanded ? 4.0 : 0.0,
                                    margin: EdgeInsets.zero,
                                    child: Padding(
                                      padding: expanded
                                          ? const EdgeInsets.all(
                                              8,
                                            )
                                          : const EdgeInsets.symmetric(
                                              vertical: 8,
                                              horizontal: 4,
                                            ),
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
                                                if (expanded)
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                              ],
                                              if (expanded)
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
                    ],
                  ],
                ),
              ),
              Text('${widget.food.price.amount / 100}€'),
            ],
          ),
        ),
      ),
    );
  }
}

class DrinkCard extends StatefulWidget {
  final Food food;

  const DrinkCard({
    Key key,
    this.food,
  }) : super(key: key);

  @override
  _DrinkCardState createState() => _DrinkCardState();
}

class _DrinkCardState extends State<DrinkCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Card(
        elevation: 2.0,
        margin: const EdgeInsets.all(10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              widget.food.imageURL != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(
                        widget.food.imageURL,
                      ),
                      onBackgroundImageError: (_, __) {},
                      backgroundColor: Colors.grey,
                      maxRadius: 20,
                    )
                  : Icon(
                      Icons.fastfood,
                    ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.food.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.food.price != null)
                      Text(
                        '${widget.food.price.amount / 100}€',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuCard extends StatelessWidget {
  final Menu menu;
  final String lang;

  const MenuCard({
    Key key,
    @required this.menu,
    @required this.lang,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                menu.imageURL != null
                    ? FadeInImage.assetNetwork(placeholder: 'assets/images/loading.gif', image: menu.imageURL, width: 40, height: 40, fit: BoxFit.contain)
                    : SizedBox(
                        width: 40,
                        height: 40,
                        child: Center(
                          child: Icon(
                            Icons.food_bank,
                          ),
                        ),
                      ),
                SizedBox(width: 5.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menu.name[lang],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        menu.description[lang],
                        style: TextStyle(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Column(),
          ],
        ),
      ),
    );
  }
}

class RestaurantCard extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantCard({
    Key key,
    @required this.restaurant,
  }) : super(key: key);

  @override
  _RestaurantCardState createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<RestaurantCard> {
  bool switchingFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      child: AspectRatio(
        aspectRatio: 1.5,
        child: Card(
          elevation: 4.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                RouteUtil.goTo(
                  context: context,
                  child: RestaurantPage(
                    restaurant: widget.restaurant.id,
                  ),
                  routeName: restaurantRoute,
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(
                                    widget.restaurant.name,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    AppLocalizations.of(context).translate(widget.restaurant.type),
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (Provider.of<AuthContext>(context).currentUser != null)
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Consumer<AuthContext>(
                                builder: (_, authContext, __) => SizedBox(
                                  height: 50,
                                  child: FittedBox(
                                    child: switchingFavorite
                                        ? Padding(
                                            padding: const EdgeInsets.all(30),
                                            child: CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                CRIMSON,
                                              ),
                                            ),
                                          )
                                        : IconButton(
                                            icon: Icon(
                                              authContext.currentUser?.favoriteRestaurants?.contains(widget.restaurant.id) ?? false ? Icons.favorite : Icons.favorite_border,
                                              color: CRIMSON,
                                            ),
                                            onPressed: () async {
                                              setState(() {
                                                switchingFavorite = true;
                                              });
                                              if (authContext.currentUser?.favoriteRestaurants?.contains(widget.restaurant.id) ?? false)
                                                await authContext.removeFromFavoriteRestaurants(
                                                  widget.restaurant,
                                                );
                                              else
                                                await authContext.addToFavoriteRestaurants(
                                                  widget.restaurant,
                                                );
                                              setState(() {
                                                switchingFavorite = false;
                                              });
                                            },
                                          ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    FadeInImage.assetNetwork(
                      image: widget.restaurant.imageURL,
                      placeholder: 'assets/images/loading.gif',
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BagItem extends StatelessWidget {
  final Food food;
  final int count;

  BagItem({
    Key key,
    @required this.food,
    @required this.count,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            food.imageURL != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(
                      food.imageURL,
                    ),
                    onBackgroundImageError: (_, __) {},
                    backgroundColor: Colors.grey,
                    maxRadius: 20,
                  )
                : Icon(
                    Icons.fastfood,
                  ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (food.price.amount != null)
                    Text(
                      '${food.price.amount / 100}€',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
              ),
              padding: const EdgeInsets.all(15.0),
              child: Text(
                '$count',
                style: TextStyle(
                  color: CRIMSON,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.edit,
                color: Colors.teal,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  child: AddToBagDialog(
                    food: food,
                  ),
                );
              },
            ),
            CircleButton(
              backgroundColor: CRIMSON,
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
              onPressed: () async {
                var result = await showDialog(
                  context: context,
                  child: ConfirmationDialog(
                    title: AppLocalizations.of(context).translate('remove_item_confirmation_title'),
                    content: AppLocalizations.of(context).translate('remove_item_confirmation_content'),
                  ),
                );

                if (result is bool && result) {
                  BagContext bagContext = Provider.of<BagContext>(context, listen: false);

                  bagContext.removeItem(food);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
