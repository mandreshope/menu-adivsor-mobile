import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/components/pointer_paint.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models/models.dart';
import 'package:menu_advisor/src/pages/detail_menu.dart';
import 'package:menu_advisor/src/pages/food.dart';
import 'package:menu_advisor/src/pages/photo_view.dart';
import 'package:menu_advisor/src/pages/restaurant.dart';
import 'package:menu_advisor/src/pages/summary.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/providers/DataContext.dart';
import 'package:menu_advisor/src/providers/MenuContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/button_item_count_widget.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';
import 'package:menu_advisor/src/utils/extensions.dart';

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
      width: 110,
      margin: EdgeInsets.symmetric(horizontal: 3),
      child: AspectRatio(
        aspectRatio: 2.8 / 5,
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
                  child: imageURL == null
                      ? SvgPicture.asset(
                          'assets/images/foodCategory-dietetic.svg',
                          height: 40,
                          color: DARK_BLUE,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: FadeInImage.assetNetwork(
                            placeholder: 'assets/images/loading.gif',
                            image: imageURL,
                            imageErrorBuilder: (_, __, ___) => Container(
                              width: 70,
                              height: 70,
                              color: Colors.white,
                            ),
                            height: 70,
                            width: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                  // ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextTranslator(
                  name,
                  isAutoSizeText: true,
                  style: TextStyle(
                    color: DARK_BLUE,
                    fontFamily: 'Golden Ranger',
                    fontSize: 18,
                  ),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 15,
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
  final bool withPrice;

  final bool showButton;

  const FoodCard({Key key, @required this.food, this.minified = false, this.imageTag, this.showButton = false, this.withPrice = true}) : super(key: key);

  @override
  _FoodCardState createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> {
  bool loadingRestaurantName = true;
  String restaurantName;
  Api api = Api.instance;
  bool loading = true;
  bool switchingFavorite = false;
  bool showFavorite = false;
  bool isInFavorite = false;
  // CartContext _cartContext;

  @override
  void initState() {
    super.initState();
    var restaurantId = widget.food.restaurant is String ? widget.food.restaurant : widget.food.restaurant['_id'];
    api.getRestaurantName(id: restaurantId).then((res) {
      if (mounted)
        setState(() {
          restaurantName = res.replaceAll('"', '');
          loadingRestaurantName = false;
        });
    }).catchError((error) {
      restaurantName = AppLocalizations.of(context).translate('no_associated_restaurant');
    });

    AuthContext authContext = Provider.of<AuthContext>(context, listen: false);
    if (authContext.currentUser == null)
      showFavorite = false;
    else
      showFavorite = true;
    isInFavorite = authContext.currentUser != null &&
        authContext.currentUser.favoriteFoods.firstWhere(
              (element) => element == widget.food.id,
              orElse: () => null,
            ) !=
            null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.showButton
          ? MediaQuery.of(context).size.width - 50
          : widget.minified
              ? 300
              : 400,
      child: AspectRatio(
        aspectRatio: widget.showButton
            ? 2.5
            : widget.minified
                ? 1.9
                : 2.5,
        child: Card(
          elevation: 4.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.showButton ? 10 : 30),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: widget.food.isAvailable == true
                  ? () {
                      RouteUtil.goTo(
                        context: context,
                        child: FoodPage(
                          food: widget.food,
                          restaurantName: restaurantName,
                        ),
                        routeName: foodRoute,
                      );
                    }
                  : null,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    bottom: widget.showButton ? 20 : 0,
                    left: widget.showButton ? 110 : 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          // key: ,
                          width: widget.minified ? (MediaQuery.of(context).size.width - 288) : (MediaQuery.of(context).size.width - 188),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 20,
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
                                      TextTranslator(
                                        widget.food.name ?? "",
                                        maxLines: 1,
                                        isAutoSizeText: true,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      TextTranslator(
                                        widget.food.description ?? "",
                                        maxLines: 1,
                                        isAutoSizeText: true,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Wrap(
                                        children: [
                                          ...widget.food.attributes
                                              .map(
                                                (attribute) => FittedBox(
                                                  child: Card(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    margin: EdgeInsets.zero,
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8),
                                                      child: Builder(
                                                        builder: (_) {
                                                          return Row(
                                                            children: [
                                                              if (widget.food.attributes != null)
                                                                //for (var attribute in dataContext.attributes)
                                                                ...[
                                                                FadeInImage.assetNetwork(
                                                                  placeholder: 'assets/images/loading.gif',
                                                                  image: attribute.imageURL,
                                                                  height: 14,
                                                                  imageErrorBuilder: (_, __, ___) => Container(
                                                                    width: 14,
                                                                    height: 14,
                                                                    color: Colors.white,
                                                                  ),
                                                                ),
                                                              ] else
                                                                TextTranslator("")
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),

                                          /// alergen
                                          ...widget.food.allergens
                                              .map(
                                                (attribute) => FittedBox(
                                                  child: Card(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    margin: EdgeInsets.zero,
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8),
                                                      child: Builder(
                                                        builder: (_) {
                                                          return Row(
                                                            children: [
                                                              if (widget.food.allergens != null)
                                                                //for (var attribute in dataContext.attributes)
                                                                ...[
                                                                FadeInImage.assetNetwork(
                                                                  placeholder: 'assets/images/loading.gif',
                                                                  image: attribute?.imageURL ?? "",
                                                                  height: 14,
                                                                  imageErrorBuilder: (_, __, ___) => Container(
                                                                    width: 14,
                                                                    height: 14,
                                                                    color: Colors.white,
                                                                  ),
                                                                ),
                                                              ] else
                                                                TextTranslator("")
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                // color:Colors.black,
                                width: MediaQuery.of(context).size.width - 170,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: widget.showButton ? MainAxisAlignment.end : MainAxisAlignment.start,
                                  children: [
                                    Consumer<CartContext>(
                                      builder: (_, cartContext, __) {
                                        if (widget.showButton)
                                          return ButtonItemCountWidget(
                                            widget.food,
                                            isContains: cartContext.contains(widget.food),
                                            itemCount: cartContext.getCount(widget.food),
                                            onAdded: (value) {
                                              cartContext.addItem(widget.food, value, true);
                                            },
                                            onRemoved: (value) {
                                              value == 0 ? cartContext.removeItem(widget.food) : cartContext.addItem(widget.food, value, false);
                                            },
                                          );
                                        return RawMaterialButton(
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
                                              color: widget.food.isPopular ? Colors.transparent : Colors.white,
                                            ),
                                            padding: widget.food.isPopular ? EdgeInsets.zero : EdgeInsets.all(5.0),
                                            child: FaIcon(
                                              widget.food.isPopular
                                                  ? Icons.visibility
                                                  : cartContext.contains(widget.food)
                                                      ? FontAwesomeIcons.minus
                                                      : FontAwesomeIcons.plus,
                                              size: widget.food.isPopular ? 22 : 10,
                                              color: widget.food.isPopular ? Colors.white : Colors.black,
                                            ),
                                          ),
                                          onPressed: widget.food.isPopular
                                              ? () => RouteUtil.goTo(
                                                    context: context,
                                                    child: FoodPage(
                                                      food: widget.food,
                                                      restaurantName: restaurantName,
                                                    ),
                                                    routeName: foodRoute,
                                                  )
                                              : !cartContext.contains(widget.food)
                                                  ? () => RouteUtil.goTo(
                                                        context: context,
                                                        child: FoodPage(
                                                          food: widget.food,
                                                          restaurantName: restaurantName,
                                                        ),
                                                        routeName: foodRoute,
                                                      )
                                                  : (cartContext.itemCount == 0) ||
                                                          (cartContext.pricelessItems && widget.food.price?.amount == null) ||
                                                          (!cartContext.pricelessItems && widget.food.price?.amount != null)
                                                      ? () async {
                                                          if (cartContext.contains(widget.food)) {
                                                            var result = await showDialog(
                                                              context: context,
                                                              builder: (_) => ConfirmationDialog(
                                                                title: AppLocalizations.of(context).translate('confirm_remove_from_cart_title'),
                                                                content: AppLocalizations.of(context).translate('confirm_remove_from_cart_content'),
                                                              ),
                                                            );

                                                            if (result is bool && result) {
                                                              cartContext.removeAllFood(widget.food);

                                                              // RouteUtil.goBack(
                                                              //     context: context);
                                                            }
                                                          } else if (!cartContext.hasSameOriginAsInBag(widget.food)) {
                                                            Fluttertoast.showToast(
                                                              msg: AppLocalizations.of(context).translate('from_different_origin_not_allowed'),
                                                            );
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
                                        );
                                      },
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    // _renderNotes(food.ratings)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Stack(
                          children: [
                            Container(
                              // child: Hero(
                              // tag: widget.imageTag ?? 'foodImage${widget.food.id}',
                              child: widget.food.imageURL != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(widget.showButton ? 10 : 30),
                                        topRight: Radius.circular(
                                          widget.showButton ? 10 : 30,
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          FadeInImage.assetNetwork(
                                            image: widget.food.imageURL,
                                            placeholder: 'assets/images/loading.gif',
                                            imageErrorBuilder: (_, o, s) {
                                              return Container(
                                                width: 100,
                                                height: double.infinity,
                                                color: Colors.white,
                                              );
                                            },
                                            width: 100,
                                            height: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                          if (widget.food.imageNotContractual == true && widget.food.isAvailable == true) ...[
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              left: 0,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.only(bottomRight: Radius.circular(widget.showButton ? 10 : 30)),
                                                child: Container(
                                                  width: double.infinity,
                                                  color: Colors.black.withOpacity(0.5),
                                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                                  child: Center(
                                                    child: TextTranslator(
                                                      AppLocalizations.of(context).translate("non_contractual_photo"),
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ] else if (widget.food.isAvailable == false) ...[
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              left: 0,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.only(bottomRight: Radius.circular(widget.showButton ? 10 : 30)),
                                                child: Container(
                                                  width: double.infinity,
                                                  color: Colors.black.withOpacity(0.5),
                                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                                  child: Center(
                                                    child: TextTranslator(
                                                      AppLocalizations.of(context).translate("non_disponible"),
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ]
                                        ],
                                      ),
                                    )
                                  : Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.white,
                                    ),
                              // ),
                            ),
                            Positioned(
                              right: 0,
                              child: Visibility(
                                visible: showFavorite,
                                child: Container(
                                  margin: EdgeInsets.all(10),
                                  height: 40,
                                  width: 40,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                                      backgroundColor: MaterialStateProperty.all(CRIMSON),
                                      shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.circular(60)),
                                      ),
                                    ),
                                    onPressed: !switchingFavorite
                                        ? () async {
                                            AuthContext authContext = Provider.of<AuthContext>(
                                              context,
                                              listen: false,
                                            );

                                            setState(() {
                                              switchingFavorite = true;
                                            });
                                            if (!isInFavorite) {
                                              await authContext.addToFavoriteFoods(widget.food);
                                            } else {
                                              await authContext.removeFromFavoriteFoods(widget.food);
                                            }

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
                                    child: Center(
                                      child: !switchingFavorite
                                          ? Icon(
                                              isInFavorite ? Icons.favorite : Icons.favorite_border,
                                              color: Colors.white,
                                              size: 18,
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
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
  final bool withPrice;

  const RestaurantFoodCard({Key key, this.food, this.withPrice}) : super(key: key);

  @override
  _RestaurantFoodCardState createState() => _RestaurantFoodCardState();
}

class _RestaurantFoodCardState extends State<RestaurantFoodCard> {
  bool expanded = false;

  bool loading = true;
  bool showOptions = false;

  List<Option> options = [];

  CartContext _cartContext;

  @override
  void initState() {
    super.initState();

    _cartContext = Provider.of<CartContext>(context, listen: false);
    if (_cartContext.contains(widget.food) && widget.food.options.length > 0) {
      showOptions = false;
    }
    if (widget.food.options.length == 0) showOptions = true;

    options = widget.food.options;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.food.isAvailable == true
          ? () async {
              RouteUtil.goTo(
                context: context,
                child: Material(
                  child: FoodPage(
                    food: widget.food,
                    fromRestaurant: true,
                  ),
                ),
                routeName: foodRoute,
              );
              //}
            }
          : null,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.only(
            right: 15.0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), topLeft: Radius.circular(5)),
                child: Stack(
                  children: [
                    FadeInImage.assetNetwork(
                      placeholder: 'assets/images/loading.gif',
                      image: widget.food.imageURL,
                      width: 95,
                      height: 100,
                      fit: BoxFit.cover,
                      imageErrorBuilder: (_, __, ___) => Container(
                        width: 95,
                        height: 100,
                        color: Colors.white,
                      ),
                    ),
                    if (widget.food.imageNotContractual == true && widget.food.isAvailable == true) ...[
                      Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: Container(
                          height: 20,
                          color: Colors.black.withOpacity(0.5),
                          child: Center(
                            child: TextTranslator(
                              AppLocalizations.of(context).translate("non_contractual_photo"),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                    ] else if (widget.food.isAvailable == false) ...[
                      Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: Container(
                          height: 20,
                          color: Colors.black.withOpacity(0.5),
                          child: Center(
                            child: TextTranslator(
                              AppLocalizations.of(context).translate("non_disponible"),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                    ]
                  ],
                ),
              ),

              // ),
              SizedBox(
                width: 15.0,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    TextTranslator(
                      widget.food.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    TextTranslator(
                      widget.food.description ?? "",
                    ),
                    if (widget.food.attributes.length > 0) ...[
                      SizedBox(
                        height: 5,
                      ),
                      Consumer<DataContext>(
                          builder: (_, dataContext, __) => InkWell(
                                onTap: () {
                                  setState(() {
                                    expanded = true;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.only(bottom: expanded ? 20 : 0),
                                  height: expanded ? 46 : 20,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(children: [
                                      ...widget.food.attributes
                                          .map(
                                            (attribute) => Padding(
                                              padding: expanded ? const EdgeInsets.symmetric(horizontal: 5, vertical: 0.8) : const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                                              child: FittedBox(
                                                child: Card(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(
                                                      20,
                                                    ),
                                                  ),
                                                  elevation: expanded ? 0.5 : 0,
                                                  margin: EdgeInsets.zero,
                                                  child: Padding(
                                                    padding: expanded
                                                        ? const EdgeInsets.all(
                                                            8,
                                                          )
                                                        : const EdgeInsets.symmetric(
                                                            vertical: 1,
                                                            horizontal: 1,
                                                          ),
                                                    child: Builder(
                                                      builder: (_) {
                                                        return Row(
                                                          children: [
                                                            // for (var attribute in dataContext.attributes)
                                                            ...[
                                                              FadeInImage.assetNetwork(
                                                                placeholder: 'assets/images/loading.gif',
                                                                image: attribute.imageURL,
                                                                height: 14,
                                                                imageErrorBuilder: (_, __, ___) => Container(
                                                                  width: 14,
                                                                  height: 14,
                                                                  color: Colors.white,
                                                                ),
                                                              ),
                                                              if (expanded)
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                              if (expanded)
                                                                TextTranslator(
                                                                  attribute.locales,
                                                                ),
                                                            ]
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),

                                      ///alergens
                                      ...widget.food.allergens
                                          .map(
                                            (attribute) => Padding(
                                              padding: expanded ? const EdgeInsets.symmetric(horizontal: 5, vertical: 0.8) : const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                                              child: FittedBox(
                                                child: Card(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(
                                                      20,
                                                    ),
                                                  ),
                                                  elevation: expanded ? 0.5 : 0,
                                                  margin: EdgeInsets.zero,
                                                  child: Padding(
                                                    padding: expanded
                                                        ? const EdgeInsets.all(
                                                            8,
                                                          )
                                                        : const EdgeInsets.symmetric(
                                                            vertical: 1,
                                                            horizontal: 1,
                                                          ),
                                                    child: Builder(
                                                      builder: (_) {
                                                        return Row(
                                                          children: [
                                                            // for (var attribute in dataContext.attributes)
                                                            ...[
                                                              FadeInImage.assetNetwork(
                                                                placeholder: 'assets/images/loading.gif',
                                                                image: attribute.imageURL,
                                                                height: 14,
                                                                imageErrorBuilder: (_, __, ___) => Container(
                                                                  width: 14,
                                                                  height: 14,
                                                                  color: Colors.white,
                                                                ),
                                                              ),
                                                              if (expanded)
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                              if (expanded)
                                                                TextTranslator(
                                                                  attribute.locales,
                                                                ),
                                                            ]
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ]),
                                  ),
                                ),
                              )
                          // Container()
                          ),
                      // ),
                    ],
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  !_cartContext.withPrice
                      ? Text("")
                      : widget.food.price?.amount == null
                          ? Text("")
                          : Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                '${widget.food.price.amount / 100}€',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                  Consumer<CartContext>(builder: (_, cart, w) {
                    return cart.contains(widget.food)
                        ? Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(shape: BoxShape.circle, color: CRIMSON),
                            child: Text("${cart.getFoodCount(widget.food)}x", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          )
                        : Container();
                  }),
                  // Spacer()
                ],
              )
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
    return Consumer<CartContext>(
      builder: (_, cartContext, __) => InkWell(
        onTap: () async {
          if (cartContext.itemCount != 0) {
            if (!cartContext.hasSamePricingAsInBag(widget.food))
              return Fluttertoast.showToast(
                msg: AppLocalizations.of(context).translate('priceless_and_not_priceless_not_allowed'),
              );
            if (!cartContext.hasSameOriginAsInBag(widget.food))
              return Fluttertoast.showToast(
                msg: AppLocalizations.of(context).translate('from_different_origin_not_allowed'),
              );
          }
          RouteUtil.goTo(
            context: context,
            child: FoodPage(
              food: widget.food,
            ),
            routeName: foodRoute,
          );
        },
        child: Card(
          elevation: 2.0,
          margin: const EdgeInsets.all(10.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /* Hero(
                      tag: widget.food.id,
                      child: */
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
                    // ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextTranslator(
                            widget.food.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.food.price != null && widget.food.price?.amount != null)
                            Text(
                              !cartContext.withPrice ? "" : '${widget.food.price.amount / 100}€',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    Consumer<CartContext>(builder: (_, cart, w) {
                      return cart.contains(widget.food)
                          ? Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(shape: BoxShape.circle, color: CRIMSON),
                              child: Text("${cart.getFoodCount(widget.food)}x", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            )
                          : Container();
                    }),
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
  final String restaurant;
  final int count = 0;
  final bool withPrice;

  MenuCard({
    Key key,
    @required this.menu,
    @required this.lang,
    this.restaurant,
    this.withPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MenuContext _controller = Provider.of<MenuContext>(context, listen: false);
    if (restaurant != null) menu.restaurant = restaurant;
    // menu.foodsGrouped = menu.foods ?? [];

    return InkWell(
      onTap: () {
        RouteUtil.goTo(context: context, child: DetailMenu(menu: Menu.clone(menu)), routeName: null);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 4.0,
        margin: EdgeInsets.symmetric(horizontal: 15),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 5.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextTranslator(
                        menu.name ?? "",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      _renderListPlat(context, _controller),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(top: 3),
                      child: CustomPaint(
                        painter: PointPainter(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // SizedBox(height: 5,),
                      TextTranslator(
                        !Provider.of<CartContext>(context).withPrice || menu.type == MenuType.priceless.value || menu.type == MenuType.per_food.value || menu.price?.amount == null
                            ? " "
                            : "${menu.price.amount / 100 ?? ""}€",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: CRIMSON),
                      ),
                      Consumer<CartContext>(builder: (_, cart, w) {
                        return cart.contains(menu)
                            ? Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(shape: BoxShape.circle, color: CRIMSON),
                                child: Text("${cart.getFoodCount(menu)}x", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              )
                            : Container();
                      }),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderListPlat(context, controller) {
    String name = "";
    for (var entry in menu.foods) name += entry.title + " + ";
    return TextTranslator(
      name.isEmpty ? name : name.substring(0, name.length - 2),
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    );
  }
}

class RestaurantCard extends StatefulWidget {
  final Restaurant restaurant;
  final bool fromHome;
  final bool withPrice;

  const RestaurantCard({Key key, @required this.restaurant, this.fromHome = false, this.withPrice = true}) : super(key: key);

  @override
  _RestaurantCardState createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<RestaurantCard> {
  bool switchingFavorite = false;
  bool isInFavorite = false;

  @override
  void initState() {
    super.initState();
    AuthContext authContext = Provider.of<AuthContext>(context, listen: false);
    isInFavorite = authContext.currentUser != null &&
        authContext.currentUser.favoriteRestaurants.firstWhere(
              (element) => element == widget.restaurant.id,
              orElse: () => null,
            ) !=
            null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.fromHome ? 300 : MediaQuery.of(context).size.width - 50,
      child: AspectRatio(
        aspectRatio: widget.fromHome ? 2.5 : 3.5,
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            TextTranslator(
                              widget.restaurant.name ?? "",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            TextTranslator(
                              widget.restaurant.description,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Stack(
                      children: [
                        FadeInImage.assetNetwork(
                          image: widget.restaurant.logo,
                          placeholder: 'assets/images/loading.gif',
                          width: 120,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          imageErrorBuilder: (_, __, ___) => Container(
                            width: 125,
                            height: 70,
                            color: Colors.white,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: Visibility(
                            visible: Provider.of<AuthContext>(context).currentUser != null,
                            child: Consumer<AuthContext>(
                              builder: (_, authContext, __) => Container(
                                margin: EdgeInsets.all(10),
                                height: 40,
                                width: 40,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                                    backgroundColor: MaterialStateProperty.all(CRIMSON),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.circular(60)),
                                    ),
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      switchingFavorite = true;
                                    });
                                    if (isInFavorite)
                                      await authContext.removeFromFavoriteRestaurants(
                                        widget.restaurant,
                                      );
                                    else
                                      await authContext.addToFavoriteRestaurants(
                                        widget.restaurant,
                                      );
                                    setState(() {
                                      switchingFavorite = false;
                                      isInFavorite = !isInFavorite;
                                    });
                                    Fluttertoast.showToast(
                                      msg: AppLocalizations.of(context).translate(
                                        isInFavorite ? 'added_to_favorite' : 'removed_from_favorite',
                                      ),
                                    );
                                  },
                                  child: Center(
                                    child: !switchingFavorite
                                        ? Icon(
                                            authContext.currentUser?.favoriteRestaurants?.contains(widget.restaurant.id) ?? false ? Icons.favorite : Icons.favorite_border,
                                            color: Colors.white,
                                            size: 18,
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
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // ),
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

class BagItem extends StatefulWidget {
  final dynamic food;
  int count;
  bool activeDelete;
  String imageTag;
  bool withPrice;
  int position;

  BagItem({Key key, @required this.food, this.position, @required this.count, this.activeDelete = true, this.imageTag, this.withPrice = true}) : super(key: key);

  @override
  _BagItemState createState() => _BagItemState();
}

class _BagItemState extends State<BagItem> {
  CartContext _cartContext;

  bool hasMessage = false;
  bool expand = false;

  @override
  Widget build(BuildContext context) {
    _cartContext = Provider.of<CartContext>(context, listen: false);
    return InkWell(
      onTap: () {
        /*RouteUtil.goTo(
          context: context,
          child: Material(
            child: FoodPage(
              food: food,
              imageTag: food.id,
              restaurantName: "restaurantName",
              fromDelevery: true,
              modalMode: false,
            ),
          ),
          routeName: foodRoute,
        );*/
      },
      child: Card(
        elevation: 2.0,
        margin: const EdgeInsets.all(10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              _foodRender(widget.food),
              //
              if (widget.food.isMenu) ...[
                if (_cartContext.foodMenuSelecteds != null) ...[
                  if (expand) ...[
                    for (Food f in widget.food.foodMenuSelecteds) ...[
                      if (f != null) ...[
                        _foodRender(f),
                        Divider(),
                        _options(f, menu: widget.food),
                      ] else ...[
                        Container()
                      ]
                    ],
                  ],
                  TextButton(
                    onPressed: () {
                      setState(() {
                        expand = !expand;
                      });
                    },
                    child: Center(
                      child: Icon(expand ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                    ),
                  )
                ]
              ],
              if (!widget.food.isMenu && widget.food.optionSelected != null && widget.food.optionSelected.isNotEmpty) ...[
                Divider(),
                if (expand) ...[
                  _options(widget.food),
                  Divider(),
                ],
                TextButton(
                  onPressed: () {
                    setState(() {
                      expand = !expand;
                    });
                  },
                  child: Center(
                    child: Icon(expand ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                  ),
                )
              ]
              // Divider(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _foodRender(dynamic f, {Menu menu}) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        f.isFoodForMenu
            ? SizedBox(
                width: 150,
              )
            : Container(),
        f.isFoodForMenu
            ? Container()
            : TextTranslator(
                '${f.quantity}x ',
                style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 20),
              ),
        SizedBox(
          width: 10,
        ),
        f.isMenu
            ? Container()
            : f.imageURL != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(
                      f.imageURL,
                    ),
                    onBackgroundImageError: (_, __) {},
                    backgroundColor: Colors.grey,
                    maxRadius: 20,
                  )
                // )
                : Icon(
                    Icons.fastfood,
                  ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextTranslator(
                f.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              f.isFoodForMenu
                  ? Container()
                  : TextTranslator(
                      f?.description ?? "",
                      style: TextStyle(
                        fontSize: f?.description == null ? 0 : 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
              if (f?.price?.amount != null) ...[
                f.isFoodForMenu
                    ? Container()
                    : f.isMenu
                        ? Text(
                            !_cartContext.withPrice || f.type == MenuType.priceless.value
                                ? ""
                                : f.type == MenuType.per_food.value
                                    ? '${(f.totalPrice.toDouble() / f.quantity) / 100}€'
                                    : '${f.price.amount / 100}€',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold),
                          )
                        : Text(
                            !_cartContext.withPrice || (menu != null && menu?.type == MenuType.priceless.value) ? "" : '${f.price.amount / 100}€',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold),
                          ),
              ]
            ],
          ),
        ),
        SizedBox(
          width: 15,
        ),
        f.isFoodForMenu
            ? Container()
            : ButtonItemCountWidget(
                f,
                onAdded: () {
                  setState(() {
                    _cartContext.refresh();
                  });
                },
                onRemoved: () async {
                  if (f.quantity <= 0) {
                    var result = await showDialog(
                      context: context,
                      builder: (_) => ConfirmationDialog(
                        title: AppLocalizations.of(context).translate('confirm_remove_from_cart_title'),
                        content: AppLocalizations.of(context).translate('confirm_remove_from_cart_content'),
                      ),
                    );

                    if (result is bool && result) {
                      _cartContext.removeItemAtPosition(widget.position);
                    } else {
                      f.quantity = 1;
                    }
                  }
                  setState(() {
                    _cartContext.refresh();
                  });
                },
                itemCount: f.quantity,
                isContains: _cartContext.contains(
                  f,
                ),
              ),
      ],
    );
  }

  Widget _options(Food f, {Menu menu}) {
    var options = f.optionSelected ?? [];
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: 15,
              bottom: 15,
              left: MediaQuery.of(context).size.width / 3,
              right: 25,
            ),
            child: Column(
              children: [
                for (Option option in options) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 15),
                      TextTranslator(
                        '${option.title}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      SizedBox(width: 5),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  for (ItemsOption itemsOption in option?.itemOptionSelected?.toList()) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 15),
                        itemsOption.quantity == null
                            ? Container()
                            : (itemsOption.quantity != null || itemsOption.quantity > 1)
                                ? TextTranslator('${itemsOption.quantity}x\t', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
                                : Container(),
                        InkWell(
                          onTap: () {
                            RouteUtil.goTo(
                                context: context,
                                child: PhotoViewPage(
                                  tag: 'tag:${itemsOption.imageUrl}',
                                  img: itemsOption.imageUrl,
                                ),
                                routeName: null);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: FadeInImage.assetNetwork(
                              placeholder: 'assets/images/loading.gif',
                              image: itemsOption.imageUrl,
                              imageErrorBuilder: (_, __, ___) => Container(
                                width: 35,
                                height: 35,
                                color: Colors.white,
                              ),
                              height: 35,
                              width: 35,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        TextTranslator('${itemsOption.name}', style: TextStyle(fontSize: 16)),
                        Spacer(),
                        if (itemsOption.price.amount == 0 || !widget.withPrice || (menu != null && menu?.type == MenuType.priceless.value))
                          Text("")
                        else
                          itemsOption.price?.amount == null
                              ? Text("")
                              : TextTranslator(
                                  '${itemsOption.price.amount / 100} €',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                      ],
                    ),
                  ],
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CommandHistoryItem extends StatelessWidget {
  CommandHistoryItem({Key key, this.command, this.position}) : super(key: key);
  final Command command;
  final int position;

  // Food food;

  @override
  Widget build(BuildContext context) {
    // food = Food.fromJson(command.items[0]['item']);

    return InkWell(
      onTap: () {
        RouteUtil.goTo(
          context: context,
          child: Material(
              child: Summary(
            commande: command,
            fromHistory: true,
          )),
          routeName: foodRoute,
        );
      },
      child: Card(
        elevation: 2.0,
        margin: const EdgeInsets.all(10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextTranslator('${command.restaurant.name}'),
              TextTranslator('${command.code?.toString()?.padLeft(6, '0')}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              _validated(),
              Column(
                children: [
                  TextTranslator("${command.createdAt.dateToString('dd/MM/yy HH:mm')}", style: TextStyle(fontSize: 16)),
                  if (command.shippingTime != null) TextTranslator("${command.shippingTime.dateToString('dd/MM/yy HH:mm')}", style: TextStyle(fontSize: 16)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _validated() {
    Color color;
    String title = "";
    if (!command.validated && !command.revoked) {
      title = "En attente";
      color = Colors.orange;
    } else if (command.validated) {
      title = "Valider";
      color = TEAL;
    } else if (command.revoked) {
      title = "Refuser";
      color = CRIMSON;
    }

    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(15), right: Radius.circular(15)),
        color: color,
      ),
      child: TextTranslator(
        title,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}

class BlogCard extends StatelessWidget {
  final Function(Blog) onTap;
  BlogCard(
    this.blog,
    this.onTap,
  );
  final Blog blog;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        onTap(blog);
      },
      child: Card(
        elevation: 4,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Container(
          child: Stack(
            fit: StackFit.loose,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 160,
                    width: double.infinity,
                    padding: EdgeInsets.only(bottom: 5, top: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: FadeInImage.assetNetwork(
                      image: blog?.imageURL ?? "",
                      placeholder: 'assets/images/loading.gif',
                      fit: BoxFit.contain,
                      imageErrorBuilder: (_, __, ___) => Container(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // ),
                  Divider(),
                  Container(
                    width: double.infinity,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(),
                        child: Center(
                          child: TextTranslator(
                            blog.title,
                            style: TextStyle(color: Colors.grey[600], fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Center(
                      child: TextTranslator(blog.description),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
