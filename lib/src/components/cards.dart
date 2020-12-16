import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:menu_advisor/src/components/buttons.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/components/menu_item_food_option.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/constants/date_format.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/pages/food.dart';
import 'package:menu_advisor/src/pages/restaurant.dart';
import 'package:menu_advisor/src/pages/summary.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/providers/DataContext.dart';
import 'package:menu_advisor/src/providers/MenuContext.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/button_item_count_widget.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';
import 'package:menu_advisor/src/utils/extensions.dart';
import 'package:url_launcher/url_launcher.dart';

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
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextTranslator(
                    name,
                    style: TextStyle(
                      color: DARK_BLUE,
                      fontFamily: 'Golden Ranger',
                      fontSize: 18,
                    ),
                    maxLines: 2,
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

  final bool showButton;

  const FoodCard({Key key, @required this.food, this.minified = false, this.imageTag, this.showButton = false}) : super(key: key);

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
                    bottom: widget.showButton ? 20 : 0,
                    left: widget.showButton ? 110 : 0,
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
                                  style: TextStyle(
                                    fontSize: 18,
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
                                    : TextTranslator(
                                        restaurantName ?? AppLocalizations.of(context).translate('no_associated_restaurant'),
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                if (widget.food.price != null && widget.food.price?.amount != null) ...[
                                  SizedBox(height: 5),
                                  Text(
                                    "${widget.food.price.amount / 100}€",
                                    style: TextStyle(
                                      fontSize: 21,
                                      color: Colors.yellow[700],
                                    ),
                                  ),
                                ] else
                                  ...[]
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
                                        cartContext.addItem(widget.food, value);
                                      },
                                      onRemoved: (value) {
                                        value == 0 ? cartContext.removeItem(widget.food) : cartContext.addItem(widget.food, value);
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
                                        color: Colors.white,
                                      ),
                                      padding: const EdgeInsets.all(5.0),
                                      child: FaIcon(
                                        cartContext.contains(widget.food) ? FontAwesomeIcons.minus : FontAwesomeIcons.plus,
                                        size: 10,
                                      ),
                                    ),
                                    onPressed: 
                                    widget.food.options.isNotEmpty ? 
                                    () => RouteUtil.goTo(
                                          context: context,
                                          child: FoodPage(
                                            food: widget.food,
                                            imageTag: widget.imageTag,
                                            restaurantName: restaurantName,
                                          ),
                                          routeName: foodRoute,
                                        ) :
                                    
                                    (cartContext.itemCount == 0) ||
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
                                                cartContext.removeItem(widget.food);

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
                  Positioned(
                    right: widget.showButton ? null : 30,
                    top: 0,
                    bottom: 0,
                    left: widget.showButton ? 30 : null,
                    child: Hero(
                      tag: widget.imageTag ?? 'foodImage${widget.food.id}',
                      child: widget.food.imageURL != null
                          ? FadeInImage.assetNetwork(
                              image: widget.food.imageURL,
                              placeholder: 'assets/images/loading.gif',
                              width: 80,
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

  bool loading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (!expanded)
          setState(() {
            expanded = true;
          });
        else {
          /*var result = await showDialog(
            context: context,
            builder: (_) => Container(
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: FoodPage(
                  food: widget.food,
                  modalMode: true,
                ),
              ),
            ),
          );*/
          RouteUtil.goTo(
            context: context,
            child: Material(
              child: FoodPage(
                food: widget.food,
                imageTag: widget.food.id,
              ),
            ),
            routeName: foodRoute,
          );
        }
        
      },
      child: Card(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15, right: 15.0, left: 15.0, bottom: 15),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: widget.food.id,
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/images/loading.gif',
                      image: widget.food.imageURL,
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                      imageErrorBuilder: (_, __, ___) => Icon(
                        Icons.food_bank_outlined,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15.0,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                          widget.food.description ?? AppLocalizations.of(context).translate('no_description'),
                        ),
                        if (widget.food.attributes.length > 0) ...[
                          SizedBox(
                            height: 5,
                          ),
                          // Consumer<DataContext>(
                          //   builder: (_, dataContext, __) =>
                             Container(
                               padding: EdgeInsets.only(bottom: expanded ? 30 : 0),
                               height: expanded ? 56 : 20,
                               child: ListView(
                                // spacing: expanded ? 5 : 5,
                                // runSpacing: 5,
                                scrollDirection: Axis.horizontal,
                                children: widget.food.foodAttributes
                                    .map(
                                      (attribute) => Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 5),
                                        child: FittedBox(
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
                                                  // var attribute = dataContext.attributes.firstWhere(
                                                  //   (element) => element['tag'] == e,
                                                  //   orElse: null,
                                                  // );

                                                  return Row(
                                                    children: [
                                                     // for (var attribute in dataContext.attributes)
                                                     ...[
FadeInImage.assetNetwork(
                                                          placeholder: 'assets/images/loading.gif',
                                                          image:  attribute.imageUrl,
                                                          height: 14,
                                                        ),
                                                        if (expanded)
                                                          SizedBox(
                                                            width: 5,
                                                          ),

                                                      if (expanded)
                                                        TextTranslator(
                                                          attribute.tag,
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
                            ),
                             ),
                          // ),
                        ],
                      ],
                    ),
                  ),
                  widget.food.price?.amount == null ? Text("") : Text('${widget.food.price.amount / 100}€'),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              right: 15,
                          child: Padding(
                padding: const EdgeInsets.only(right: 15, bottom: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Consumer<CartContext>(
                        builder: (_, cartContext, __) => 
                        ButtonItemCountWidget(widget.food, 
                        onAdded: (value) async {
                            if (widget.food.isMenu){
                                
                            }else{
                                if (widget.food.options.isNotEmpty && widget.food.optionSelected == null ){
                                  var optionSelected = await showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (_) => OptionChoiceDialog(
                                                    food: widget.food,
                                                  ),
                                                );
                                  if (optionSelected != null)
                                    cartContext.addItem(widget.food, value);
                                }else{
                                  cartContext.addItem(widget.food, value);
                                }
                            }
                                
                        }, onRemoved: (value) {
                              value == 0 ? cartContext.removeItem(widget.food) : cartContext.addItem(widget.food, value);
                            }, itemCount: cartContext.getCount(widget.food), isContains: cartContext.contains(widget.food))
                        ),
                  ],
                ),
              ),
            ),
          ],
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
              imageTag: widget.food.id,
            ),
            routeName: foodRoute,
          );
          /*if (cartContext.contains(widget.food)) {
            var result = await showDialog(
              context: context,
              builder: (_) => ConfirmationDialog(
                title: AppLocalizations.of(context)
                    .translate('confirm_remove_from_cart_title'),
                content: AppLocalizations.of(context)
                    .translate('confirm_remove_from_cart_content'),
              ),
            );

            if (result is bool && result) {
              cartContext.removeItem(widget.food);
            }
          } else {
            bool result = await showDialog<bool>(
              context: context,
              builder: (_) => AddToBagDialog(
                food: widget.food,
              ),
            );
            if (result is bool && result) {}
          }*/
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
                    Hero(
                      tag: widget.food.id,
                      child: widget.food.imageURL != null
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
                    ),
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
              Padding(
                padding: const EdgeInsets.only(right: 15, bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Consumer<CartContext>(
                        builder: (_, cartContext, __) => ButtonItemCountWidget(widget.food, onAdded: (value) {
                              cartContext.addItem(widget.food, value);
                            }, onRemoved: (value) {
                              value == 0 ? cartContext.removeItem(widget.food) : cartContext.addItem(widget.food, value);
                            }, itemCount: cartContext.getCount(widget.food), isContains: cartContext.contains(widget.food))

                        /*RawMaterialButton(
                        fillColor: DARK_BLUE,
                        padding: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            // bottomLeft: Radius.circular(30),
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
                            cartContext.contains(widget.food)
                                ? FontAwesomeIcons.minus
                                : FontAwesomeIcons.plus,
                            size: 10,
                          ),
                        ),
                        onPressed: (cartContext.itemCount == 0) ||
                                (cartContext.pricelessItems &&
                                    widget.food.price.amount == null) ||
                                (!cartContext.pricelessItems &&
                                    widget.food.price.amount != null)
                            ? () async {
                                if (cartContext.contains(widget.food)) {
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
                                    cartContext.removeItem(widget.food);
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
                                Fluttertoast.showToast(
                                    msg:
                                        'Vous ne pouvez pas à la fois commander des articles sans prix et avec prix');
                              },
                      ),*/
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
  final String restaurant;
  int count = 0;

  MenuCard({
    Key key,
    @required this.menu,
    @required this.lang,
    this.restaurant
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MenuContext _controller = Provider.of<MenuContext>(context, listen: false);
    CartContext _cartContext = Provider.of<CartContext>(context, listen: false);
    menu.restaurant = restaurant;
    _controller.menu = menu;
    _controller.foodsGrouped = menu.foods ?? List();
    count = _cartContext.getCount(menu);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                menu.imageURL != null
                    ? FadeInImage.assetNetwork(placeholder: 'assets/images/loading.gif', image: menu.imageURL, width: 100, height: 100, fit: BoxFit.contain)
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextTranslator(
                        menu.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                        ),
                      ),
                      TextTranslator(
                        menu.description ?? "",
                        style: TextStyle(),
                      ),

                    ],
                  ),
                ),
                Consumer<CartContext>(
                  builder: (_, _cart,__) {
                    return ButtonItemCountWidget(
                        menu,
                        isMenu: true, onAdded: (value){
                          if (value < 2){
                            _cart.addItem(menu, value);
                            count = value;
                          }
                        
                        }, 
                        onRemoved: (value){
                          value == 0 ? _cart.removeItem(menu) 
                          : _cart.addItem(menu, value);
                          count = value;

                        }, itemCount: count
                        , isContains: _cart.contains(menu));
                  }
                )
              ],
            ),
            Column(
              children: [
                for (var entry in _controller.foodsGrouped.entries)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 15,),
                      TextTranslator(entry.key,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),),
                      Divider(),
                      for (var food in entry.value)...[
                        Consumer<MenuContext>(
                          builder: (context, menuContext,w) {
                            return InkWell(
                              onTap: (){
                                menuContext.select(entry.key, food);
                              },
                                child: Card(
                                elevation: 2,
                                child: Container(
                                  margin: EdgeInsets.all(15),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Radio(value: menuContext.selectedMenu[entry.key]?.first?.id, groupValue: food.id, onChanged: null,activeColor: CRIMSON,hoverColor: CRIMSON,),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: TextTranslator(food.name),
                                          ),
                                          if (menu.type == MenuType.fixed_price.value)...[
                                            Text(" ")
                                          ]else if (menu.type == MenuType.fixed_price.value)...[
                                            Text(" ")
                                          ]else...[
                                            food?.price?.amount == null ? Text("") : Text("${food.price.amount / 100} €", style: TextStyle(fontWeight: FontWeight.bold)),
                                          ]
                                            

                                          /*ButtonItemCountWidget(
                                            food,
                                            isMenu: true, onAdded: (value){
                                              _cartContext.addItem(food, value);
                                          }, onRemoved: (value){
                                              value == 0 ? _cartContext.removeItem(food) 
                                              : _cartContext.addItem(food, value);
                                          }, itemCount: _cartContext.getCount(food)
                                          , isContains: _cartContext.contains(food))*/
                                        ],
                                      ),
                                      if (menuContext.selectedMenu[entry.key]?.first?.id == food.id)...[
                                        MenuItemFoodOption(food: food,)
                                      ]else
                                        Container()
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        )
                      ]
                    ],
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RestaurantCard extends StatefulWidget {
  final Restaurant restaurant;
  final bool fromHome;

  const RestaurantCard({Key key, @required this.restaurant, this.fromHome = false}) : super(key: key);

  @override
  _RestaurantCardState createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<RestaurantCard> {
  bool switchingFavorite = false;

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
                                      widget.restaurant.type ?? "",
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
                              child: Visibility(
                                visible: false,
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

class BagItem extends StatefulWidget {
  final dynamic food;
  int count;
  bool activeDelete;
  String imageTag;


  BagItem({Key key, @required this.food, @required this.count, this.activeDelete = true, this.imageTag}) : super(key: key);

  @override
  _BagItemState createState() => _BagItemState();
}

class _BagItemState extends State<BagItem> {
  CartContext _cartContext;

  bool hasMessage = false;

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
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextTranslator(
                '${widget.count} x ',
                style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(
                width: 10,
              ),
              widget.food.imageURL != null
                  ? Hero(
                      tag: widget.imageTag ?? widget.food.id,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                          widget.food.imageURL,
                        ),
                        onBackgroundImageError: (_, __) {},
                        backgroundColor: Colors.grey,
                        maxRadius: 20,
                      ),
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
                    TextTranslator(
                      widget.food.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextTranslator(
                      widget.food?.description ?? "",
                      style: TextStyle(fontSize: widget.food?.description == null ? 0 : 15, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                    ),
                    if (widget.food.price?.amount != null)
                      Text(
                        '${_cartContext.getTotalPriceFood(widget.food)}€',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
              /*if (food.price.amount != null)
                      TextTranslator(
                        '${food.price.amount / 100}€',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),*/
              /*Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                padding: const EdgeInsets.all(15.0),
                child: TextTranslator(
                  '$count',
                  style: TextStyle(
                    color: CRIMSON,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),*/
              /* IconButton(
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
              ),*/
              
              ButtonItemCountWidget(
                widget.food,
                itemCount: widget.count,
                onAdded: (value) {
                  widget.count = value;
                  _cartContext.addItem(widget.food, value);
                },
                onRemoved: (value) {
                  value == 0 ? _cartContext.removeItem(widget.food) : _cartContext.addItem(widget.food, value);

                  if (_cartContext.items.length == 0) RouteUtil.goBack(context: context);
                  widget.count = value;
                },
                isContains: _cartContext.contains(widget.food),
                isFromDelevery: true,
              ),
               SizedBox(
                  width: 15,
                ),
              Stack(
                  children: [
                    
                    CircleButton(
  
                    backgroundColor: CRIMSON,
                    onPressed: (){
                      showDialog<String>(context: context,
                      child: MessageDialog(message: widget.food.message,)).then((value) {
                          print(value);
                          widget.food.message = value;
                          if (value.isNotEmpty){
                            setState(() {
                              hasMessage = true;
                            });
                          }else{
                            setState(() {
                              hasMessage = false;
                            });
                          }
                        }   
                      );
                    },
                    child: Icon(Icons.comment,
                        color: Colors.white,
                        size: 15,),
                        
                  ),
                  Visibility(
                    visible: hasMessage,
                                      child: Positioned(
                        right: 0,
                        bottom: 0,
                        child:  Icon(
                                        Icons.brightness_1,
                                        color: Color(0xff62C0AB),
                                        size: 12,
                                      )
                      ),
                  ),
                  ],
              ),
              if (widget.activeDelete) ...[
                SizedBox(
                  width: 15,
                ),
                CircleButton(
                  backgroundColor: CRIMSON,
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 15,
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
                      CartContext cartContext = Provider.of<CartContext>(context, listen: false);

                      cartContext.removeItem(widget.food);
                      if (cartContext.items.length == 0) RouteUtil.goBack(context: context);
                    }
                  },
                ),
              ]
            ],
          ),
        ),
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
            child: Summary(commande: command,fromHistory: true,)
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
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextTranslator('${command.restaurant.name}'),
              TextTranslator('${command.code?.toString()?.padLeft(6,'0')}', style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
              // SizedBox(width: 15),
              // Image.network(
              //   item.imageURL,
              //   width: 25,
              // ),
              // SizedBox(width: 8),
              _validated(),
              // Spacer(),
              if (command.shippingTime != null)
                TextTranslator("${command.shippingTime.dateToString('dd/MM/yy HH:mm')}", style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _validated() {
    Color color;
    String title = "";
    if (!command.validated && !command.revoked){
      title = "En attente";
      color = Colors.orange;
    }else if (command.validated){
      title = "Valider";
      color = TEAL;
    }else if (command.revoked){
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
  BlogCard(this.blog);
  Blog blog;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        height: 400,
        width: 400,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              fit: StackFit.loose,
                children: [
                  Container(
                    height: 190,
                    width: double.infinity,
                    child: FadeInImage.assetNetwork(
                      image: blog.imageURL,
                      placeholder: 'assets/images/loading.gif',
                      fit: BoxFit.contain,
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
                              blog.title,
                              style: TextStyle(
                                color:Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                      ),

                  ))
                ],
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child:TextTranslator(
                blog.description,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                  style:TextStyle(
                    fontSize: 15
                )
              )
            ),
            Spacer(),
            Container(width: double.infinity,height: 1,color:Colors.grey[200]),
            InkWell(
              onTap: () async{
                if (await canLaunch(blog.url))
                  launch(blog.url);
              },
              child: Container(
                height: 50,
                child: Center(
                  child: TextTranslator(
                    "Acheter maintenant",
                    style: TextStyle(
                      fontSize:16,
                      color: CRIMSON,
                      fontWeight: FontWeight.bold
                    )
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
