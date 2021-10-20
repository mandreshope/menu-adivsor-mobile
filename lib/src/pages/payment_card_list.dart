import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/constants/colors.dart';
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
import 'package:menu_advisor/src/services/stripe.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';

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
                        children: [for (final c in user.paymentCards.toList()) _renderPayement(c, cartContext, authContext, commandContext)],
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
                              AppLocalizations.of(context).translate('no_payment_card').replaceFirst('\$', '+'),
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
              title: AppLocalizations.of(context).translate('confirm_remove_payment_card_title'),
              content: AppLocalizations.of(context).translate('confirm_remove_payment_card_content'),
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
                msg: AppLocalizations.of(context).translate('error_deleting_payment_card'),
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
                  int totalPrice = 0;
                  int priceLivraison = 0;
                  if (widget.restaurant.deliveryFixed) {
                    priceLivraison = (widget.restaurant.priceDelevery != null ? widget.restaurant.priceDelevery : 0).toInt();
                    totalPrice = ((cartContext.totalPrice + priceLivraison) * 100).round();
                  } else {
                    if (commandContext.commandType == "delivery") {
                      if (widget.restaurant.isFreeCP(commandContext.deliveryAddress) || widget.restaurant.isFreeCity(commandContext.deliveryAddress)) {
                        /// livraison gratuite
                        priceLivraison = 0;
                      } else {
                        priceLivraison = commandContext.getDeliveryPriceByMiles(widget.restaurant).toInt();
                        double remiseWithCodeDiscount = cartContext.totalPrice;
                        if (commandContext.withCodeDiscount) {
                          remiseWithCodeDiscount = cartContext.calculremise(
                            totalPrice: cartContext.totalPrice,
                            discountIsPrice: widget.restaurant?.discount?.codeDiscount?.discountIsPrice,
                            discountValue: widget.restaurant?.discount?.codeDiscount?.valueDouble,
                          );
                        }
                        if (widget.restaurant?.discount?.delivery?.discountType == DiscountType.SurTransport) {
                          priceLivraison = cartContext
                              .calculremise(
                                totalPrice: priceLivraison.toDouble(),
                                discountIsPrice: widget.restaurant?.discount?.delivery?.discountIsPrice,
                                discountValue: widget.restaurant?.discount?.delivery?.valueDouble,
                              )
                              .toInt();
                          totalPrice = (remiseWithCodeDiscount + priceLivraison).toInt();
                        } else if (widget.restaurant?.discount?.delivery?.discountType == DiscountType.SurCommande) {
                          int totalPriceWithRemise = cartContext
                              .calculremise(
                                totalPrice: remiseWithCodeDiscount,
                                discountIsPrice: widget.restaurant?.discount?.delivery?.discountIsPrice,
                                discountValue: widget.restaurant?.discount?.delivery?.valueDouble,
                              )
                              .toInt();
                          totalPrice = (totalPriceWithRemise + priceLivraison).toInt();
                        } else {
                          totalPrice = cartContext
                              .calculremise(
                                totalPrice: remiseWithCodeDiscount + priceLivraison,
                                discountIsPrice: widget.restaurant?.discount?.delivery?.discountIsPrice,
                                discountValue: widget.restaurant?.discount?.delivery?.valueDouble,
                              )
                              .toInt();
                        }
                      }
                    }
                    totalPrice = (totalPrice * 100).toInt();
                  }

                  StripeTransactionResponse payment = await StripeService.payViaExistingCard(
                    restaurant: widget.restaurant,
                    amount: totalPrice.toString(),
                    card: creditCard,
                    currency: 'eur',
                  );

                  if (payment.success) {
                    var command = await Api.instance.sendCommand(
                        priceLivraison: priceLivraison.toString(),
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
                                  'options': e.optionSelected != null ? e.optionSelected : [],
                                  'comment': e.message,
                                })
                            .toList(),
                        restaurant: cartContext.currentOrigin,
                        discount: widget.restaurant?.discount,
                        totalPrice: totalPrice,
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
                    cm.withCodeDiscount = commandContext.withCodeDiscount;

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
        ),
      ),
    );
    // }
  }
}
