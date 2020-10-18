import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/components/cards.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/pages/delivery_details.dart';
import 'package:menu_advisor/src/pages/home.dart';
import 'package:menu_advisor/src/pages/login.dart';
import 'package:menu_advisor/src/pages/summary.dart';
import 'package:menu_advisor/src/pages/user_details.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/providers/CommandContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:provider/provider.dart';

import '../models.dart';

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  bool sendingCommand = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('order'),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  physics: BouncingScrollPhysics(),
                  child: Consumer<CartContext>(
                    builder: (_, cartContext, __) {
                      final List<Widget> list = [];
                      cartContext.items.forEach(
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

                      if (cartContext.itemCount == 0)
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
                              AppLocalizations.of(context)
                                  .translate('all_items'),
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
              Consumer2<CartContext, CommandContext>(
                builder: (_, cartContext, commandContext, __) => Padding(
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
                            AppLocalizations.of(context)
                                .translate('command_type'),
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
                              if (!cartContext.pricelessItems)
                                Theme(
                                  data: ThemeData(
                                    cardColor:
                                        commandContext.commandType == 'delivery'
                                            ? CRIMSON
                                            : Colors.white,
                                    brightness:
                                        commandContext.commandType == 'delivery'
                                            ? Brightness.dark
                                            : Brightness.light,
                                  ),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () => commandContext.commandType =
                                          'delivery',
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 20,
                                        ),
                                        width:
                                            MediaQuery.of(context).size.width /
                                                4,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)
                                                  .translate('delivery'),
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
                                  cardColor:
                                      commandContext.commandType == 'on_site'
                                          ? CRIMSON
                                          : Colors.white,
                                  brightness:
                                      commandContext.commandType == 'on_site'
                                          ? Brightness.dark
                                          : Brightness.light,
                                ),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () =>
                                        commandContext.commandType = 'on_site',
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 20,
                                      ),
                                      width:
                                          MediaQuery.of(context).size.width / 4,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)
                                                .translate('on_site'),
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
                                  cardColor:
                                      commandContext.commandType == 'takeaway'
                                          ? CRIMSON
                                          : Colors.white,
                                  brightness:
                                      commandContext.commandType == 'takeaway'
                                          ? Brightness.dark
                                          : Brightness.light,
                                ),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () =>
                                        commandContext.commandType = 'takeaway',
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 20,
                                      ),
                                      width:
                                          MediaQuery.of(context).size.width / 4,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)
                                                .translate('takeaway'),
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
              Consumer<CartContext>(
                builder: (_, cartContext, __) => Padding(
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
                        '${cartContext.totalPrice}€',
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
                child: Consumer3<CommandContext, AuthContext, CartContext>(
                  builder: (_, commandContext, authContext, cartContext, __) =>
                      FlatButton(
                    onPressed: () async {
                      if (authContext.currentUser == null) {
                        if (commandContext.commandType != 'delivery')
                          RouteUtil.goTo(
                            context: context,
                            child: UserDetailsPage(),
                            routeName: userDetailsRoute,
                          );
                        else {
                          Fluttertoast.showToast(
                              msg:
                                  'Veuillez vous connecter pour pouvoir continuer');
                          RouteUtil.goTo(
                            context: context,
                            child: LoginPage(),
                            routeName: loginRoute,
                          );
                        }
                      } else if (commandContext.commandType == 'delivery') {
                        RouteUtil.goTo(
                          context: context,
                          child: DeliveryDetailsPage(),
                          routeName: loginRoute,
                        );
                      } else if (commandContext.commandType == 'on_site' ||
                          commandContext.commandType == 'takeaway') {
                        try {
                          setState(() {
                            sendingCommand = true;
                          });

                          var command = await Api.instance.sendCommand(
                            relatedUser: authContext.currentUser.id,
                            commandType: commandContext.commandType,
                            items: cartContext.items.entries
                                .map((e) =>
                                    {'quantity': e.value, 'item': e.key.id})
                                .toList(),
                            restaurant: cartContext.currentOrigin,
                            totalPrice: (cartContext.totalPrice * 100).round(),
                          );
                          CommandModel cm = CommandModel.fromJson(command);

                          cartContext.clear();
                          commandContext.clear();
                          Fluttertoast.showToast(
                            msg: AppLocalizations.of(context)
                                .translate('success'),
                          );
                          RouteUtil.goTo(
                            context: context,
                            child: HomePage(),
                            routeName: homeRoute,
                            method: RoutingMethod.atTop,
                          );
                          RouteUtil.goTo(
                                              context: context,
                                              child: Summary(commande: cm,),
                                              routeName: homeRoute,
                                              // method: RoutingMethod.atTop,
                                            );
                        } catch (error) {
                          Fluttertoast.showToast(
                            msg: 'Erreur lors de l\'envoi de la commande',
                          );
                        }
                      } else {
                        Fluttertoast.showToast(
                          msg:
                              'Veuillez sélection un type de commande avant de continuer',
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
                      commandContext.commandType == null
                          ? AppLocalizations.of(context).translate('validate')
                          : (commandContext.commandType != 'delivery' &&
                                  authContext.currentUser != null)
                              ? AppLocalizations.of(context)
                                  .translate('validate')
                              : AppLocalizations.of(context).translate('next'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (sendingCommand)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(CRIMSON),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
