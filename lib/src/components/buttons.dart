import 'package:flutter/material.dart';
import 'package:menu_advisor/src/components/cards.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/pages/order.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';

import 'dialogs.dart';

class RoundedButton extends StatelessWidget {
  /// The child of the rounded button
  final Widget child;

  final VoidCallback onPressed;

  final Color backgroundColor;

  final List<BoxShadow> boxShadow;

  final EdgeInsets padding;

  final double radius;

  const RoundedButton({Key key, @required this.child, @required this.onPressed, this.backgroundColor = Colors.white, this.boxShadow, this.padding, this.radius = 50.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Material(
        type: MaterialType.button,
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        child: InkWell(
          child: Container(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              boxShadow: boxShadow,
            ),
            child: Center(
              child: child,
            ),
          ),
          onTap: onPressed,
        ),
      ),
    );
  }
}

class CircleButton extends StatelessWidget {
  final Color backgroundColor;

  final EdgeInsets padding;

  final Widget child;

  final VoidCallback onPressed;

  final BoxBorder border;

  const CircleButton({
    Key key,
    this.backgroundColor,
    this.padding,
    @required this.child,
    @required this.onPressed,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.button,
      color: backgroundColor,
      shape: CircleBorder(),
      child: InkWell(
        child: Container(
          padding: padding ?? const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: border,
          ),
          child: Center(
            child: child,
          ),
        ),
        onTap: onPressed,
      ),
    );
  }
}

class OrderButton extends StatelessWidget {
  const OrderButton({Key key, this.totalPrice, this.fromModal = false, this.withPrice = true}) : super(key: key);
  final double totalPrice;
  final bool fromModal;
  final bool withPrice;

  @override
  Widget build(BuildContext context) {
    CartContext provider = Provider.of<CartContext>(context, listen: false);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white, //DARK_BLUE,
        boxShadow: [
          new BoxShadow(
            color: Colors.black26,
            blurRadius: 12.0,
          ),
        ],
      ),
      height: 60,
      child: Stack(
        children: [
          /* Align(
            alignment: Alignment.centerRight,
            child: */
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                /*Text(
                    !Provider.of<CartContext>(context,listen: false).withPrice ? "" : this.totalPrice == 0 ? "" : '${this.totalPrice.toStringAsFixed(2)} €',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),*/
                Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    //this.onTap();

                    if (!fromModal)
                      showModalBottomSheet(
                          context: context,
                          builder: (_) {
                            return Consumer<CartContext>(builder: (_, _cartContext, __) {
                              return Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(left: 10, right: 10, top: 15),
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextTranslator(
                                          "Vider panier",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        InkWell(
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.grey,
                                          ),
                                          onTap: () async {
                                            var result = await showDialog(
                                              context: context,
                                              builder: (_) => ConfirmationDialog(
                                                title: AppLocalizations.of(context).translate('confirm_remove_from_cart_title'),
                                                content: AppLocalizations.of(context).translate('confirm_remove_from_cart_content'),
                                              ),
                                            );

                                            if (result is bool && result) {
                                              _cartContext.clear();
                                              RouteUtil.goBack(context: context);
                                            }
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                        itemCount: _cartContext.items.length,
                                        itemBuilder: (_, position) {
                                          // dynamic food = _cartContext.items.keys.elementAt(position);
                                          dynamic food = _cartContext.items[position];

                                          // var count = _cartContext.items.values.elementAt(position);
                                          var count = 1;
                                          if (food.isFoodForMenu) return Container();

                                          return BagItem(
                                            food: food,
                                            count: count,
                                            position: position,
                                            activeDelete: false,
                                            imageTag: '${food.id}$position',
                                            withPrice: withPrice,
                                          );
                                        }),
                                  ),
                                  OrderButton(
                                    totalPrice: _cartContext.totalPrice ?? 0,
                                    fromModal: true,
                                    withPrice: withPrice,
                                  )
                                ],
                              );
                            });
                            /**/
                          });
                  },
                  child: /*Text("")*/
                      Stack(
                    children: [
                      Container(
                          padding: EdgeInsets.all(8),
                          margin: EdgeInsets.only(right: 5, top: 5),
                          decoration: BoxDecoration(shape: BoxShape.circle, color: CRIMSON),
                          child: Icon(
                            Icons.shopping_cart,
                            color: Colors.white,
                          )),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.only(bottom: 5),
                          decoration: BoxDecoration(color: TEAL, borderRadius: BorderRadius.circular(12.5)),
                          child: Center(
                            child: Text(
                              "${provider.totalItems}",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          width: 25,
                          height: 25,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  !Provider.of<CartContext>(context, listen: false).withPrice
                      ? ""
                      : this.totalPrice == 0
                          ? ""
                          : '${this.totalPrice.toStringAsFixed(2)} €',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: CRIMSON),
                )
              ],
            ),
          ),
          Visibility(
              visible: true,
              child: Positioned(
                right: 0,
                child: ElevatedButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(
                      EdgeInsets.all(25),
                    ),
                  ),
                  onPressed: () {
                    RouteUtil.goTo(
                      context: context,
                      child: OrderPage(
                        withPrice: withPrice,
                      ),
                      routeName: orderRoute,
                    );
                  },
                  child: TextTranslator(
                    AppLocalizations.of(context).translate('command'),
                    style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
