import 'package:flutter/material.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/pages/order.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';

class RoundedButton extends StatelessWidget {
  /// The child of the rounded button
  final Widget child;

  final VoidCallback onPressed;

  final Color backgroundColor;

  final List<BoxShadow> boxShadow;

  final EdgeInsets padding;

  final double radius;

  const RoundedButton(
      {Key key,
      @required this.child,
      @required this.onPressed,
      this.backgroundColor = Colors.white,
      this.boxShadow,
      this.padding,
      this.radius = 50.0})
      : super(key: key);

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
            padding: padding ??
                const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
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
  const OrderButton({Key key, this.totalPrice}) : super(key: key);
  final double totalPrice;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
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
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CRIMSON
                    ),
                    child: Icon(Icons.shopping_cart,color: Colors.white,)),
                  SizedBox(width: 10,),
                  Text(
                    '${this.totalPrice} €',
                    style: TextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold, color: CRIMSON),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: RaisedButton(
              padding: EdgeInsets.all(25),
              onPressed: () {
                RouteUtil.goTo(
                  context: context,
                  child: OrderPage(),
                  routeName: orderRoute,
                );
              },
              child: Text(
                AppLocalizations.of(context).translate('command'),
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}
