import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/constants/constant.dart';
import 'package:menu_advisor/src/models/models.dart';
import 'package:menu_advisor/src/models/restaurants/restaurant_discount_model.dart';
import 'package:menu_advisor/src/pages/payment_card_list.dart';
import 'package:menu_advisor/src/pages/summary.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/providers/CommandContext.dart';
import 'package:menu_advisor/src/providers/MenuContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/services/notification_service.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChoosePayement extends StatelessWidget {
  final Restaurant restaurant;
  final dynamic customer;

  const ChoosePayement({Key key, this.restaurant, this.customer})
      : super(key: key);

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
            print("$logTrace Carte bancaire");
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
            print("$logTrace à la livraison");

            showDialogProgress(context, barrierDismissible: false);
            CommandContext commandContext = Provider.of<CommandContext>(
              context,
              listen: false,
            );

            CartContext cartContext = Provider.of<CartContext>(
              context,
              listen: false,
            );

            AuthContext authContext =
                Provider.of<AuthContext>(context, listen: false);

            int totalPrice = 0;
            int totalPriceSansRemise = (cartContext.totalPrice * 100).toInt();
            int priceLivraison = 0;
            if (restaurant.deliveryFixed) {
              priceLivraison = (restaurant.priceDelevery != null
                      ? restaurant.priceDelevery
                      : 0)
                  .toInt();
              totalPrice =
                  ((cartContext.totalPrice * 100) + priceLivraison).round();
            } else {
              if (commandContext.commandType == "delivery") {
                if (restaurant.isFreeCP(commandContext.deliveryAddress) ||
                    restaurant.isFreeCity(commandContext.deliveryAddress)) {
                  /// livraison gratuite
                  priceLivraison = 0;
                } else {
                  priceLivraison = commandContext
                      .getDeliveryPriceByMiles(restaurant)
                      .toInt();
                  double remiseWithCodeDiscount = cartContext.totalPrice;
                  if (commandContext.withCodeDiscount != null) {
                    remiseWithCodeDiscount = cartContext.calculremise(
                      totalPrice: cartContext.totalPrice,
                      discountIsPrice:
                          commandContext.withCodeDiscount.discountIsPrice,
                      discountValue:
                          commandContext.withCodeDiscount.value.toDouble(),
                    );
                  }
                  if (restaurant?.discountDelivery == true) {
                    if (restaurant?.discount?.delivery?.discountType ==
                        DiscountType.SurTransport) {
                      ///remise sur le frais de livraison
                      double discountValue =
                          cartContext.discountValueInPlageDiscount(
                        discountIsPrice:
                            restaurant?.discount?.delivery?.discountIsPrice,
                        discountValue:
                            restaurant?.discount?.delivery?.valueDouble,
                        plageDiscount:
                            restaurant?.discount?.delivery?.plageDiscount,
                        totalPriceSansRemise: totalPriceSansRemise.toDouble(),
                      );
                      priceLivraison = cartContext
                          .calculremise(
                            totalPrice: priceLivraison.toDouble(),
                            discountIsPrice:
                                restaurant?.discount?.delivery?.discountIsPrice,
                            discountValue: discountValue,
                          )
                          .toInt();
                      totalPrice =
                          (remiseWithCodeDiscount + priceLivraison).toInt();
                    } else if (restaurant?.discount?.delivery?.discountType ==
                        DiscountType.SurCommande) {
                      ///remise sur le commande
                      double discountValue =
                          cartContext.discountValueInPlageDiscount(
                        discountIsPrice:
                            restaurant?.discount?.delivery?.discountIsPrice,
                        discountValue:
                            restaurant?.discount?.delivery?.valueDouble,
                        plageDiscount:
                            restaurant?.discount?.delivery?.plageDiscount,
                        totalPriceSansRemise: totalPriceSansRemise.toDouble(),
                      );
                      int totalPriceWithRemise = cartContext
                          .calculremise(
                            totalPrice: remiseWithCodeDiscount,
                            discountIsPrice:
                                restaurant?.discount?.delivery?.discountIsPrice,
                            discountValue: discountValue,
                          )
                          .toInt();
                      totalPrice =
                          (totalPriceWithRemise + priceLivraison).toInt();
                    } else {
                      ///remise sur la totalité
                      double discountValue =
                          cartContext.discountValueInPlageDiscount(
                        discountIsPrice:
                            restaurant?.discount?.delivery?.discountIsPrice,
                        discountValue:
                            restaurant?.discount?.delivery?.valueDouble,
                        plageDiscount:
                            restaurant?.discount?.delivery?.plageDiscount,
                        totalPriceSansRemise: totalPriceSansRemise.toDouble(),
                      );
                      totalPrice = cartContext
                          .calculremise(
                            totalPrice: remiseWithCodeDiscount + priceLivraison,
                            discountIsPrice:
                                restaurant?.discount?.delivery?.discountIsPrice,
                            discountValue: discountValue,
                          )
                          .toInt();
                    }
                  }
                }
              }
              totalPrice = (totalPrice * 100).toInt();
            }

            ///get tokenFCM
            final sharedPrefs = await SharedPreferences.getInstance();
            final tokenFCM = sharedPrefs.getString(kTokenFCM);

            ///TODO: await Api.instance.sendCommand - DELIVERY
            var command = await Api.instance.sendCommand(
              tokenNavigator: tokenFCM,
              addCodePromo: commandContext.withCodeDiscount,
              isCodePromo: commandContext.withCodeDiscount != null,
              priceLivraison: priceLivraison.toString(),
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
                  .map((e) => {
                        'quantity': e.quantity,
                        'item': e.id,
                        'options':
                            e.optionSelected != null ? e.optionSelected : [],
                        'comment': e.message,
                      })
                  .toList(),
              restaurant: cartContext.currentOrigin,
              discount: restaurant?.discount,
              totalPrice: totalPrice,
              totalPriceSansRemise: totalPriceSansRemise,
              menu: cartContext.items
                  .where((e) => e.isMenu)
                  .map((e) => {
                        'quantity': e.quantity,
                        'item': e.id,
                        'foods': e.foodMenuSelecteds,
                      })
                  .toList(),
              shippingAddress: commandContext.deliveryAddress,
              shipAsSoonAsPossible: commandContext.deliveryDate == null &&
                  commandContext.deliveryTime == null,
              shippingTime: (commandContext.deliveryDate == null &&
                      commandContext.deliveryTime == null)
                  ? null
                  : commandContext.deliveryDate
                          ?.add(
                            Duration(
                              minutes: commandContext.deliveryTime.hour * 60 +
                                  commandContext.deliveryTime.minute,
                            ),
                          )
                          ?.millisecondsSinceEpoch ??
                      null,
              priceless: !cartContext.withPrice,
            );
            Command cm = Command.fromJson(command);
            cm.codeDiscount = commandContext.withCodeDiscount;
            cm.withCodeDiscount = commandContext.withCodeDiscount != null;

            await sendPushMessage(cm.tokenNavigator,
                message: "Vous avez un commande ${cm.commandType}");

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

  Widget _card(BuildContext context, String title, IconData iconData,
          Function onTap) =>
      Center(
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
