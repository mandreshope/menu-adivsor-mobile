import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/constants/constant.dart';
import 'package:menu_advisor/src/models/models.dart';
import 'package:menu_advisor/src/models/restaurants/restaurant_discount_model.dart';
import 'package:menu_advisor/src/pages/add_payment_card.dart';
import 'package:menu_advisor/src/pages/summary.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/providers/CommandContext.dart';
import 'package:menu_advisor/src/providers/MenuContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/services/notification_service.dart';
import 'package:menu_advisor/src/services/stripe.dart';
import 'package:menu_advisor/src/types/types.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentCardListPage extends StatefulWidget {
  final bool isPaymentStep;
  final Restaurant restaurant;
  final String typedePayment;

  const PaymentCardListPage({
    Key key,
    this.isPaymentStep = false,
    this.restaurant,
    this.typedePayment,
  }) : super(key: key);

  @override
  _PaymentCardListPageState createState() => _PaymentCardListPageState();
}

class _PaymentCardListPageState extends State<PaymentCardListPage> {
  bool isPaying = false;
  bool isDeletingPaymentCard = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextTranslator(
          AppLocalizations.of(context).translate('my_payment_cards'),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Consumer3<AuthContext, CartContext, CommandContext>(
            builder: (_, authContext, cartContext, commandContext, __) {
              var user = authContext.currentUser;

              return user.paymentCards.length > 0
                  ? SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final c in user.paymentCards.toList())
                            _renderPayement(
                                c, cartContext, authContext, commandContext)
                        ],
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.warning,
                            size: 80,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40.0,
                            ),
                            child: TextTranslator(
                              AppLocalizations.of(context)
                                  .translate('no_payment_card')
                                  .replaceFirst('\$', '+'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
            },
          ),
          if (isPaying || isDeletingPaymentCard)
            Container(
              color: Colors.black45,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(CRIMSON),
                ),
              ),
            )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          RouteUtil.goTo(
            context: context,
            child: PaymentCardDetailsPage(
              restaurant: widget.restaurant,
              isPaymentStep: Provider.of<AuthContext>(
                    context,
                    listen: false,
                  ).currentUser ==
                  null,
            ),
            routeName: addPaymentCardRoute,
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _renderPayement(
    c,
    CartContext cartContext,
    AuthContext authContext,
    CommandContext commandContext,
  ) {
    //  for (var c in user.paymentCards){
    PaymentCard creditCard = c is PaymentCard ? c : PaymentCard.fromJson(c);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onLongPress: () async {
          var result = await showDialog(
            context: context,
            builder: (_) => ConfirmationDialog(
              title: AppLocalizations.of(context)
                  .translate('confirm_remove_payment_card_title'),
              content: AppLocalizations.of(context)
                  .translate('confirm_remove_payment_card_content'),
            ),
          );

          if (result is bool && result) {
            // Remove card
            setState(() {
              isDeletingPaymentCard = true;
            });
            try {
              await authContext.removePaymentCard(creditCard);
            } catch (error) {
              Fluttertoast.showToast(
                msg: AppLocalizations.of(context)
                    .translate('error_deleting_payment_card'),
              );
            }
            setState(() {
              isDeletingPaymentCard = false;
            });
          }
        },
        onTap: widget.isPaymentStep
            ? () async {
                setState(() {
                  isPaying = true;
                });
                try {
                  int totalPrice = cartContext.totalPrice.round();
                  int totalDiscount = 0;
                  int totalPriceSansRemise =
                      (cartContext.totalPrice * 100).round();
                  int priceLivraison = 0;
                  final priceLivraisonSansRemise = commandContext
                      .getDeliveryPriceByMiles(widget.restaurant)
                      .round();
                  double remiseWithCodeDiscount = cartContext.totalPrice;
                  int discountCode =
                      0; // prix en euro an'le code promo, default value : 0
                  int discountDelivery =
                      0; // prix en euro an'le remise sur le transport
                  if (widget.restaurant.deliveryFixed) {
                    priceLivraison = (widget.restaurant.priceDelevery != null
                            ? widget.restaurant.priceDelevery
                            : 0)
                        .round();
                    totalPrice =
                        ((cartContext.totalPrice + priceLivraison) * 100)
                            .round();
                  } else {
                    if (commandContext.commandType == "delivery") {
                      if (widget.restaurant
                              .isFreeCP(commandContext.deliveryAddress) ||
                          widget.restaurant
                              .isFreeCity(commandContext.deliveryAddress)) {
                        /// livraison gratuite
                        priceLivraison = 0;
                      } else {
                        priceLivraison = commandContext
                            .getDeliveryPriceByMiles(widget.restaurant)
                            .round();
                        remiseWithCodeDiscount = cartContext.totalPrice;
                        if (commandContext?.withCodeDiscount != null) {
                          remiseWithCodeDiscount = cartContext.calculremise(
                            totalPrice: cartContext.totalPrice,
                            discountIsPrice:
                                commandContext.withCodeDiscount.discountIsPrice,
                            discountValue: commandContext.withCodeDiscount.value
                                .toDouble(),
                          );
                          discountCode = cartContext
                              .remiseInEuro(
                                discountIsPrice: commandContext
                                    .withCodeDiscount.discountIsPrice,
                                discountValue: commandContext
                                    .withCodeDiscount.value
                                    .toDouble(),
                                totalPrice: remiseWithCodeDiscount.toDouble(),
                              )
                              .round();
                        }

                        if (widget.restaurant?.discountDelivery == true) {
                          if (widget.restaurant?.discount?.delivery
                                  ?.discountType ==
                              DiscountType.SurTransport) {
                            ///remise sur le frais de livraison
                            totalDiscount = cartContext
                                .discountValueInPlageDiscount(
                                  plageDiscounts: widget.restaurant?.discount
                                      ?.delivery?.plageDiscount,
                                  price: totalPriceSansRemise.toDouble(),
                                )
                                .round();
                            priceLivraison = cartContext
                                .calculremise(
                                  totalPrice: priceLivraison.toDouble(),
                                  discountIsPrice: true,
                                  discountValue: totalDiscount.toDouble(),
                                )
                                .round();
                            discountDelivery = totalDiscount.round();
                            totalPrice =
                                (remiseWithCodeDiscount + priceLivraison)
                                    .round();
                          } else if (widget.restaurant?.discount?.delivery
                                  ?.discountType ==
                              DiscountType.SurCommande) {
                            ///remise sur le commande
                            totalDiscount = cartContext
                                .discountValueInPlageDiscount(
                                  plageDiscounts: widget.restaurant?.discount
                                      ?.delivery?.plageDiscount,
                                  price: totalPriceSansRemise.toDouble(),
                                )
                                .round();
                            int totalPriceWithRemise = cartContext
                                .calculremise(
                                  totalPrice: remiseWithCodeDiscount,
                                  discountIsPrice: true,
                                  discountValue: totalDiscount.toDouble(),
                                )
                                .round();
                            totalPrice =
                                (totalPriceWithRemise + priceLivraison).round();
                          } else {
                            ///remise sur la totalité
                            totalDiscount = cartContext
                                .discountValueInPlageDiscount(
                                  plageDiscounts: widget.restaurant?.discount
                                      ?.delivery?.plageDiscount,
                                  price: totalPriceSansRemise.toDouble(),
                                )
                                .round();
                            totalPrice = cartContext
                                .calculremise(
                                  totalPrice:
                                      remiseWithCodeDiscount + priceLivraison,
                                  discountIsPrice: true,
                                  discountValue: totalDiscount.toDouble(),
                                )
                                .round();
                          }
                        }
                      }
                    }
                    totalPrice = (totalPrice * 100).round();
                  }

                  StripeTransactionResponse payment =
                      await StripeService.payViaExistingCard(
                    restaurant: widget.restaurant,
                    amount: totalPrice.toString(),
                    card: creditCard,
                    currency: 'eur',
                  );

                  ///get tokenFCM
                  final sharedPrefs = await SharedPreferences.getInstance();
                  final tokenFCM = sharedPrefs.getString(kTokenFCM);

                  if (payment.success) {
                    ///TODO: await Api.instance.sendCommand - DELIVERY
                    var command = await Api.instance.sendCommand(
                        tokenNavigator: tokenFCM,
                        addCodePromo: commandContext.withCodeDiscount,
                        isCodePromo: commandContext.withCodeDiscount != null,
                        deliveryPrice: Price(
                            amount: priceLivraisonSansRemise, currency: 'eur'),
                        optionLivraison: widget.restaurant.optionLivraison,
                        etage: widget.restaurant.etage,
                        isDelivery: true,
                        appartement: widget.restaurant.appartement,
                        codeappartement: widget.restaurant.codeappartement,
                        payed: true,
                        comment: cartContext.comment,
                        relatedUser: authContext.currentUser?.id ?? null,
                        commandType: commandContext.commandType,
                        items: cartContext.items
                            .where((e) => !e.isMenu)
                            .toList()
                            .map((e) => {
                                  'quantity': e.quantity,
                                  'item': e.id,
                                  'options': e.optionSelected != null
                                      ? e.optionSelected
                                      : [],
                                  'comment': e.message,
                                })
                            .toList(),
                        restaurant: cartContext.currentOrigin,
                        discount: widget.restaurant?.discount,
                        discountPrice: totalDiscount,
                        discountCode: discountCode,
                        discountDelivery: discountDelivery,
                        totalPrice: totalPrice,
                        totalPriceSansRemise: totalPriceSansRemise,
                        menu: cartContext.items
                            .where((e) => e.isMenu)
                            .toList()
                            .map((e) => {
                                  'quantity': e.quantity,
                                  'item': e.id,
                                  'foods': e.foodMenuSelecteds,
                                })
                            .toList(),
                        shippingAddress: commandContext.deliveryAddress,
                        shipAsSoonAsPossible:
                            commandContext.deliveryDate == null &&
                                commandContext.deliveryTime == null,
                        shippingTime: commandContext.deliveryDate
                                ?.add(
                                  Duration(
                                    minutes:
                                        commandContext.deliveryTime.hour * 60 +
                                            commandContext.deliveryTime.minute,
                                  ),
                                )
                                ?.millisecondsSinceEpoch ??
                            null,
                        priceless: !cartContext.withPrice);

                    Command cm = Command.fromJson(command);
                    cm.codeDiscount = commandContext.withCodeDiscount;
                    cm.withCodeDiscount =
                        commandContext.withCodeDiscount != null;

                    ///TODO: SEND PUSH NOTIFICATION
                    /*  await sendPushMessage(tokenFCM,
                        message: "Votre commande est livré");*/
                    /*for (var tokenNavigator in cm.tokenNavigator) {
                      await sendPushMessage(tokenNavigator,
                          message: "Vous avez un commande ${cm.commandType}");
                    }*/

                    Api.instance.setCommandToPayedStatus(
                      true,
                      id: command['_id'],
                      paymentIntentId: payment.paymentIntentId,
                    );
                    Fluttertoast.showToast(
                      msg: AppLocalizations.of(
                        context,
                      ).translate('success'),
                    );

                    Provider.of<CartContext>(
                      context,
                      listen: false,
                    ).clear();

                    Provider.of<CommandContext>(
                      context,
                      listen: false,
                    ).clear();
                    Provider.of<MenuContext>(context, listen: false).clear();

                    commandContext.clear();
                    cartContext.clear();
                    Provider.of<MenuContext>(context, listen: false).clear();
                    Fluttertoast.showToast(
                      msg: 'Votre commande a été bien reçu.',
                    );

                    RouteUtil.goTo(
                      context: context,
                      child: Summary(commande: cm),
                      routeName: confirmEmailRoute,
                    );
                  } else {
                    Fluttertoast.showToast(
                      msg: 'Echec du paiement',
                    );
                  }
                } catch (error) {
                  Fluttertoast.showToast(
                    msg: 'Echec du paiement. Carte invalide',
                  );
                } finally {
                  setState(() {
                    isPaying = false;
                  });
                }
              }
            : null,
        child: CreditCardWidget(
          cardHolderName: creditCard.owner,
          showBackView: false,
          cvvCode: creditCard.securityCode.toString(),
          cardNumber: creditCard.cardNumber.toString(),
          expiryDate: '${creditCard.expiryMonth}/${creditCard.expiryYear}',
          onCreditCardWidgetChange: (creditCardBrand) {},
        ),
      ),
    );
    // }
  }
}
