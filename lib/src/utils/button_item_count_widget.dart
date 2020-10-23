import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/components/buttons.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:provider/provider.dart';

class ButtonItemCountWidget extends StatefulWidget {
  ButtonItemCountWidget(this.food,
      {@required this.onAdded,
      @required this.onRemoved,
      @required this.itemCount,
      this.isFromDelevery = false,
      @required this.isContains = false})
      : super();
  Function onAdded;
  Function onRemoved;
  int itemCount;
  bool isFromDelevery;
  bool isContains;
  Food food;

  @override
  _ButtonItemCountWidgetState createState() => _ButtonItemCountWidgetState();
}

class _ButtonItemCountWidgetState extends State<ButtonItemCountWidget> {
  CartContext _cartContext;

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
          onPressed: () {
            if (!_cartContext.hasSamePricingAsInBag(widget.food)) {
              Fluttertoast.showToast(
                msg: AppLocalizations.of(context)
                    .translate('priceless_and_not_priceless_not_allowed'),
              );
            } else if (!_cartContext.hasSameOriginAsInBag(widget.food)) {
              Fluttertoast.showToast(
                msg: AppLocalizations.of(context)
                    .translate('from_different_origin_not_allowed'),
              );
            }else{
              widget.onAdded(++widget.itemCount);
            }
            
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
        padding:
            EdgeInsets.symmetric(horizontal: widget.isFromDelevery ? 0 : 0),
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
              onPressed: () {
                widget.onRemoved(--widget.itemCount);
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
                  child: Text(
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
              onPressed: () {
                widget.onAdded(++widget.itemCount);
              },
            ),
          ],
        ),
      ),
    );
  }
}
