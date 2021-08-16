import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/pages/payment_card_list.dart';
import 'package:menu_advisor/src/pages/summary.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/providers/CommandContext.dart';
import 'package:menu_advisor/src/providers/MenuContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';

class ChoosePayement extends StatelessWidget {
  final Restaurant restaurant;
  final dynamic customer;
  const ChoosePayement({Key key, this.restaurant, this.customer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextTranslator("Choix de payement"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _card(context, "Carte bancaire", Icons.payment, () {
            print("Carte bancaire");
            RouteUtil.goTo(
              context: context,
              child: PaymentCardListPage(
                isPaymentStep: true,
                restaurant: restaurant,
                typedePayment: "Carte bancaire",
              ),
              routeName: paymentCardListRoute,
            );
          }),
          SizedBox(
            height: 25,
          ),
          _card(context, "à la livraison", Icons.delivery_dining, () async {
            print("à la livraison");

            showDialogProgress(context, barrierDismissible: false);
            CommandContext commandContext = Provider.of<CommandContext>(
              context,
              listen: false,
            );

            CartContext cartContext = Provider.of<CartContext>(
              context,
              listen: false,
            );

            AuthContext authContext = Provider.of<AuthContext>(context, listen: false);

            var command = await Api.instance.sendCommand(
                paiementLivraison: true,
                isDelivery: true,
                optionLivraison: restaurant.optionLivraison,
                etage: restaurant.etage,
                appartement: restaurant.appartement,
                codeappartement: restaurant.codeappartement,
                comment: cartContext.comment,
                relatedUser: authContext.currentUser?.id ?? null,
                commandType: commandContext.commandType,
                items: cartContext.items
                    .where((e) => !e.isMenu)
                    .map((e) => {'quantity': e.quantity, 'item': e.id, 'options': e.optionSelected != null ? e.optionSelected : [], 'comment': e.message})
                    .toList(),
                restaurant: cartContext.currentOrigin,
                totalPrice: ((cartContext.totalPrice * 100) + (restaurant.priceDelevery != null ? restaurant.priceDelevery : 0).toDouble()).round(),
                menu: cartContext.items.where((e) => e.isMenu).map((e) => {'quantity': e.quantity, 'item': e.id, 'foods': e.foodMenuSelecteds}).toList(),
                shippingAddress: commandContext.deliveryAddress,
                shipAsSoonAsPossible: commandContext.deliveryDate == null && commandContext.deliveryTime == null,
                shippingTime: commandContext.deliveryDate
                        ?.add(
                          Duration(
                            minutes: commandContext.deliveryTime.hour * 60 + commandContext.deliveryTime.minute,
                          ),
                        )
                        ?.millisecondsSinceEpoch ??
                    null,
                priceless: !cartContext.withPrice);
            Command cm = Command.fromJson(command);

            commandContext.clear();
            cartContext.clear();
            Provider.of<MenuContext>(context, listen: false).clear();
            Fluttertoast.showToast(
              msg: 'Votre commande a été bien reçu.',
            );

            dismissDialogProgress(context);

            RouteUtil.goTo(
              context: context,
              child: Summary(commande: cm),
              routeName: confirmEmailRoute,
            );
          }),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, String title, IconData iconData, Function onTap) => Center(
        child: Theme(
          data: ThemeData(
            cardColor: CRIMSON,
            brightness: Brightness.dark,
          ),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                //on tap
                onTap();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 20,
                ),
                width: MediaQuery.of(context).size.width / 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextTranslator(
                      title,
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    FaIcon(
                      iconData,
                      size: 55,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
