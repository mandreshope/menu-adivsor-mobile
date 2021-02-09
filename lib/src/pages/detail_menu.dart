import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu_advisor/src/components/buttons.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/components/menu_item_food_option.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/providers/MenuContext.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/button_item_count_widget.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';
import 'package:menu_advisor/src/utils/extensions.dart';

class DetailMenu extends StatefulWidget {
  Menu menu;

  DetailMenu({@required this.menu});

  @override
  _DetailMenuState createState() => _DetailMenuState();
}

class _DetailMenuState extends State<DetailMenu> {
  // MenuContext _controller;
  CartContext _cartContext;
  // int count = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.menu.idNewFood = DateTime.now().millisecondsSinceEpoch.toString();

  }

  @override
  Widget build(BuildContext context) {
    widget.menu.foodsGrouped = widget.menu.foods ?? List();
    _cartContext = Provider.of<CartContext>(context, listen: false);
    // count = _cartContext.getCount(widget.menu);
    widget.menu.count = _cartContext.getFoodCountByIdNew(widget.menu);


    return Scaffold(
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
        title: TextTranslator(widget.menu.name),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child:
                Column(
                  children: [
                    _renderHeaderPicture(),
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
                              child:
                              !_cartContext.withPrice ? Text("") : Text(
                                '${widget.menu.price.amount / 100} €',
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
                    _renderListPlat(context),
                    _renderAddMenu(),
                    SizedBox(height: 50,),
                    _cartContext.getFoodCountByIdNew(widget.menu) > 0 ?
                    SizedBox(height: 50,) : Container()
                  ],

            ),
          ),
          Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Consumer<CartContext>(
                builder: (_, cartContext, __) => widget.menu.count > 0
                    ? OrderButton(
                  totalPrice: _cartContext.totalPrice,
                )
                    : SizedBox(),
              )),
        ],
      ),
    );
  }

  Widget _renderHeaderPicture() => Stack(
        children: [
          Hero(
            tag: widget.menu.id,
            child: widget.menu.imageURL != null
                ? Image.network(
                    widget.menu.imageURL,
                    width: MediaQuery.of(context).size.width,
                    height: 250,
                    fit: BoxFit.contain,
                  )
                : Icon(
                    Icons.fastfood,
                    size: 250,
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
              ))
        ],
      );

  Widget _renderListPlat(context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
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
                for (var food in entry.value) ...[
                  Consumer<CartContext>(builder: (context, menuContext, w) {
                    return InkWell(
                      onTap: () {
                        // if (_cartContext.contains(widget.menu)){
                        if (widget.menu.count == 0) {
                          widget.menu.setFoodMenuSelected(entry.key, food);
                          widget.menu.select(
                              _cartContext, entry.key, food,()=>menuContext.refresh());
                        } else {
                          // Fluttertoast.showToast(
                          //     msg: "Veuillez ajouter le menu dans le panier");
                        }
                      },
                      child: Card(
                        elevation: 2,
                        child: Container(
                          margin: EdgeInsets.all(15),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Radio<String>(
                                    value: widget.menu
                                        .selectedMenu[entry.key]?.first?.id,
                                    groupValue: food.id,
                                    onChanged: (value) {
                                      print("food selected");
                                      if (_cartContext.contains(widget.menu))
                                        _cartContext
                                            .foodMenuSelected[entry.key] = food;
                                    },
                                    activeColor: CRIMSON,
                                    hoverColor: CRIMSON,
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: FadeInImage.assetNetwork(
                                      placeholder: 'assets/images/loading.gif',
                                      image: food.imageURL,
                                      height: 25,
                                      width: 25,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 6,
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: TextTranslator(
                                      food.name,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  if (widget.menu.type ==
                                      MenuType.fixed_price.value) ...[
                                    Text(" ")
                                  ] else if (widget.menu.type ==
                                      MenuType.fixed_price.value) ...[
                                    Text(" ")
                                  ] else ...[
                                    food?.price?.amount == null
                                        ? Text("")
                                        : Text("${food.price.amount / 100} €",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                  ]
                                ],
                              ),
                              if (widget.menu
                                      .selectedMenu[entry.key]?.first?.id ==
                                  food.id) ...[
                                MenuItemFoodOption(
                                    food: food,
                                    menu: widget.menu,
                                    withPrice: _cartContext.withPrice,
                                    subMenu: entry.key)
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

    return Consumer<CartContext>(
      builder: (_,cart,w){
        widget.menu.count = _cartContext.getFoodCountByIdNew(widget.menu);
        return widget.menu.count > 0 ?
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ButtonItemCountWidget(
                    widget.menu,
                    onAdded: (){
                      widget.menu.count++;
                      _cartContext.addItem(widget.menu, 1, true);
                      setState(() {

                      });
                    },
                    onRemoved: (){
                      widget.menu.count--;
                      _cartContext.addItem(widget.menu, 1, false);
                      setState(() {

                      });
                    }, itemCount: _cartContext.getFoodCountByIdNew(widget.menu), isContains: cart.contains(widget.menu)),
              ],
            ) :
        RaisedButton(
          padding: EdgeInsets.all(20),
          color: widget.menu.count > 0 ? Colors.teal : CRIMSON,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          onPressed: () async {
            if ((widget.menu.count > 0) ||
                (_cartContext.hasSamePricingAsInBag(widget.menu) &&
                    _cartContext.hasSameOriginAsInBag(widget.menu))) {
              if (widget.menu.count > 0) {
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
                  _cartContext.removeItem(widget.menu);
                  RouteUtil.goBack(context: context);
                }
              } else {
                widget.menu.count++;
                _cartContext.addItem(widget.menu, 1, true);
              }
            } else if (!_cartContext.hasSamePricingAsInBag(widget.menu)) {
              Fluttertoast.showToast(
                msg: AppLocalizations.of(context)
                    .translate('priceless_and_not_priceless_not_allowed'),
              );
            } else if (!_cartContext.hasSameOriginAsInBag(widget.menu)) {
              Fluttertoast.showToast(
                msg: AppLocalizations.of(context)
                    .translate('from_different_origin_not_allowed'),
              );
            } else {
              widget.menu.count++;
              _cartContext.addItem(widget.menu, 1, true);
            }
            // setState(() {});
          },
          child: TextTranslator(
            widget.menu.count > 0
                ? AppLocalizations.of(context).translate('remove_from_cart')
                : AppLocalizations.of(context).translate("add_to_cart"),
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        );
      },
    );

  }
}
