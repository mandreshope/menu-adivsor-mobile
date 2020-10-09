import 'package:flutter/material.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/pages/payment_method.dart';
import 'package:menu_advisor/src/pages/user_details.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:provider/provider.dart';

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('order'),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              physics: BouncingScrollPhysics(),
              child: Consumer<BagContext>(
                builder: (_, bagContext, __) {
                  final List<Widget> list = [];
                  bagContext.items.forEach(
                    (food, count) {
                      list.add(
                        BagItem(
                          food: food,
                          count: count,
                        ),
                      );
                    },
                  );

                  if (bagContext.itemCount == 0)
                    return Center(
                      child: Text(
                        AppLocalizations.of(context)
                            .translate('no_item_in_cart'),
                      ),
                    );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          AppLocalizations.of(context).translate('all_items'),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...list,
                    ],
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: FlatButton(
              onPressed: () {
                AuthContext authContext =
                    Provider.of<AuthContext>(context, listen: false);

                if (authContext.currentUser == null) {
                  RouteUtil.goTo(
                    context: context,
                    child: UserDetailsPage(),
                    routeName: userDetailsRoute,
                  );
                } else {
                  RouteUtil.goTo(
                    context: context,
                    child: PaymentMethodPage(),
                    routeName: paymentMethodRoute,
                  );
                }
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
