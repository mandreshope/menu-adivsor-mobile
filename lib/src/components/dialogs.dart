import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/components/buttons.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/pages/order.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:provider/provider.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;

  const ConfirmationDialog({
    Key key,
    @required this.title,
    @required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
      ),
      content: Text(
        content,
      ),
      actions: [
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text(
            AppLocalizations.of(context).translate('cancel'),
          ),
        ),
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: Text(
            AppLocalizations.of(context).translate("confirm"),
          ),
        ),
      ],
    );
  }
}

class BagModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).translate("in_cart"),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Consumer<BagContext>(
                  builder: (_, bagContext, __) => Text(
                    'Total: ${bagContext.totalPrice}€',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              physics: BouncingScrollPhysics(),
              child: Consumer<BagContext>(
                builder: (_, bagContext, __) {
                  final List<Widget> list = [];
                  bagContext.items.forEach(
                    (food, count) {
                      list.add(
                        BagItem(
                          food: food,
                          count: count,
                        ),
                      );
                    },
                  );

                  if (bagContext.itemCount == 0)
                    return Center(
                      child: Text(
                        AppLocalizations.of(context)
                            .translate('no_item_in_cart'),
                      ),
                    );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: list,
                  );
                },
              ),
            ),
          ),
          Consumer<BagContext>(
            builder: (_, bagContext, __) => FlatButton(
              onPressed: () {
                if (bagContext.itemCount == 0)
                  Fluttertoast.showToast(
                    msg: AppLocalizations.of(context).translate('empty_cart'),
                  );
                else
                  RouteUtil.goTo(
                    context: context,
                    child: OrderPage(),
                    routeName: orderRoute,
                  );
              },
              padding: const EdgeInsets.all(
                20.0,
              ),
              color: Colors.teal,
              child: Text(
                AppLocalizations.of(context).translate("order"),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BagItem extends StatelessWidget {
  final Food food;
  final int count;

  BagItem({
    Key key,
    @required this.food,
    @required this.count,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            food.imageURL != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(
                      food.imageURL,
                    ),
                    onBackgroundImageError: (_, __) {},
                    backgroundColor: Colors.grey,
                    maxRadius: 20,
                  )
                : Icon(
                    Icons.fastfood,
                  ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${food.price.amount / 100}€',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Text('$count'),
            ),
            CircleButton(
              backgroundColor: CRIMSON,
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
              onPressed: () async {
                var result = await showDialog(
                  context: context,
                  child: ConfirmationDialog(
                    title: AppLocalizations.of(context)
                        .translate('remove_item_confirmation_title'),
                    content: AppLocalizations.of(context)
                        .translate('remove_item_confirmation_content'),
                  ),
                );

                if (result is bool && result) {
                  BagContext bagContext =
                      Provider.of<BagContext>(context, listen: false);

                  bagContext.removeItem(food);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AddToBagDialog extends StatefulWidget {
  final Food food;

  const AddToBagDialog({
    Key key,
    this.food,
  }) : super(key: key);

  @override
  _AddToBagDialogState createState() => _AddToBagDialogState();
}

class _AddToBagDialogState extends State<AddToBagDialog> {
  int itemCount = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 25.0,
                left: 25.0,
                right: 25.0,
              ),
              child: Text(
                AppLocalizations.of(context).translate('add_to_cart'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Text(
                AppLocalizations.of(context).translate('item_count'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                children: [
                  CircleButton(
                    backgroundColor: Colors.transparent,
                    border: Border.all(
                      width: 1,
                      color: Colors.grey,
                    ),
                    child: FaIcon(
                      FontAwesomeIcons.minus,
                      color: Colors.black,
                    ),
                    onPressed: itemCount > 1
                        ? () {
                            setState(() {
                              itemCount--;
                            });
                          }
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      itemCount.toString(),
                    ),
                  ),
                  CircleButton(
                    backgroundColor: Colors.transparent,
                    border: Border.all(
                      width: 1,
                      color: Colors.grey,
                    ),
                    child: FaIcon(
                      FontAwesomeIcons.plus,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        itemCount++;
                      });
                    },
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 10.0,
                  bottom: 10.0,
                ),
                child: RaisedButton(
                  color: CRIMSON,
                  child: Text(
                    AppLocalizations.of(context).translate('add'),
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    BagContext bagContext =
                        Provider.of<BagContext>(context, listen: false);

                    bagContext.addItem(widget.food, itemCount);
                    Navigator.of(context).pop(true);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
