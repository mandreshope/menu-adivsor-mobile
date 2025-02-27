import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/components/buttons.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/constants/constant.dart';
import 'package:menu_advisor/src/models/models.dart';
import 'package:menu_advisor/src/pages/food.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ButtonItemCountWidget extends StatefulWidget {
  ButtonItemCountWidget(
    this.food, {
    @required this.onAdded,
    this.options,
    this.isSmal = true,
    this.onPressed,
    this.withPrice = true,
    @required this.onRemoved,
    @required this.itemCount,
    this.isFromDelevery = false,
    this.isContains = false,
    this.isMenu = false,
    this.fromRestaurant = false,
  }) : super();
  final Function onAdded;
  final Function onRemoved;
  final Function onPressed;
  int itemCount;
  final bool isFromDelevery;
  final bool isContains;
  final dynamic food;
  final bool isMenu;
  final bool fromRestaurant;
  final bool withPrice;
  final List<Option> options;
  final int quantity = 0;
  final bool isSmal;

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
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isContains)
      return CircleButton(
          backgroundColor: TEAL,
          onPressed: () async {
            if (widget.fromRestaurant && (widget.food is Food)) {
              RouteUtil.goTo(
                context: context,
                child: Material(
                  child: FoodPage(
                    food: widget.food,
                  ),
                ),
                routeName: foodRoute,
              );
              return;
            }
            if (_cartContext.itemCount != 0) {
              if (!_cartContext.hasSamePricingAsInBag(widget.food)) {
                Fluttertoast.showToast(
                  msg: AppLocalizations.of(context)
                      .translate('priceless_and_not_priceless_not_allowed'),
                );
                return;
              } else if (!_cartContext.hasSameOriginAsInBag(widget.food)) {
                Fluttertoast.showToast(
                  msg: AppLocalizations.of(context)
                      .translate('from_different_origin_not_allowed'),
                );
                return;
              }
            }
            int value = ++widget.itemCount;
            _cartContext.addItem(widget.food, value, true);
          },
          child: FaIcon(
            FontAwesomeIcons.plus,
            color: Colors.white,
            size: 12,
          ));
    return Container(
      height: widget.isSmal ? 35 : 65,
      decoration: BoxDecoration(
          color: !widget.isSmal ? Colors.transparent : CRIMSON,
          borderRadius: BorderRadius.all(
            Radius.circular(3),
          )),
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: widget.isFromDelevery ? 0 : 0),
        child: Row(
          children: [
            RoundedButton(
              backgroundColor: CRIMSON,
              padding: widget.isSmal
                  ? EdgeInsets.symmetric(horizontal: 10, vertical: 6)
                  : EdgeInsets.symmetric(horizontal: 25, vertical: 6),
              radius: widget.isSmal ? 0.0 : 35.0,
              child: FaIcon(
                FontAwesomeIcons.minus,
                color: Colors.white,
                size: 12,
              ),
              onPressed: () async {
                print("$logTrace FOOD QUANTITY DECREMENT");
                widget.food.quantity--;
                widget.onRemoved();
              },
            ),
            SizedBox(
              width: widget.isSmal ? 0 : 12,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.isSmal ? Colors.white : Colors.transparent,
                ),
                padding: EdgeInsets.symmetric(vertical: 6),
                width: 35,
                child: Center(
                  child: TextTranslator(
                    '${widget.itemCount}',
                    style: TextStyle(
                        color: CRIMSON,
                        fontWeight: FontWeight.bold,
                        fontSize: widget.isSmal ? 14 : 25),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: widget.isSmal ? 0 : 12,
            ),
            RoundedButton(
              backgroundColor: CRIMSON,
              padding: widget.isSmal
                  ? EdgeInsets.symmetric(horizontal: 10, vertical: 6)
                  : EdgeInsets.symmetric(horizontal: 25, vertical: 6),
              radius: widget.isSmal ? 0.0 : 35.0,
              child: FaIcon(
                FontAwesomeIcons.plus,
                color: Colors.white,
                size: widget.isFromDelevery ? 12 : 12,
              ),
              onPressed: () async {
                print("$logTrace FOOD QUANTITY INCREMENT");
                widget.food.quantity++;
                widget.onAdded();
              },
            ),
          ],
        ),
      ),
    );
  }
}
