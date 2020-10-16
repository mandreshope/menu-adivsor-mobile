import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/components/cards.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/pages/delivery_details.dart';
import 'package:menu_advisor/src/pages/login.dart';
import 'package:menu_advisor/src/pages/user_details.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/providers/CommandContext.dart';
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
                      if (food.price != null)
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
                        AppLocalizations.of(context).translate('no_item_in_cart'),
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
          Consumer2<BagContext, CommandContext>(
            builder: (_, bagContext, commandContext, __) => Padding(
              padding: const EdgeInsets.all(10),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        AppLocalizations.of(context).translate('command_type'),
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (!bagContext.pricelessItems)
                            Theme(
                              data: ThemeData(
                                cardColor: commandContext.commandType == 'delivery' ? CRIMSON : Colors.white,
                                brightness: commandContext.commandType == 'delivery' ? Brightness.dark : Brightness.light,
                              ),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () => commandContext.commandType = 'delivery',
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 20,
                                    ),
                                    width: MediaQuery.of(context).size.width / 4,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context).translate('delivery'),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        FaIcon(
                                          FontAwesomeIcons.houseUser,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Theme(
                            data: ThemeData(
                              cardColor: commandContext.commandType == 'on_site' ? CRIMSON : Colors.white,
                              brightness: commandContext.commandType == 'on_site' ? Brightness.dark : Brightness.light,
                            ),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => commandContext.commandType = 'on_site',
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 20,
                                  ),
                                  width: MediaQuery.of(context).size.width / 4,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context).translate('on_site'),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      FaIcon(
                                        FontAwesomeIcons.streetView,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Theme(
                            data: ThemeData(
                              cardColor: commandContext.commandType == 'takeaway' ? CRIMSON : Colors.white,
                              brightness: commandContext.commandType == 'takeaway' ? Brightness.dark : Brightness.light,
                            ),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => commandContext.commandType = 'takeaway',
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 20,
                                  ),
                                  width: MediaQuery.of(context).size.width / 4,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context).translate('takeaway'),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      FaIcon(
                                        FontAwesomeIcons.briefcase,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Consumer<BagContext>(
            builder: (_, bagContext, __) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${AppLocalizations.of(context).translate('total_to_pay')} : ',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 22,
                    ),
                  ),
                  Text(
                    '${bagContext.totalPrice}€',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: FlatButton(
              onPressed: () {
                AuthContext authContext = Provider.of<AuthContext>(context, listen: false);

                CommandContext commandContext = Provider.of<CommandContext>(context, listen: false);

                if (authContext.currentUser == null) {
                  if (commandContext.commandType != 'delivery')
                    RouteUtil.goTo(
                      context: context,
                      child: UserDetailsPage(),
                      routeName: userDetailsRoute,
                    );
                  else
                    Fluttertoast.showToast(msg: 'Veuillez vous connecter pour pouvoir continuer');
                  RouteUtil.goTo(
                    context: context,
                    child: LoginPage(),
                    routeName: loginRoute,
                  );
                } else if (commandContext.commandType == 'delivery') {
                  RouteUtil.goTo(
                    context: context,
                    child: DeliveryDetailsPage(),
                    routeName: loginRoute,
                  );
                } else if (commandContext.commandType == 'on_site' || commandContext.commandType == 'takeaway') {
                  RouteUtil.goTo(
                    context: context,
                    child: UserDetailsPage(),
                    routeName: userDetailsRoute,
                  );
                } else {
                  Fluttertoast.showToast(
                    msg: 'Veuillez sélection un type de commande avant de continuer',
                  );
                }
              },
              padding: const EdgeInsets.all(
                20.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.teal,
              child: Text(
                AppLocalizations.of(context).translate("next"),
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
