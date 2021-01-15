import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/components/buttons.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/pages/food.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';

class ButtonItemCountWidget extends StatefulWidget {
  ButtonItemCountWidget(this.food, {@required this.onAdded,this.options,this.onPressed,this.withPrice = true,@required this.onRemoved, @required this.itemCount, this.isFromDelevery = false, @required this.isContains = false, this.isMenu = false,this.fromRestaurant = false})
      : super();
  Function onAdded;
  Function onRemoved;
  Function onPressed;
  int itemCount;
  bool isFromDelevery;
  bool isContains;
  dynamic food;
  bool isMenu;
  bool fromRestaurant;
  bool withPrice;
  List<Option> options;


  @override
  _ButtonItemCountWidgetState createState() => _ButtonItemCountWidgetState();
}

class _ButtonItemCountWidgetState extends State<ButtonItemCountWidget> {
  CartContext _cartContext;
  bool showOptions = false;

  @override
  void initState() {
    super.initState();
    _cartContext = Provider.of<CartContext>(context, listen: false);
    // widget.itemCount = _cartContext.getCount(widget.food);
    // widget.isContains = _cartContext.contains(widget.food);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isContains)
      return CircleButton(
          backgroundColor: TEAL,
          onPressed: () async {
            if (widget.fromRestaurant && widget.food.options.length > 0) {
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
              return;
            }
            if (_cartContext.itemCount != 0) {
              if (!_cartContext.hasSamePricingAsInBag(widget.food)) {
                Fluttertoast.showToast(
                  msg: AppLocalizations.of(context).translate('priceless_and_not_priceless_not_allowed'),
                );
                return;
              } else if (!_cartContext.hasSameOriginAsInBag(widget.food)) {
                Fluttertoast.showToast(
                  msg: AppLocalizations.of(context).translate('from_different_origin_not_allowed'),
                );
                return;
              }
            }

            // widget.onAdded(++widget.itemCount);
            int value = ++widget.itemCount;
            /*if (widget.food.options.isNotEmpty) {
              var optionSelected = await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => OptionChoiceDialog(
                  food: widget.food,
                  withPrice: widget.withPrice,
                ),
              );
              if (optionSelected != null) _cartContext.addItem(widget.food, value, true);
            } else {*/
              _cartContext.addItem(widget.food, value, true);
            //}

          },
          child: FaIcon(
            FontAwesomeIcons.plus,
            color: Colors.white,
            size: 12,
          ));
    return Container(
      decoration: BoxDecoration(
          color: CRIMSON,
          borderRadius: BorderRadius.all(
            Radius.circular(3),
          )),
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: widget.isFromDelevery ? 0 : 0),
        child: Row(
          children: [
            RoundedButton(
              backgroundColor: CRIMSON,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              radius: 0.0,
              child: FaIcon(
                FontAwesomeIcons.minus,
                color: Colors.white,
                size: 12,
              ),
              onPressed: () async { // onRemove
                // widget.onRemoved(--widget.itemCount);
                int value = --widget.itemCount;
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
                    if (!widget.fromRestaurant)
                      RouteUtil.goBack(context: context);
                  }
                } else {
                  _cartContext.addItem(widget.food, value, false);
                }
                // if (value <= 0) {
                //   showOptions = false;
                //   widget.onPressed(false);
                // }
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                padding: EdgeInsets.symmetric(vertical: 6),
                width: 35,
                child: Center(
                  child: TextTranslator(
                    '${widget.itemCount}',
                    style: TextStyle(
                      color: CRIMSON,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            RoundedButton(
              backgroundColor: CRIMSON,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              radius: 0.0,
              child: FaIcon(
                FontAwesomeIcons.plus,
                color: Colors.white,
                size: widget.isFromDelevery ? 12 : 12,
              ),
              onPressed: () async {
                if (widget.fromRestaurant && widget.food.options.length > 0) {
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
                  return;
                }
                if (widget.food.isMenu) return;
                int value = ++widget.itemCount;
                /*if (widget.food.options.isNotEmpty) {
                  var optionSelected = await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => OptionChoiceDialog(
                      food: widget.food,
                      withPrice: widget.withPrice,
                    ),
                  );
                  if (optionSelected != null) _cartContext.addItem(widget.food, value, true);
                } else {*/
                  _cartContext.addItem(widget.food, value, true);
               // }
                // widget.onAdded();
              },
            ),
          ],
        ),
      ),
    );
  }
}
