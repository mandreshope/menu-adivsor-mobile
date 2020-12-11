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
import 'package:menu_advisor/src/providers/DataContext.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/button_item_count_widget.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';

class FoodPage extends StatefulWidget {
  final Food food;
  final String imageTag;
  final String restaurantName;
  final bool modalMode;
  final bool fromDelevery;

  FoodPage({this.food, this.imageTag, this.restaurantName, this.modalMode = false, this.fromDelevery = false});

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
  int itemCount = 1;
  CartContext _cartContext;

  @override
  void initState() {
    super.initState();

    _cartContext = Provider.of<CartContext>(context, listen: false);
    if (_cartContext.contains(widget.food)) itemCount = _cartContext.getCount(widget.food);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
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

    DataContext dataContext = Provider.of<DataContext>(context,listen: false);
    dataContext.fetchFoodAttributes(widget.food.attributes);
    });

  }

  @override
  Widget build(BuildContext context) {
    return !widget.modalMode
        ? Scaffold(
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
              title: TextTranslator(widget.food.name),
              actions: [],
            ),
            body: mainContent,
          )
        : Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(

              child: mainContent,
            ),
            
          );
  }

  Widget get mainContent => Container(
        width: !widget.modalMode ? double.infinity : MediaQuery.of(context).size.width - 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            SingleChildScrollView(
                child: Column(
                mainAxisSize: widget.fromDelevery ? MainAxisSize.min : MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 4,
                    child: _image(),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Divider(),
                  Container(
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 15),
                          padding: EdgeInsets.all(5),
                          child: Text(
                            '€',
                            style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black),
                        ),
                        Positioned(
                          left: 70,
                          child: TextTranslator(
                            'Prix',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        if (widget.food.price != null && widget.food.price?.amount != null)
                          Positioned(
                            right: 25,
                            child: Text(
                              '${widget.food.price.amount / 100} €',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Divider(),
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: TextTranslator(
                      AppLocalizations.of(context).translate('description'),
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: TextTranslator(
                      widget.food.description ?? AppLocalizations.of(context).translate('no_description'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Divider(),
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: TextTranslator(
                      AppLocalizations.of(context).translate('attributes'),
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 10,
                      right: 5 /** MediaQuery.of(context).size.width / 7*/,
                    ),
                    child: widget.food.attributes.length > 0
                        ? Consumer<DataContext>(
                            builder: (_, dataContext, __) {
                              
                            return !dataContext.loadingFoodAttributes
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                      left: 5.0,
                                    ),
                                    child: Wrap(
                                      spacing: 5,
                                      runSpacing: 5,
                                      children: dataContext.attributes
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
                                                          if (dataContext.attributes != null)
                                                          //for (var attribute in dataContext.attributes) 
                                                          ...[
                                                            FadeInImage.assetNetwork(
                                                              placeholder: 'assets/images/loading.gif',
                                                              image: attribute.imageUrl,
                                                              height: 14,
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            TextTranslator(
                                                              attribute.tag,
                                                            ),
                                                          ]
                                                          else TextTranslator("")
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
                                  )
                                : CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                    CRIMSON,
                                  ));})
                        : Padding(
                            padding: const EdgeInsets.only(
                              left: 20.0,
                            ),
                            child: TextTranslator(
                              AppLocalizations.of(context).translate('no_attribute'),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                  ),

                  // Text("test"),

                  if (!widget.fromDelevery) ...[
                    //  Spacer(),
                    // if (!this._cartContext.contains(widget.food))
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (showFavorite)
                          SizedBox(
                            width: 30,
                          ),
                        Consumer<CartContext>(
                            builder: (_, cartContext, __) => 
                            ButtonItemCountWidget(widget.food, 
                            onAdded: (value) async {
                                if (widget.food.options.isNotEmpty){
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
                                  
                                }, 
                                onRemoved: (value) {
                                  value == 0 ? cartContext.removeItem(widget.food) : cartContext.addItem(widget.food, value);
                                }, 
                                itemCount: cartContext.getCount(widget.food), 
                                isContains: cartContext.contains(widget.food)))
                      ],
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 20,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (showFavorite) ...[
                            FloatingActionButton(
                              onPressed: !switchingFavorite
                                  ? () async {
                                      AuthContext authContext =
                                          Provider.of<AuthContext>(
                                        context,
                                        listen: false,
                                      );

                                      setState(() {
                                        switchingFavorite = true;
                                      });
                                      if (!isInFavorite)
                                        await authContext
                                            .addToFavoriteFoods(widget.food);
                                      else
                                        await authContext
                                            .removeFromFavoriteFoods(widget.food);
                                      setState(() {
                                        switchingFavorite = false;
                                        isInFavorite = !isInFavorite;
                                      });
                                      Fluttertoast.showToast(
                                        msg: AppLocalizations.of(context)
                                            .translate(
                                          isInFavorite
                                              ? 'added_to_favorite'
                                              : 'removed_from_favorite',
                                        ),
                                      );
                                    }
                                  : null,
                              child: !switchingFavorite
                                  ? Icon(
                                      isInFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                    )
                                  : SizedBox(
                                      width: 15,
                                      height: 15,
                                      child: FittedBox(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
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
                            child: Consumer<CartContext>(
                              builder: (_, cartContext, __) => Column(
                                children: [
                                  RaisedButton(
                                    padding: EdgeInsets.all(20),
                                    color: cartContext.contains(widget.food)
                                        ? Colors.teal
                                        : CRIMSON,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    onPressed: () async {
                                      if ((cartContext.itemCount == 0) ||
                                          (cartContext.hasSamePricingAsInBag(
                                                  widget.food) &&
                                              cartContext.hasSameOriginAsInBag(
                                                  widget.food))) {
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
                                            setState(() {
                                              itemCount = 1;
                                            });
                                            RouteUtil.goBack(context: context);
                                          }
                                        } else {
                                          /*bool result = await showDialog<bool>(
                                              context: context,
                                              builder: (_) => AddToBagDialog(
                                                food: widget.food,
                                              ),
                                            );
                                            if (result is bool && result) {}*/
                                         /* if (cartContext.contains(widget.food))
                                            cartContext.setCount(
                                                widget.food, itemCount);
                                          else
                                            cartContext.addItem(
                                                widget.food, itemCount);*/
                                                if (widget.food.options.isNotEmpty){
                                                  var optionSelected = await showDialog(
                                                                  context: context,
                                                                  barrierDismissible: false,
                                                                  builder: (_) => OptionChoiceDialog(
                                                                    food: widget.food,
                                                                  ),
                                                                );
                                                  if (optionSelected != null)
                                                    cartContext.addItem(widget.food, itemCount);
                                                }else{
                                                  cartContext.addItem(widget.food, itemCount);
                                                }

                                          /*Navigator.of(context).pop(true);*/
                                          
                                        }
                                      } else if (!cartContext
                                          .hasSamePricingAsInBag(widget.food)) {
                                        Fluttertoast.showToast(
                                          msg: AppLocalizations.of(context).translate(
                                              'priceless_and_not_priceless_not_allowed'),
                                        );
                                      } else if (!cartContext
                                          .hasSameOriginAsInBag(widget.food)) {
                                        Fluttertoast.showToast(
                                          msg: AppLocalizations.of(context).translate(
                                              'from_different_origin_not_allowed'),
                                        );
                                      }
                                    },
                                    child: TextTranslator(
                                      cartContext.contains(widget.food)
                                          ? AppLocalizations.of(context)
                                              .translate('remove_from_cart')
                                          : AppLocalizations.of(context)
                                              .translate("add_to_cart"),
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  cartContext.contains(widget.food) ? SizedBox(height: 50,) : Container()
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  ],

                ],
              ),
            ),
            Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: Consumer<CartContext>(
                  builder: (_, cartContext, __) => cartContext.contains(widget.food)
                      ? OrderButton(
                          totalPrice: cartContext.getTotalPriceFood(widget.food),
                        )
                      : SizedBox(),
                )),
          ],
        ),
      );

  Widget _image() => GestureDetector(
        onTap: () {
          return;
          Navigator.of(context).push(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (BuildContext context) {
                return new Scaffold(
                  appBar: AppBar(
                    iconTheme: IconThemeData(
                      color: Colors.black,
                    ),
                    title: TextTranslator(
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
                  // width: 4 * MediaQuery.of(context).size.width / 7,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.contain,
                )
              : Icon(
                  Icons.fastfood,
                  size: 250,
                ),
        ),
      );
}
