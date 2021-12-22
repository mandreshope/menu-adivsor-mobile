import 'dart:async';

import 'package:expandable/expandable.dart';
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
import 'package:menu_advisor/src/utils/price_formated.dart';
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

  StreamController<bool> _streamController = StreamController();
  StreamSink<bool> get isTransparentSink => _streamController.sink;
  Stream<bool> get isTransparentStream =>
      _streamController.stream.asBroadcastStream();

  ScrollController _scrollController;
  bool isContains = false;

  Restaurant restaurant;
  bool loading = false;

  List<MenuFood> menuFoods = [];

  _scrollListener() {
    double offset = _scrollController.offset;
    if (offset <= 50) {
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

    menuFoods = widget.menu.foods.map((e) => MenuFood.copy(e)).toList();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _scrollController.addListener(_scrollListener);
      if (widget.menu.restaurant is String) {
        setState(() {
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
                      Container(
                          margin: EdgeInsets.only(left: 15),
                          child: _renderTitlePlat(context)),
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
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.black),
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
                            if (widget.menu.price != null &&
                                widget.menu.price?.amount != null)
                              Positioned(
                                right: 25,
                                child: !_cartContext.withPrice ||
                                        widget.menu.type ==
                                            MenuType.priceless.value
                                    ? Text("")
                                    : Consumer<CartContext>(
                                        builder: (context, snapshot, _) {
                                        return Text(
                                          widget.menu.type ==
                                                      MenuType.per_food.value ||
                                                  widget.menu.price?.amount ==
                                                      null
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
                        padding: const EdgeInsets.only(
                            left: 15.0, top: 8.0, bottom: 8.0, right: 15.0),
                        child: TextTranslator(widget.menu.description,
                            style: TextStyle(fontSize: 18)),
                      ),
                      Divider(),
                      _renderListPlat(context),
                      menuFoods.isEmpty ? Container() : _renderAddMenu(),
                      SizedBox(
                        height: 50,
                      ),
                    ],
                  ),
                ),
                menuFoods.isNotEmpty
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
                          child: Consumer<CartContext>(
                              builder: (_, cartContext, __) {
                            return Container(
                              color: (_cartContext.hasMenuObligatorySelected(
                                      widget.menu, menuFoods))
                                  ? CRIMSON
                                  : Colors.grey,
                              width: double.infinity,
                              height: 45,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  TextButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                        Colors.transparent,
                                      ),
                                      shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                    onPressed: () async {
                                      if (!cartContext
                                          .hasSamePricingAsInBag(widget.menu)) {
                                        showDialog(
                                          context: context,
                                          builder: (_) => ConfirmationDialog(
                                            title: "",
                                            isSimple: true,
                                            content: AppLocalizations.of(
                                                    context)
                                                .translate(
                                                    'priceless_and_not_priceless_not_allowed'),
                                          ),
                                        ).then((value) {
                                          if (value) {
                                            _cartContext.clear();
                                            _cartContext.addItem(
                                                widget.menu, 1, true);
                                            setState(() {});
                                            RouteUtil.goBack(context: context);
                                          }
                                        });
                                      } else if (!cartContext
                                          .hasSameOriginAsInBag(widget.menu)) {
                                        showDialog(
                                          context: context,
                                          builder: (_) => ConfirmationDialog(
                                            title: "",
                                            isSimple: true,
                                            content: AppLocalizations.of(
                                                    context)
                                                .translate(
                                                    'from_different_origin_not_allowed'),
                                          ),
                                        ).then((value) {
                                          if (value) {
                                            _cartContext.clear();
                                            _cartContext.addItem(
                                                widget.menu, 1, true);
                                            setState(() {});
                                            RouteUtil.goBack(context: context);
                                          }
                                        });
                                      } else {
                                        if (cartContext
                                            .hasMenuObligatorySelected(
                                                widget.menu, menuFoods)) {
                                          _cartContext.addItem(
                                              widget.menu, 1, true);
                                          RouteUtil.goBack(context: context);
                                        } else
                                          Fluttertoast.showToast(
                                            msg:
                                                'Ajouter au moin un menu obligatoire et une option',
                                          );
                                      }
                                    },
                                    child: TextTranslator(
                                      AppLocalizations.of(context)
                                              .translate("add_to_cart") +
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

  Widget _renderTitlePlat(context) {
    String name = "";
    for (var menuFood in menuFoods) name += menuFood.title + " + ";
    return TextTranslator(
      name.isEmpty ? name : name.substring(0, name.length - 2),
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    );
  }

  Widget _renderListPlat(context) {
    return menuFoods.isEmpty
        ? Container()
        : Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(0),
            ),
            margin: EdgeInsets.all(15),
            padding: EdgeInsets.all(25),
            child: Column(
              children: [
                for (var menuFood in menuFoods)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextTranslator(
                            menuFood.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (menuFood.isObligatory)
                            Text(
                              "*",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            )
                        ],
                      ),
                      TextTranslator(
                        "Choisissez-en jusqu'à ${menuFood.maxOptions}",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Divider(),
                      for (final food in menuFood.foods) ...[
                        ExpandableNotifier(
                          child: Column(
                            children: <Widget>[
                              ScrollOnExpand(
                                scrollOnExpand: true,
                                scrollOnCollapse: false,
                                child: ExpandablePanel(
                                  controller: food.expandableController,
                                  theme: ExpandableThemeData(
                                    headerAlignment:
                                        ExpandablePanelHeaderAlignment.center,
                                    tapBodyToCollapse: true,
                                    hasIcon: false,
                                    tapHeaderToExpand: false,
                                    tapBodyToExpand: false,
                                  ),
                                  header: Consumer<CartContext>(
                                      builder: (context, menuContext, w) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              RouteUtil.goTo(
                                                  context: context,
                                                  child: PhotoViewPage(
                                                    tag: 'tag:${food.imageURL}',
                                                    img: food.imageURL,
                                                  ),
                                                  routeName: null);
                                            },
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(0),
                                              child: FadeInImage.assetNetwork(
                                                placeholder:
                                                    'assets/images/loading.gif',
                                                image: food.imageURL,
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
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                6,
                                          ),
                                          Align(
                                            alignment: Alignment.center,
                                            child: TextTranslator(
                                              food.name,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          if (widget.menu.type ==
                                                  MenuType.fixed_price.value &&
                                              _cartContext.withPrice) ...[
                                            Spacer(),
                                            food?.price?.amount == null
                                                ? Text("")
                                                : Text(
                                                    priceFormated(
                                                        food.price.amount /
                                                            100),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                          ] else if (widget.menu.type ==
                                              MenuType.priceless.value) ...[
                                            Text(" ")
                                          ] else ...[
                                            Spacer(),
                                            if (_cartContext.withPrice)
                                              food?.price?.amount == null
                                                  ? Text("")
                                                  : Text(
                                                      priceFormated(
                                                          food.price.amount /
                                                              100),
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                          ],
                                          Spacer(),
                                          IconButton(
                                            icon: menuFood.maxOptions == 1
                                                ? Icon(
                                                    food.isSelected
                                                        ? Icons.radio_button_on
                                                        : Icons
                                                            .radio_button_off,
                                                    color: food.isSelected
                                                        ? CRIMSON
                                                        : Colors.grey,
                                                  )
                                                : Icon(
                                                    food.isSelected
                                                        ? Icons.check_box
                                                        : Icons
                                                            .check_box_outline_blank,
                                                    color: food.isSelected
                                                        ? CRIMSON
                                                        : Colors.grey,
                                                  ),
                                            onPressed: () {
                                              print("$logTrace food selected");
                                              setState(() {
                                                food.isSelected =
                                                    !food.isSelected;
                                                food.expandableController
                                                        .expanded =
                                                    !food.expandableController
                                                        .expanded;
                                              });
                                              if (menuFood.isMaxOptions) {
                                                widget.menu.setFoodMenuSelected(
                                                  menuFood.sId,
                                                  food,
                                                  menuFood.foods,
                                                );
                                                widget.menu.select(
                                                  _cartContext,
                                                  menuFood.sId,
                                                  food,
                                                  () => menuContext.refresh(),
                                                );
                                              } else {
                                                food.isSelected = false;
                                                menuContext.refresh();
                                                print("$logTrace max options");
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "maximum selection ${menuFood.title} : ${menuFood.maxOptions}");
                                              }
                                              if (!food.expandableController
                                                  .expanded) {
                                                food?.optionSelected
                                                    ?.forEach((option) {
                                                  option.itemOptionSelected
                                                      .clear();
                                                  option.singleItemOptionSelected =
                                                      null;
                                                  menuContext.refresh();
                                                });
                                              }

                                              setState(() {});
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  collapsed: Container(),
                                  expanded: Consumer<CartContext>(
                                      builder: (context, menuContext, w) {
                                    return MenuItemFoodOption(
                                      food: food,
                                      menu: widget.menu,
                                      withPrice: _cartContext.withPrice,
                                      subMenu: menuFood.title,
                                    );
                                  }),
                                  builder: (_, collapsed, expanded) {
                                    return Expandable(
                                      collapsed: collapsed,
                                      expanded: expanded,
                                      theme: const ExpandableThemeData(
                                          crossFadePoint: 0),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
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
        Consumer<CartContext>(builder: (_, cartContext, __) {
          if (widget.menu.quantity <= 0) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              showDialog(
                context: context,
                builder: (_) => ConfirmationDialog(
                  title: AppLocalizations.of(context)
                      .translate('confirm_remove_from_cart_title'),
                  content: AppLocalizations.of(context)
                      .translate('confirm_remove_from_cart_content'),
                ),
              ).then((result) {
                if (result is bool && result) {
                  RouteUtil.goBack(context: context);
                } else {
                  widget.menu.quantity = 1;
                  cartContext.refresh();
                }
              });
            });
          }
          return _cartContext.hasMenuObligatorySelected(widget.menu, menuFoods)
              ? ButtonItemCountWidget(
                  widget.menu,
                  onAdded: () async {
                    cartContext.refresh();
                  },
                  onRemoved: () {
                    cartContext.refresh();
                  },
                  itemCount: widget.menu.quantity,
                  isContains: _cartContext.hasMenuObligatorySelected(
                      widget.menu, menuFoods),
                  isSmal: false,
                )
              : Container();
        })
      ],
    );
  }
}
