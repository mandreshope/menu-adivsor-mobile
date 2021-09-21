import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/components/menu_item_food_option.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/constants/constant.dart';
import 'package:menu_advisor/src/models/models.dart';
import 'package:menu_advisor/src/pages/photo_view.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/button_item_count_widget.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';
import 'package:menu_advisor/src/utils/extensions.dart';

class DetailMenu extends StatefulWidget {
  final Menu menu;

  DetailMenu({@required this.menu});

  @override
  _DetailMenuState createState() => _DetailMenuState();
}

class _DetailMenuState extends State<DetailMenu> {
  // MenuContext _controller;
  CartContext _cartContext;
  // int count = 0;
  Food _food;

  StreamController<bool> _streamController = StreamController();
  StreamSink<bool> get isTransparentSink => _streamController.sink;
  Stream<bool> get isTransparentStream => _streamController.stream.asBroadcastStream();

  ScrollController _scrollController;
  bool isContains = false;

  Restaurant restaurant;
  bool loading = false;

  _scrollListener() {
    double offset = _scrollController.offset;
    if (offset <= 50) {
      // print("offset $offset");
      isTransparentSink.add(true);
    } else {
      isTransparentSink.add(false);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(_scrollListener);
    _streamController.close();
    isTransparentSink.close();
  }

  @override
  void initState() {
    super.initState();
    _init();
    print("$logTrace type ${widget.menu.type}");
  }

  _init() {
    _scrollController = ScrollController();
    widget.menu.idNewFood = DateTime.now().millisecondsSinceEpoch.toString();
    _cartContext = Provider.of<CartContext>(context, listen: false);
    _cartContext.itemsTemp.clear();

    // sort menu type by priority
    // widget.menu.foods.sort((a, b) => a.food.type.priority.compareTo(b.food.type.priority));
    widget.menu.foodsGrouped = widget.menu.foods ?? [];
    widget.menu.count = _cartContext.getFoodCountByIdNew(widget.menu);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _scrollController.addListener(_scrollListener);
      if (widget.menu.restaurant is String) {
        setState(() {
          // restaurant = res;
          loading = true;
        });
        Api.instance
            .getRestaurant(
          id: widget.menu.restaurant,
          lang: Provider.of<SettingContext>(
            context,
            listen: false,
          ).languageCode,
        )
            .then((res) {
          if (!mounted) return;

          setState(() {
            restaurant = res;
            loading = false;
          });
        }).catchError((error) {
          print(error.toString());
          Fluttertoast.showToast(
            msg: AppLocalizations.of(context).translate('connection_error'),
          );
          setState(() {
            loading = false;
          });
        });
      }
      // else{
      //   setState(() {
      //     loading = false;
      //   });
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: TextTranslator(widget.menu.name),
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  CRIMSON,
                ),
              ),
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 25,
                      ),
                      Container(margin: EdgeInsets.only(left: 15), child: _renderTitlePlat(context)),
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
                            if (widget.menu.price != null && widget.menu.price?.amount != null)
                              Positioned(
                                right: 25,
                                child: !_cartContext.withPrice || widget.menu.type == MenuType.priceless.value
                                    ? Text("")
                                    : Consumer<CartContext>(builder: (context, snapshot, _) {
                                        return Text(
                                          widget.menu.type == MenuType.per_food.value || widget.menu.price?.amount == null
                                              ? '${widget.menu.totalPrice / 100} €'
                                              : '${widget.menu.price.amount / 100} €',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.black,
                                          ),
                                        );
                                      }),
                              ),
                          ],
                        ),
                      ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0, top: 8.0, bottom: 8.0, right: 15.0),
                        child: TextTranslator(widget.menu.description, style: TextStyle(fontSize: 18)),
                      ),
                      Divider(),
                      _renderListPlat(context),
                      widget.menu.foods.isEmpty ? Container() : _renderAddMenu(),
                      SizedBox(
                        height: 50,
                      ),
                      Consumer<CartContext>(
                        builder: (_, cart, w) {
                          return cart.getFoodCountByIdNew(widget.menu) > 0
                              ? SizedBox(
                                  height: 150,
                                )
                              : Container();
                        },
                      )
                    ],
                  ),
                ),
                widget.menu.foods.isNotEmpty
                    ? Container()
                    : Align(
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _renderAddMenu(),
                            SizedBox(
                              height: 75,
                            )
                          ],
                        )),
                //addd to panier
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      // vertical: 20,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Consumer<CartContext>(builder: (_, cartContext, __) {
                            widget.menu.count = _cartContext.getFoodCountByIdNew(widget.menu);
                            return Container(
                              color: widget.menu.foodMenuSelecteds.isEmpty || !_cartContext.hasOptionSelectioned(_food) ? Colors.grey : CRIMSON,
                              width: double.infinity,
                              height: 45,
                              child:
                                  /*  */

                                  Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  TextButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(
                                        Colors.transparent,
                                      ),
                                      shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                    onPressed: () async {
                                      // if (!restaurant.isOpen) {
                                      //   Fluttertoast.showToast(
                                      //     msg: 'Restaurant fermé',
                                      //   );
                                      //   return;
                                      // }

                                      if (!cartContext.hasSamePricingAsInBag(widget.menu)) {
                                        showDialog(
                                          context: context,
                                          builder: (_) => ConfirmationDialog(
                                            title: "",
                                            isSimple: true,
                                            content: AppLocalizations.of(context).translate('priceless_and_not_priceless_not_allowed'),
                                          ),
                                        ).then((value) {
                                          if (value) {
                                            _cartContext.clear();
                                            _cartContext.addItem(widget.menu, 1, true);
                                            setState(() {});
                                            RouteUtil.goBack(context: context);
                                          }
                                        });
                                        // Fluttertoast.showToast(
                                        //   msg: AppLocalizations.of(context).translate('priceless_and_not_priceless_not_allowed'),
                                        // );
                                      } else if (!cartContext.hasSameOriginAsInBag(widget.menu)) {
                                        showDialog(
                                          context: context,
                                          builder: (_) => ConfirmationDialog(
                                            title: "",
                                            isSimple: true,
                                            content: AppLocalizations.of(context).translate('from_different_origin_not_allowed'),
                                          ),
                                        ).then((value) {
                                          if (value) {
                                            _cartContext.clear();
                                            _cartContext.addItem(widget.menu, 1, true);
                                            setState(() {});
                                            RouteUtil.goBack(context: context);
                                          }
                                        });
                                        // Fluttertoast.showToast(
                                        //   msg: AppLocalizations.of(context).translate('from_different_origin_not_allowed'),
                                        // );
                                      } else {
                                        if (cartContext.hasOptionSelectioned(_food)) {
                                          _cartContext.addItem(widget.menu, 1, true);
                                          // setState(() {});
                                          RouteUtil.goBack(context: context);
                                        } else
                                          Fluttertoast.showToast(
                                            msg: 'Ajouter une option',
                                          );
                                        //}
                                      }
                                    },
                                    child: TextTranslator(
                                      AppLocalizations.of(context).translate("add_to_cart") +
                                          '\t\t${widget.menu.quantity == 0 || !cartContext.withPrice || widget.menu.type == MenuType.priceless.value ? "" : widget.menu.totalPrice / 100}' +
                                          '${(widget.menu.quantity == 0 || !cartContext.withPrice || widget.menu.type == MenuType.priceless.value ? "" : "€")}',
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _renderHeaderPicture() => Stack(
        children: [
          InkWell(
            onTap: () {
              RouteUtil.goTo(
                  context: context,
                  child: PhotoViewPage(
                    tag: widget.menu.id,
                    img: widget.menu.imageURL,
                  ),
                  routeName: null);
            },
            // child: Hero(
            //   tag: widget.menu.id,
            child: widget.menu.imageURL != null
                ? Image.network(
                    widget.menu.imageURL,
                    width: MediaQuery.of(context).size.width,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Icon(
                        Icons.fastfood,
                        size: 250,
                      ),
                    ),
                  )
                : Icon(
                    Icons.fastfood,
                    size: 250,
                  ),
          ),
          // )

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
                        widget.menu.name,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ))*/
        ],
      );

  Widget _renderTitlePlat(context) {
    String name = "";
    for (var entry in widget.menu.foodsGrouped.entries) name += entry.key + " + ";
    return TextTranslator(
      name.isEmpty ? name : name.substring(0, name.length - 2),
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    );
  }

  Widget _renderListPlat(context) {
    return widget.menu.foods.isEmpty
        ? Container()
        : Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(0)),
            margin: EdgeInsets.all(15),
            padding: EdgeInsets.all(25),
            child: Column(
              children: [
                for (var entry in widget.menu.foodsGrouped.entries)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 15,
                      ),
                      TextTranslator(
                        entry.key,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Divider(),
                      for (var menuFood in entry.value) ...[
                        Consumer<CartContext>(builder: (context, menuContext, w) {
                          return InkWell(
                            onTap: () {
                              // if (_cartContext.contains(widget.menu)){
                              if (widget.menu.count == 0 || widget.menu.count == 1) {
                                widget.menu.setFoodMenuSelected(entry.key, menuFood.food);
                                _food = menuFood.food;
                                widget.menu.select(_cartContext, entry.key, menuFood.food, () => menuContext.refresh());
                                if (widget.menu.count == 0) {
                                  widget.menu.count++;
                                  // _cartContext.addItem(widget.menu, 1, true);
                                }
                              } else {
                                // Fluttertoast.showToast(
                                //     msg: "Veuillez ajouter le menu dans le panier");
                              }
                            },
                            child: Card(
                              elevation: 2,
                              child: Container(
                                // margin: EdgeInsets.all(15),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            RouteUtil.goTo(
                                                context: context,
                                                child: PhotoViewPage(
                                                  tag: 'tag:${menuFood.food.imageURL}',
                                                  img: menuFood.food.imageURL,
                                                ),
                                                routeName: null);
                                          },
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(0),
                                            child: FadeInImage.assetNetwork(
                                              placeholder: 'assets/images/loading.gif',
                                              image: menuFood.food.imageURL,
                                              imageErrorBuilder: (_, o, s) {
                                                return Container(
                                                  width: 75,
                                                  height: 75,
                                                  color: Colors.white,
                                                );
                                              },
                                              height: 75,
                                              width: 75,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width / 6,
                                        ),
                                        Align(
                                          alignment: Alignment.center,
                                          child: TextTranslator(
                                            menuFood.food.name,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        if (widget.menu.type == MenuType.fixed_price.value && _cartContext.withPrice) ...[
                                          Spacer(),
                                          if (menuFood.food.additionalPrice.amount != null) ...[
                                            menuFood.food.additionalPrice.amount == 0
                                                ? Text("")
                                                : Text("+ ${(menuFood.food.additionalPrice.amount / 100)} €", style: TextStyle(fontWeight: FontWeight.bold))
                                          ],
                                        ] else if (widget.menu.type == MenuType.priceless.value) ...[
                                          Text(" ")
                                        ] else ...[
                                          Spacer(),
                                          if (_cartContext.withPrice)
                                            menuFood.food?.price?.amount == null ? Text("") : Text("${menuFood.food.price.amount / 100} €", style: TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                        Spacer(),
                                        IconButton(
                                            icon: Icon(
                                              widget.menu.selectedMenu[entry.key]?.first?.id != menuFood.food.id ? Icons.check_box_outline_blank : Icons.check_box,
                                              color: widget.menu.selectedMenu[entry.key]?.first?.id != menuFood.food.id ? Colors.grey : CRIMSON,
                                            ),
                                            onPressed: () {
                                              print("$logTrace food selected");
                                              /*                                          if (_cartContext.contains(widget.menu)){
                                               _cartContext.foodMenuSelected[entry.key] = food;
                                               _food = food;
                                              }*/
                                              if (widget.menu.count == 0 || widget.menu.count == 1) {
                                                widget.menu.setFoodMenuSelected(entry.key, menuFood.food);
                                                _food = menuFood.food;
                                                widget.menu.select(_cartContext, entry.key, menuFood.food, () => menuContext.refresh());
                                                if (widget.menu.count == 0) {
                                                  widget.menu.count++;
                                                  // _cartContext.addItem(widget.menu, 1, true);
                                                }
                                              } else {
                                                // Fluttertoast.showToast(
                                                //     msg: "Veuillez ajouter le menu dans le panier");
                                              }
                                            }),
                                      ],
                                    ),
                                    if (widget.menu.selectedMenu[entry.key]?.first?.id == menuFood.food.id) ...[
                                      MenuItemFoodOption(
                                        food: menuFood.food,
                                        menu: widget.menu,
                                        withPrice: _cartContext.withPrice,
                                        subMenu: entry.key,
                                      )
                                      // Container()
                                    ] else
                                      Container()
                                  ],
                                ),
                              ),
                            ),
                          );
                        })
                      ]
                    ],
                  )
              ],
            ),
          );
  }

  Widget _renderAddMenu() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        /* if (showFavorite)
                          SizedBox(
                            width: 20,
                          ),*/
        Consumer<CartContext>(builder: (_, cartContext, __) {
          // widget.menu.count = widget.menu.quantity;

          // if (widget.menu.quantity == 0) {
          if (widget.menu.quantity <= 0) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              showDialog(
                context: context,
                builder: (_) => ConfirmationDialog(
                  title: AppLocalizations.of(context).translate('confirm_remove_from_cart_title'),
                  content: AppLocalizations.of(context).translate('confirm_remove_from_cart_content'),
                ),
              ).then((result) {
                if (result is bool && result) {
                  // _cartContext.removeAllFood(widget.food);
                  // _cartContext.removeItemAtPosition(widget.position);
                  // if (!widget.fromRestaurant)
                  // RouteUtil.goBack(context: context);
                  RouteUtil.goBack(context: context);
                } else {
                  widget.menu.quantity = 1;
                  cartContext.refresh();
                }
              });
            });

            // _cartContext.addItem(widget.food, 0, false);
            // if(_cartContext.items.length == 0){
            //   // RouteUtil.goBack(context: context);
            // }

          }
          return widget.menu.foodMenuSelecteds.isEmpty || !_cartContext.hasOptionSelectioned(_food)
              ? Container()
              : ButtonItemCountWidget(
                  widget.menu,
                  onAdded: () async {
                    // setState(() {
                    //  ++ widget.menu.count;
                    // widget.menu.quantity = widget.menu.count;
                    // if(widget.menu.count > 1)
                    // this.isAdded = true;
                    // else
                    // this.isAdded = false;
                    // });
                    cartContext.refresh();
                  },
                  onRemoved: () {
                    // setState(() {
                    // -- widget.menu.count;
                    // widget.menu.quantity = widget.menu.count;
                    // if (widget.menu.count <= 0) {
                    //   widget.menu.count = 0;
                    //   this.isAdded = false;
                    //   _init();
                    // }else if (itemCount == 1){
                    //   this.isAdded = false;
                    // }
                    // });
                    cartContext.refresh();
                  },
                  itemCount: widget.menu.quantity,
                  isContains: !(widget.menu.foodMenuSelecteds.isEmpty || !_cartContext.hasOptionSelectioned(_food)),
                  isSmal: false,
                );
        })
      ],
    );
  }
}
