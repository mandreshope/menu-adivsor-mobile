import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/components/buttons.dart';
import 'package:menu_advisor/src/components/cards.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/pages/order.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/providers/DataContext.dart';
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
                Consumer<CartContext>(
                  builder: (_, cartContext, __) => Text(
                    'Total: ${cartContext.totalPrice}€',
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
              child: Consumer<CartContext>(
                builder: (_, cartContext, __) {
                  final List<Widget> list = [];
                  cartContext.items.forEach(
                    (food, count) {
                      list.add(
                        BagItem(
                          food: food,
                          count: count,
                        ),
                      );
                    },
                  );

                  if (cartContext.itemCount == 0)
                    return Center(
                      child: Text(
                        AppLocalizations.of(context).translate('no_item_in_cart'),
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
          Consumer<CartContext>(
            builder: (_, cartContext, __) => FlatButton(
              onPressed: () {
                if (cartContext.itemCount == 0)
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

    CartContext cartContext = Provider.of<CartContext>(context, listen: false);
    if (cartContext.contains(widget.food)) itemCount = cartContext.getCount(widget.food);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Consumer<CartContext>(
        builder: (_, cartContext, __) => Container(
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
                  cartContext.contains(widget.food) ? AppLocalizations.of(context).translate('edit') : AppLocalizations.of(context).translate('add_to_cart'),
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
                      cartContext.contains(widget.food) ? AppLocalizations.of(context).translate('edit') : AppLocalizations.of(context).translate('add'),
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      if (cartContext.contains(widget.food))
                        cartContext.setCount(widget.food, itemCount);
                      else
                        cartContext.addItem(widget.food, itemCount);

                      Navigator.of(context).pop(true);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LanguageDialog extends StatelessWidget {
  final String lang;

  LanguageDialog({this.lang});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(15),
        height: 100,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.of(context).translate('language'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  alignment: Alignment.center,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 0,
                        ),
                        decoration: BoxDecoration(
                          color: lang == 'fr' ? Colors.grey[400].withOpacity(.4) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: SvgPicture.asset('assets/images/france-flag.svg'),
                          onPressed: () => Navigator.of(context).pop<String>('fr'),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 0,
                        ),
                        decoration: BoxDecoration(
                          color: lang == 'en' ? Colors.grey[400].withOpacity(.4) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: SvgPicture.asset('assets/images/usa-flag.svg'),
                          onPressed: () => Navigator.of(context).pop<String>('en'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchSettingDialog extends StatefulWidget {
  final String languageCode;
  final Map<String, dynamic> filters;
  final String type;
  final bool inRestaurant;

  SearchSettingDialog({
    Key key,
    @required this.languageCode,
    @required this.filters,
    @required this.type,
    this.inRestaurant = false,
  }) : super(key: key);

  @override
  _SearchSettingDialogState createState() => _SearchSettingDialogState();
}

class _SearchSettingDialogState extends State<SearchSettingDialog> {
  Map<String, dynamic> filters = Map();
  String type;

  @override
  void initState() {
    super.initState();

    type = widget.type;
    filters.addAll(widget.filters);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
          top: 25,
          bottom: 10,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context).translate('search_type'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              child: Row(
                children: [
                  if (widget.inRestaurant) ...[
                    'all',
                    'food',
                  ] else ...[
                    'all',
                    'restaurant',
                    'food',
                  ]
                ]
                    .map(
                      (e) => Theme(
                        data: ThemeData(
                          brightness: type == e ? Brightness.dark : Brightness.light,
                          cardColor: type == e ? CRIMSON : Colors.white,
                        ),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(50),
                            onTap: () {
                              setState(() {
                                type = e;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                AppLocalizations.of(context).translate(e),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              AppLocalizations.of(context).translate('categories'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              child: Row(
                children: [
                  Theme(
                    data: ThemeData(
                      brightness: !filters.containsKey('category') ? Brightness.dark : Brightness.light,
                      cardColor: !filters.containsKey('category') ? CRIMSON : Colors.white,
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () {
                          setState(() {
                            filters.remove('category');
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            'Tous',
                          ),
                        ),
                      ),
                    ),
                  ),
                  ...Provider.of<DataContext>(context)
                      .foodCategories
                      .map(
                        (e) => Theme(
                          data: ThemeData(
                            brightness: filters.containsKey('category') && filters['category'] == e.id ? Brightness.dark : Brightness.light,
                            cardColor: filters.containsKey('category') && filters['category'] == e.id ? CRIMSON : Colors.white,
                          ),
                          child: Card(
                            color: filters.containsKey('category') && filters['category'] == e.id ? CRIMSON : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(50),
                              onTap: () {
                                setState(() {
                                  filters['category'] = e.id;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  e.name[widget.languageCode],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              AppLocalizations.of(context).translate('attributes'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              child: Row(
                children: [
                  Theme(
                    data: ThemeData(
                      brightness: !filters.containsKey('attributes') ? Brightness.dark : Brightness.light,
                      cardColor: !filters.containsKey('attributes') ? CRIMSON : Colors.white,
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () {
                          setState(() {
                            filters.remove('attributes');
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            'Tous',
                          ),
                        ),
                      ),
                    ),
                  ),
                  ...Provider.of<DataContext>(context)
                      .attributes
                      .map(
                        (e) => Theme(
                          data: ThemeData(
                            brightness: filters.containsKey('attributes') && filters['attributes'] == e['tag'] ? Brightness.dark : Brightness.light,
                            cardColor: filters.containsKey('attributes') && filters['attributes'] == e['tag'] ? CRIMSON : Colors.white,
                          ),
                          child: Card(
                            color: filters.containsKey('attributes') && filters['attributes'] == e['tag'] ? CRIMSON : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(50),
                              onTap: () {
                                setState(() {
                                  filters['attributes'] = e['tag'];
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      e['imageURL'],
                                      height: 18,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      e[widget.languageCode],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: RaisedButton(
                onPressed: () => Navigator.of(context).pop(
                  {
                    'filters': filters,
                    'type': type,
                  },
                ),
                child: Text(
                  AppLocalizations.of(context).translate('confirm'),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
