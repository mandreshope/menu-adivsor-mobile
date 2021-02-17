import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_collapse/flutter_collapse.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/components/buttons.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/pages/photo_view.dart';
import 'package:menu_advisor/src/pages/restaurant.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/providers/DataContext.dart';
import 'package:menu_advisor/src/providers/MenuContext.dart';
import 'package:menu_advisor/src/providers/OptionContext.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/button_item_count_widget.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class FoodPage extends StatefulWidget {
  Food food;
  final String imageTag;
  final String restaurantName;
  final bool modalMode;
  final bool fromDelevery;
  final bool fromRestaurant;
  final String subMenu;
  FoodPage({this.food, this.subMenu, this.imageTag, this.restaurantName, this.modalMode = false, this.fromDelevery = false, this.fromRestaurant = false});

  @override
  _FoodPageState createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  bool isInFavorite = false;
  bool showFavorite = false;
  Api api = Api.instance;
  bool loading = true;
  String restaurantName;
  bool switchingFavorite = false;
  int itemCount = 0;
  CartContext _cartContext;
  List<Option> options = [];
  // bool collaspse = true;
  Map<String, bool> collaspse = Map();

  OptionContext _optionContext;

  List<Option> _optionSelected = List();

  Menu menu;
  Food foodAdded;

  dynamic choiceSelected;
  bool isAdded = false;
  ItemsOption singleItemOptionSelected;

  @override
  void initState() {
    super.initState();

    _optionContext = Provider.of<OptionContext>(context, listen: false);
    _cartContext = Provider.of<CartContext>(context, listen: false);
    // if (_cartContext.contains(widget.food)) itemCount = _cartContext.getCount(widget.food);
    MenuContext _menuContext = Provider.of<MenuContext>(context, listen: false);
    // menu = _menuContext.menu;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      /*Food f = await api.getFood(
        id: widget.food.id,
        lang: 'fr'
      );

     widget.food = f;*/

      api
          .getRestaurant(
        id: (widget.food.restaurant is String) ? widget.food.restaurant : widget.food.restaurant['_id'],
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

      DataContext dataContext = Provider.of<DataContext>(context, listen: false);
      // dataContext.fetchFoodAttributes(widget.food.attributes);
      dataContext.attributes = widget.food.attributes;
      // setState(() {

      // });
      // options = widget.food.options;
      _init();
    });
  }

  _init() {
    foodAdded = Food.copy(widget.food);
    foodAdded.idNewFood = DateTime.now().millisecondsSinceEpoch.toString();
    options = widget.food.options.map((e) => Option.copy(e)).toList();

    options.forEach((element) {
      collaspse[element.sId] = true;
    });

    itemCount = _cartContext.getFoodCountByIdNew(foodAdded);
    this.isAdded = false;
    singleItemOptionSelected = null;
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
              actions: [
                showFavorite
                    ? IconButton(
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
                        icon: !switchingFavorite
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
                      )
                    : Container(),
                IconButton(
                    icon: Icon(
                      FontAwesomeIcons.share,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Share.share("Menu advisor");
                    }),
              ],
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
                    height: MediaQuery.of(context).size.height / 3.5,
                    child: _image(),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Divider(),
                  Center(
                    child: TextTranslator(
                      widget.food.name,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        // fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  loading
                      ? Center(
                          child: CupertinoActivityIndicator(
                          animating: true,
                        ))
                      : Center(
                          child: InkWell(
                            onTap: () {
                              if (widget.fromRestaurant)
                                RouteUtil.goBack(context: context);
                              else
                                RouteUtil.goTo(
                                  context: context,
                                  child: RestaurantPage(
                                    restaurant: (widget.food.restaurant is String) ? widget.food.restaurant : widget.food.restaurant['_id'],
                                  ),
                                  routeName: restaurantRoute,
                                );
                            },
                            child: TextTranslator(
                              restaurantName,
                              style: TextStyle(color: Colors.blue, fontSize: 20, decoration: TextDecoration.underline, fontWeight: FontWeight.w600),
                            ),
                          ),
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
                            child: !_cartContext.withPrice
                                ? Text("")
                                : Text(
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
                  //description
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
                        ? Consumer<DataContext>(builder: (_, dataContext, __) {
                            return /*!dataContext.loadingFoodAttributes
                                ?*/
                                Padding(
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
                                                        image: attribute.imageURL,
                                                        height: 14,
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      TextTranslator(
                                                        attribute.locales,
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
                              ),
                            );
                            /*: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                    CRIMSON,
                                  ));*/
                          })
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

                  // options
                  SizedBox(
                    height: 15,
                  ),
                  loading
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              CRIMSON,
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 25),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: options.length,
                                itemBuilder: (_, position) {
                                  Option option = options[position];
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Collapse(
                                        title: TextTranslator("Vous avez ${option.maxOptions} choix de ${option.title}", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                        body: Container(
                                          child: Padding(padding: const EdgeInsets.all(0), child: _choice(option, option.maxOptions == 1 ? true : false)),
                                        ),
                                        value: collaspse[option.sId],
                                        onChange: (value) {
                                          setState(() {
                                            collaspse[option.sId] = value;
                                          });
                                        },
                                      )
                                    ],
                                  );
                                },
                              ),

                              /*RaisedButton(
                          padding: EdgeInsets.all(8),
                          color: CRIMSON,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          onPressed: ()=> Navigator.of(context).pop(optionSelected),
                          child: TextTranslator(
                            AppLocalizations.of(context)
                                .translate("validate"),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),*/
                            ],
                          ),
                        ),
                  // Text("test"),

                  if (!widget.fromDelevery) ...[
                    //  Spacer(),
                    // if (!this._cartContext.contains(widget.food))
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /* if (showFavorite)
                          SizedBox(
                            width: 20,
                          ),*/
                        itemCount == 0
                            ? Container()
                            : Consumer<CartContext>(builder: (_, cartContext, __) {
                                this.itemCount = cartContext.getFoodCountByIdNew(foodAdded);
                                if (this.itemCount == 0) {
                                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                    setState(() {
                                      _init();
                                    });
                                  });
                                }
                                return itemCount == 0
                                    ? Container()
                                    :
                                    /*    Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      // border: Border.all(color: CRIMSON,width: 1)
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 6),
                                    width: 35,
                                    child: Center(
                                      child: TextTranslator(
                                        '${itemCount}',
                                        style: TextStyle(
                                          color: CRIMSON,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                        )*/
                                    ButtonItemCountWidget(foodAdded, onAdded: () async {
                                        setState(() {
                                          // cartContext.addItem(
                                          //     foodAdded, itemCount, true);
                                          // choiceSelected.select(choiceSelected.selected);
                                          // foodAdded = Food.copy(widget.food);
                                          /*options.forEach((element) {
                                    element.itemOptionSelected =
                                        List();});*/
                                          this.itemCount++;
                                        });
                                      }, onRemoved: (food) {
                                        // value == 0 ? cartContext.removeItem(widget.food) : cartContext.addItem(widget.food, value,false);
                                        setState(() {
                                          // options = food.optionSelected.map<Option>((e) => Option.copy(e)).toList();
                                          /* options.forEach((element) {
                                      element.itemOptionSelected =
                                          List();});
                                    print(options);*/
                                          --this.itemCount;
                                          if (this.itemCount <= 0) {
                                            this.itemCount = 0;
                                            this.isAdded = false;
                                            _init();
                                            /*foodAdded = Food.copy(widget.food);
                                        foodAdded.optionSelected = null;
                                        options.forEach((element) {
                                          element.itemOptionSelected = List();
                                        });
                                        // _optionContext.itemOptions = option.itemOptionSelected;
                                        singleItemOptionSelected = null;
                                        options = food.optionSelected.map<Option>((e) => Option.copy(e)).toList();
*/
                                          }
                                        });
                                      }, itemCount: cartContext.getFoodCountByIdNew(foodAdded), isContains: cartContext.contains(widget.food));

                                //delete all food
                                /*
                        Consumer<CartContext>(
                          builder: (_,cartContext,w){
                            return itemCount == 0 ? Container() :
                             IconButton(icon: Icon(Icons.delete_rounded,color:Colors.grey), onPressed: () async {
                              if ((itemCount == 0) ||
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
                                    cartContext.removeAllFood(widget.food);
                                    setState(() {
                                      itemCount = 1;
                                    });
                                    RouteUtil.goBack(context: context);
                                  }
                                }
                              }
                            });

                          },
                        )*/
                              })
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
                          Expanded(
                            child: Container(
                              child: Consumer<CartContext>(
                                builder: (_, cartContext, __) => Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    /* cartContext.contains(widget.food) ?

                                    FlatButton(child: Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(30)),
                                            color: CRIMSON
                                          ),
                                          child: Icon(Icons.remove,color: Colors.white,
                                              size: 35),
                                        ),
                                            onPressed: () async {
                                              int value = --itemCount;
                                              if (value <= 0) {
                                                var result = await showDialog(
                                                  context: context,
                                                  builder: (_) => ConfirmationDialog(
                                                    title: AppLocalizations.of(context).translate('confirm_remove_from_cart_title'),
                                                    content: AppLocalizations.of(context).translate('confirm_remove_from_cart_content'),
                                                  ),
                                                );

                                                if (result is bool && result) {
                                                  _cartContext.removeItem(widget.food);
                                                  // if (!fromRestaurant)
                                                  itemCount = 0;
                                                    RouteUtil.goBack(context: context);
                                                }
                                              } else {
                                                _cartContext.addItem(widget.food, value, false);
                                              }
                                            }) : Container(),*/

                                    // add food
                                    if (itemCount == 0)
                                      RaisedButton(
                                        padding: EdgeInsets.all(20),
                                        color:
                                            /*itemCount > 0
                                          ? Colors.teal
                                          // :*/ /*cartContext.hasOptionSelectioned(foodAdded) ?
                                            CRIMSON :*/
                                            Colors.grey,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        onPressed: () async {
                                          if ((this.itemCount == 0) || (cartContext.hasSamePricingAsInBag(widget.food) && cartContext.hasSameOriginAsInBag(widget.food))) {
                                            /*  if (cartContext.contains(widget.food)) {
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
                                              cartContext.removeAllFood(foodAdded);
                                              setState(() {
                                                itemCount = 1;
                                              });
                                              RouteUtil.goBack(context: context);
                                            }
                                          } else {*/
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
                                            /* if (widget.food.options.isNotEmpty){
                                                    var optionSelected = await showDialog(
                                                                    context: context,
                                                                    barrierDismissible: false,
                                                                    builder: (_) => OptionChoiceDialog(
                                                                      food: widget.food,
                                                                    ),
                                                                  );
                                                    if (optionSelected != null)
                                                      cartContext.addItem(widget.food, itemCount,true);
                                                  }else{*/
                                            if (cartContext.hasOptionSelectioned(foodAdded)) {
                                              cartContext.addItem(foodAdded, itemCount, true);
                                              // foodAdded = Food.copy(widget.food);
                                              /*options.forEach((element) {
                                                  element.itemOptionSelected =
                                                      List();
                                                  element.singleItemOptionSelected = null;
                                                });*/
                                              // cartContext.refresh();
                                              this.isAdded = true;
                                              this.itemCount++;
                                              RouteUtil.goBack(context: context);
                                              setState(() {});
                                            } else
                                              Fluttertoast.showToast(
                                                msg: 'Ajouter une option',
                                              );
                                            //}
                                          } else if (!cartContext.hasSamePricingAsInBag(widget.food)) {
                                            Fluttertoast.showToast(
                                              msg: AppLocalizations.of(context).translate('priceless_and_not_priceless_not_allowed'),
                                            );
                                          } else if (!cartContext.hasSameOriginAsInBag(widget.food)) {
                                            Fluttertoast.showToast(
                                              msg: AppLocalizations.of(context).translate('from_different_origin_not_allowed'),
                                            );
                                          }
                                        },
                                        child: TextTranslator(
                                          /*cartContext.contains(widget.food)
                                            ? AppLocalizations.of(context)
                                                .translate('remove_from_cart')
                                            : */
                                          AppLocalizations.of(context).translate("add_to_cart"),
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    //cartContext.contains(widget.food) ? SizedBox(height: 50,) : Container()
                                    /* cartContext.contains(widget.food) ?
                                    FlatButton(child:  Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(30)),
                                          color: CRIMSON
                                      ),
                                      child: Icon(Icons.add,color: Colors.white,
                                          size: 35),
                                    ),
                                        onPressed: () async {
                                          int value = ++itemCount;
                                          _cartContext.addItem(widget.food, value, true);
                                          setState(() {
                                            // option.itemOptionSelected = List();
                                          });

                                        }) : Container(),*/
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  Consumer<CartContext>(
                    builder: (_, cartContext, __) => cartContext.contains(widget.food)
                        ? SizedBox(
                            height: 95,
                          )
                        : Container(),
                  )
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
                          totalPrice: _cartContext.totalPrice,
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
        child: Stack(
          children: [
            InkWell(
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
              onTap: () {
                RouteUtil.goTo(
                    context: context,
                    child: PhotoViewPage(
                      tag: widget.imageTag ?? 'foodImage${widget.food.id}',
                      img: widget.food.imageURL,
                    ),
                    routeName: null);
              },
            ),
            /* Positioned.fill(
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
                      color: Colors.black.withAlpha(70),
                      child: Center(
                        child: TextTranslator(
                          widget.food.name,
                          style: TextStyle(
                              color:Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                  ),

                ))*/
          ],
        ),
      );

  Widget _choice(Option option, bool isSingle) {
    if (isSingle) {
      return ChipsChoice.single(
        value: singleItemOptionSelected,
        choiceStyle:
            C2ChoiceStyle(borderColor: Colors.white, disabledColor: Colors.white, borderRadius: BorderRadius.zero, showCheckmark: false, padding: EdgeInsets.zero, labelPadding: EdgeInsets.zero),
        padding: EdgeInsets.zero,
        // wrapped: true,
        // textDirection: TextDirection.ltr,
        direction: Axis.vertical,
        onChanged: (value) {
          // int diff =
          if (this.isAdded) return;
          setState(() {
            singleItemOptionSelected = value;
            singleItemOptionSelected.isSingle = true;
            singleItemOptionSelected.quantity = 1;
            if (option.itemOptionSelected.isEmpty) option.itemOptionSelected = List();

            option.itemOptionSelected.removeWhere((element) => element.isSingle);
            option.itemOptionSelected.add(value);

            foodAdded.optionSelected = options.map((o) => Option.copy(o)).toList();
            _optionContext.itemOptions = option.itemOptionSelected;
          });
        },
        choiceItems: C2Choice.listFrom(
          meta: (position, item) {},
          source: option.items,
          value: (i, v) => v,
          label: (i, v) => v.name,
        ),
        choiceBuilder: (_) {
          return Container(
            margin: EdgeInsets.only(top: 15),
            color: Colors.white,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  width: 10,
                ),
                InkWell(
                  onTap: () {
                    _.select(!_.selected);
                  },
                  child: _.selected
                      ? Icon(
                          Icons.radio_button_checked,
                          color: CRIMSON,
                          size: 25,
                        )
                      : Icon(
                          Icons.add_circle_outlined,
                          color: Colors.grey,
                          size: 25,
                        ),
                ),
                SizedBox(
                  width: 20,
                ),
                InkWell(
                  onTap: () {
                    RouteUtil.goTo(
                        context: context,
                        child: PhotoViewPage(
                          tag: 'tag:${_.value.imageUrl}',
                          img: _.value.imageUrl,
                        ),
                        routeName: null);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/images/loading.gif',
                      image: _.value.imageUrl,
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Text("${_.value.name}"),
                SizedBox(
                  width: 5,
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      // shape: BoxShape.circle,
                      // color: _.value.price == 0 ? null : Colors.grey[400]
                      ),
                  child: !_cartContext.withPrice || _.value.price.amount == null
                      ? Text("")
                      : Text(
                          "${_.value.price.amount == 0 ? '' : _.value.price.amount / 100}${_.value.price.amount == 0 ? '' : "€"}",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                )
              ],
            ),
          );
        },
      );
    }

    return ChipsChoice.multiple(
      value: option.itemOptionSelected,
      choiceStyle: C2ChoiceStyle(borderColor: Colors.transparent, disabledColor: Colors.white, borderRadius: BorderRadius.zero),
      padding: EdgeInsets.zero,
      // wrapped: true,
      // textDirection: TextDirection.ltr,
      direction: Axis.vertical,
      onChanged: (value) {
        // int diff =
        if (this.isAdded) return;
        setState(() {
          if (option.itemOptionSelected?.length == option.maxOptions) {
            if (option.itemOptionSelected.length >= value.length) {
              var seen = Set<String>();
              option.itemOptionSelected = value.cast<ItemsOption>().where((element) => seen.add(element.name)).toList();
              foodAdded.optionSelected = options.map((o) => Option.copy(o)).toList();
            } else {
              print("max options");
              Fluttertoast.showToast(msg: "maximum selection ${option.title} : ${option.maxOptions}");
            }
          } else {
            var seen = Set<String>();
            option.itemOptionSelected = value.cast<ItemsOption>().where((element) => seen.add(element.name)).toList();

            foodAdded.optionSelected = options.map((o) => Option.copy(o)).toList();
          }
          _optionContext.itemOptions = option.itemOptionSelected;
        });
      },

      choiceItems: C2Choice.listFrom(
        meta: (position, item) {},
        source: option.items,
        value: (i, v) => v,
        label: (i, v) => v.name,
      ),
      choiceBuilder: (_) {
        choiceSelected = _;

        return Consumer<OptionContext>(builder: (context, snapshot, w) {
          return Container(
            // color: _.selected ? CRIMSON : Colors.grey.withAlpha(1),
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                !_.selected
                    ? IconButton(
                        icon: Icon(Icons.add_circle_outlined, color: Colors.grey, size: 25),
                        onPressed: () {
                          if (this.isAdded) return;
                          if (option.isMaxOptions) {
                            _.value.quantity = 1;
                            _.select(!_.selected);
                          } else {
                            print("max options");
                            Fluttertoast.showToast(msg: "maximum selection ${option.title} : ${option.maxOptions}");
                          }
                        },
                      )
                    :
                    //button incrementation

                    Container(
                        padding: EdgeInsets.only(left: 0),
                        // width: 50,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                icon: Icon(
                                  Icons.remove_circle,
                                  color: CRIMSON,
                                  size: 35,
                                ),
                                onPressed: () {
                                  if (this.isAdded) return;
                                  if (_.value.quantity == 1) {
                                    _.value.quantity = 0;
                                    _.select(false);
                                  } else {
                                    _.value.quantity--;
                                    _.select(true);
                                  }
                                  snapshot.refresh();
                                }),
                            SizedBox(
                              width: 2,
                            ),
                            Text(
                              "${_.value.quantity ?? ""}",
                              style: TextStyle(fontSize: 20),
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            IconButton(
                                icon: Icon(Icons.add_circle_outlined, color: CRIMSON, size: 35),
                                onPressed: () {
                                  // if (_optionContext.quantityOptions == option.maxOptions){
                                  if (this.isAdded) return;
                                  if (option.isMaxOptions) {
                                    _.value.quantity++;
                                    _.select(true);
                                    snapshot.refresh();
                                  } else {
                                    print("max options");
                                    Fluttertoast.showToast(msg: "maximum selection ${option.title} : ${option.maxOptions}");
                                  }
                                }),
                          ],
                        ),
                      ),
                SizedBox(
                  width: 10,
                ),
                InkWell(
                  onTap: () {
                    RouteUtil.goTo(
                        context: context,
                        child: PhotoViewPage(
                          tag: 'tag:${_.value.imageUrl}',
                          img: _.value.imageUrl,
                        ),
                        routeName: null);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/images/loading.gif',
                      image: _.value.imageUrl,
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Text("${_.value.name}"),
                Spacer(),
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      // shape: BoxShape.circle,
                      // color: _.value.price == 0 ? null : Colors.grey[400]
                      ),
                  child: !_cartContext.withPrice || _.value.price.amount == null
                      ? Text("")
                      : Text(
                          "${_.value.price.amount == 0 ? '' : _.value.price.amount / 100}${_.value.price.amount == 0 ? '' : "€"}",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                ),
                Spacer(),
              ],
            ),
          );
        });
      },
    );
  }
}
