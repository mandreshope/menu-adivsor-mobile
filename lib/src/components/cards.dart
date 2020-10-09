import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/components/buttons.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/pages/food.dart';
import 'package:menu_advisor/src/pages/restaurant.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: DARK_BLUE,
                      width: 2,
                    ),
                  ),
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

class FoodCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      width: minified ? 340 : 300,
      child: AspectRatio(
        aspectRatio: minified ? 2.5 : 1.5,
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
                    food: food,
                    imageTag: imageTag,
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
                                  food.name,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  food.restaurant?.name ??
                                      AppLocalizations.of(context).translate(
                                          'no_associated_restaurant'),
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "${food.price.amount / 100}€",
                                  style: TextStyle(
                                    fontSize: 21,
                                    color: Colors.yellow[700],
                                  ),
                                ),
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
                                    bagContext.contains(food)
                                        ? FontAwesomeIcons.minus
                                        : FontAwesomeIcons.plus,
                                    size: 10,
                                  ),
                                ),
                                onPressed: () async {
                                  if (bagContext.contains(food)) {
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
                                      bagContext.removeItem(food);
                                    }
                                  } else
                                    showDialog(
                                      context: context,
                                      builder: (_) => AddToBagDialog(
                                        food: food,
                                      ),
                                    );
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
                      tag: imageTag ?? 'foodImage${food.id}',
                      child: food.imageURL != null
                          ? FadeInImage.assetNetwork(
                              image: food.imageURL,
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

class MenuCard extends StatelessWidget {
  final Menu menu;

  const MenuCard({
    Key key,
    @required this.menu,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 5,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                width: MediaQuery.of(context).size.width / 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(
                      menu.imageURL,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 5.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantCard({
    Key key,
    @required this.restaurant,
  }) : super(key: key);

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
                    restaurant: restaurant,
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
                                    restaurant.name,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    AppLocalizations.of(context)
                                        .translate(restaurant.type),
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Consumer<AuthContext>(
                              builder: (_, authContext, __) => IconButton(
                                icon: Icon(
                                  authContext.currentUser?.favoriteRestaurants
                                                  ?.firstWhere(
                                                (element) =>
                                                    element.id == restaurant.id,
                                                orElse: () => null,
                                              ) !=
                                              null ??
                                          false
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: CRIMSON,
                                ),
                                onPressed: () {},
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    FadeInImage.assetNetwork(
                      image: restaurant.imageURL,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Text('$count'),
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
                    title: AppLocalizations.of(context)
                        .translate('remove_item_confirmation_title'),
                    content: AppLocalizations.of(context)
                        .translate('remove_item_confirmation_content'),
                  ),
                );

                if (result is bool && result) {
                  BagContext bagContext =
                      Provider.of<BagContext>(context, listen: false);

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
