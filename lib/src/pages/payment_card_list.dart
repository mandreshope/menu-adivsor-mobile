import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/pages/add_payment_card.dart';
import 'package:menu_advisor/src/pages/home.dart';
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
          Consumer<AuthContext>(
            builder: (_, authContext, __) {
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
                                          await StripeService.payViaExistingCard(
                                            amount: (Provider.of<BagContext>(
                                                      context,
                                                      listen: false,
                                                    ).totalPrice *
                                                    100)
                                                .floor()
                                                .toString(),
                                            card: creditCard,
                                            currency: 'eur',
                                          );
                                          CommandContext commandContext = Provider.of<CommandContext>(
                                            context,
                                            listen: false,
                                          );
                                          BagContext bagContext = Provider.of<BagContext>(
                                            context,
                                            listen: false,
                                          );

                                          await Api.instance.sendCommand(
                                            commandType: commandContext.commandType,
                                            items: bagContext.items.entries.map((e) => {'quantity': e.value, 'item': e.key.id}).toList(),
                                            restaurant: bagContext.currentOrigin,
                                            totalPrice: (bagContext.totalPrice * 100).round(),
                                          );

                                          Fluttertoast.showToast(
                                            msg: AppLocalizations.of(
                                              context,
                                            ).translate('success'),
                                          );

                                          Provider.of<BagContext>(
                                            context,
                                            listen: false,
                                          ).clear();
                                          Provider.of<CommandContext>(
                                            context,
                                            listen: false,
                                          ).clear();

                                          RouteUtil.goTo(
                                            context: context,
                                            child: HomePage(),
                                            routeName: homeRoute,
                                            method: RoutingMethod.atTop,
                                          );
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
