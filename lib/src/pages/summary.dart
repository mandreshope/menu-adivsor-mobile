import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/constants/date_format.dart';
import 'package:menu_advisor/src/types.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/pdf_helper.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/extensions.dart';

import '../models.dart';

class Summary extends StatelessWidget {
  Summary({@required this.commande});
  List<Food> foods = [
    Food(id: "sf", name: "qsdff", category: null, restaurant: "qsdf", price: Price(amount: 15, currency: "13")),
    Food(id: "sf", name: "qsdff", category: null, restaurant: "qsdf", price: Price(amount: 15, currency: "13")),
    Food(id: "sf", name: "qsdff", category: null, restaurant: "qsdf", price: Price(amount: 15, currency: "13")),
    Food(id: "sf", name: "qsdff", category: null, restaurant: "qsdf", price: Price(amount: 15, currency: "13")),
  ];

  BuildContext context;
  CommandModel commande;

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.save),
          onPressed: () {
            print("save...");
            PdfHelper(context, commande);
            RouteUtil.goBack(context: context);
          },
        ),
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context).translate('summary'),
          ),
        ),
        body: _body());
  }

  Widget _body() => Column(
        children: [
          SizedBox(
            height: 25,
          ),
          /*Text(
            AppLocalizations.of(context).translate('summary').toUpperCase(),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 8,
          ),*/
          Text(
            commande?.restaurant?.name ?? "",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CRIMSON),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            "${DateTime.now().dateToString(DATE_FORMATED_ddMMyyyyHHmmWithSpacer2)}",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 25,
          ),
          for (int i = 0; i <= commande.items.length - 1; i++) _items(commande.items[i], i),
          SizedBox(
            height: 15,
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(right: 8),
            child: Text(
             commande.totalPrice == null ? "_" : "Total : ${commande.totalPrice/100} eur",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      );

  Widget _items(CommandItem item, int position) {
    return Container(
      padding: EdgeInsets.all(10),
      color: position % 2 == 0 ? CRIMSON : Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(width: 120, child: _text(item.food?.name ?? "", position)),
          _text("|", position),
          Container(width: 50, child: _text("${item?.quantity ?? 0} x", position)),
          _text("|", position),
          if (item.food?.price?.amount == null) _text("_", position) else _text("${item.food.price.amount/100} ${item.food.price?.currency ?? ""}", position),
        ],
      ),
    );
  }

  Widget _text(String value, position) => Text(
        value,
        style: TextStyle(fontSize: 16, color: position % 2 == 0 ? Colors.white : Colors.black),
      );
}
