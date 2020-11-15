import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/extensions.dart';

import '../models.dart';

class Summary extends StatelessWidget {
  Summary({@required this.commande});
  BuildContext context;
  CommandModel commande;

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context).translate('summary'),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 25,
                ),
                Divider(),
                _header(),
                Divider(),
                //commande id
                Row(
                  children: [
                    Text("Commande ID : "),
                    Text(commande.code?.toString()?.padLeft(6,'0') ?? "", style: TextStyle(color: CRIMSON, fontWeight: FontWeight.bold, fontSize: 18)),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.horizontal(left: Radius.circular(15), right: Radius.circular(15)),
                        color: Colors.orange,
                      ),
                      child: Text(
                        "En attente",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    )
                  ],
                ),
                //end commande id
                Divider(),
                // food
                for (var command in commande.items) _items(command),
                // Divider(),
                // menu
                for (var command in commande.menus) _items(command),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Text('Total', style: TextStyle(fontSize: 16)),
                      Spacer(),
                      Text('${commande.totalPrice / 100} €', style: TextStyle(fontSize: 16, color: CRIMSON, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context).translate(commande.commandType ?? 'on_site').toUpperCase(),
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      Text('${commande.shippingTime == null ? "" : commande.shippingTime.dateToString("dd/MM/yyyy HH:mm")}')
                    ],
                  ),
                ),
                Divider(),
              ],
            ),
          ),
        ));
  }

  Widget _header() => Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              commande.restaurant.imageURL ?? "",
              // width: 4 * MediaQuery.of(context).size.width / 7,
              width: MediaQuery.of(context).size.width / 4,
              height: MediaQuery.of(context).size.width / 4,
              fit: BoxFit.cover,
            ),
            SizedBox(
              width: 15,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  commande.restaurant.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      FontAwesomeIcons.mapMarkerAlt,
                      size: 15,
                      color: CRIMSON,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      commande.restaurant.address ?? "",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      FontAwesomeIcons.phoneAlt,
                      size: 15,
                      color: CRIMSON,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      "Tel : 0",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black54),
                    )
                  ],
                )
              ],
            )
          ],
        ),
      );

  Widget _items(CommandItem commandItem) {
    dynamic item = commandItem.food != null ? commandItem.food : commandItem.menu; 
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('${commandItem.quantity}', style: TextStyle(fontSize: 16)),
              SizedBox(width: 15),
              Image.network(
                item.imageURL,
                width: 25,
              ),
              SizedBox(width: 8),
              Text('${item.name}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Spacer(),
              item.price?.amount == null ? Text("_") : Text("${item.price.amount / 100} €", style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
        Divider()
      ],
    );
  }
}
