import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:menu_advisor/src/pages/add_payment_card.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/types.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:provider/provider.dart';

class PaymentCardListPage extends StatefulWidget {
  @override
  _PaymentCardListPageState createState() => _PaymentCardListPageState();
}

class _PaymentCardListPageState extends State<PaymentCardListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('my_payment_cards'),
        ),
      ),
      body: Consumer<AuthContext>(
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
                        CreditCardWidget(
                          cardHolderName: creditCard.owner,
                          showBackView: false,
                          cvvCode: creditCard.securityCode.toString(),
                          cardNumber: creditCard.cardNumber.toString(),
                          expiryDate:
                              '${(creditCard.expirationDate.month < 10 ? '0' : '') + creditCard.expirationDate.month.toString()}/${creditCard.expirationDate.year.toString().substring(2)}',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          RouteUtil.goTo(
            context: context,
            child: AddPaymentCardPage(),
            routeName: addPaymentCardRoute,
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
