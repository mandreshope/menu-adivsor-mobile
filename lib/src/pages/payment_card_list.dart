import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/pages/add_payment_card.dart';
import 'package:menu_advisor/src/pages/summary.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/providers/CommandContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/services/stripe.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:provider/provider.dart';

class PaymentCardListPage extends StatefulWidget {
  final bool isPaymentStep;

  const PaymentCardListPage({
    Key key,
    this.isPaymentStep = false,
  }) : super(key: key);

  @override
  _PaymentCardListPageState createState() => _PaymentCardListPageState();
}

class _PaymentCardListPageState extends State<PaymentCardListPage> {
  bool isPaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
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
                          for (PaymentCard creditCard in user.paymentCards)
                            Material(
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
                                    await authContext.removePaymentCard(creditCard);
                                  }
                                },
                                onTap: widget.isPaymentStep
                                    ? () async {
                                        setState(() {
                                          isPaying = true;
                                        });
                                        try {
                                          var command = await Api.instance.sendCommand(
                                            relatedUser: authContext.currentUser.id,
                                            commandType: commandContext.commandType,
                                            items: cartContext.items.entries.map((e) => {'quantity': e.value, 'item': e.key.id}).toList(),
                                            restaurant: cartContext.currentOrigin,
                                            totalPrice: (cartContext.totalPrice * 100).round(),
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
                                          );
                                          var commandStr = command.toString();
                                          CommandModel cm = CommandModel.fromJson(command);
                                          var payment = await StripeService.payViaExistingCard(
                                            amount: (cartContext.totalPrice * 100).floor().toString(),
                                            card: creditCard,
                                            currency: 'eur',
                                          );
                                          if (payment.success) {
                                            Api.instance.setCommandToPayedStatus(
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

                                            RouteUtil.goToAndRemoveUntil(
                                              context: context,
                                              child: Summary(
                                                commande: cm,
                                              ),
                                              routeName: summaryRoute,
                                              predicate: (route) => route.settings.name == homeRoute,
                                            );
                                          } else {
                                            Fluttertoast.showToast(
                                              msg: 'Echec du paiemenet',
                                            );
                                          }
                                        } catch (error) {
                                          Fluttertoast.showToast(
                                            msg: 'Echec du paiemenet. Carte invalide',
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
                            ),
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
                            child: Text(
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
          if (isPaying)
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
}
