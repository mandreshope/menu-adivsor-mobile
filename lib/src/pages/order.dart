import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/components/buttons.dart';
import 'package:menu_advisor/src/components/cards.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/pages/confirm_sms.dart';
import 'package:menu_advisor/src/pages/delivery_details.dart';
import 'package:menu_advisor/src/pages/login.dart';
import 'package:menu_advisor/src/pages/summary.dart';
import 'package:menu_advisor/src/pages/user_details.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/providers/CommandContext.dart';
import 'package:menu_advisor/src/providers/MenuContext.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models.dart';

class OrderPage extends StatefulWidget {
  final bool withPrice;
  OrderPage({this.withPrice = true});
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  bool sendingCommand = false;
  CartContext _cartContext;
  Restaurant _restaurant;
 Api _api = Api.instance;

 bool isRestaurantLoading = true;
 TextEditingController comment = TextEditingController();

  TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
     _cartContext = Provider.of<CartContext>(context,listen: false);

    _api
        .getRestaurant(
      id: _cartContext.currentOrigin,
      lang: Provider.of<SettingContext>(
        context,
        listen: false,
      ).languageCode,
    ).then((value) {
      _restaurant = value;
      setState(() {
        isRestaurantLoading = false;
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextTranslator(
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
                      String id = "-1";
                      cartContext.items.forEach(
                        (food,count) {
                          //if (food.price != null)
                          if (food.id != id){
                            id = food.id;
                            list.add(
                              BagItem(
                                food: food,
                                count: count,
                                withPrice: widget.withPrice,
                              ),
                            );
                          }
                            
                        },
                      );

                      if (cartContext.itemCount == 0)
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10.0,
                          ),
                          child: TextTranslator(
                            AppLocalizations.of(context).translate('no_item_in_cart'),
                            textAlign: TextAlign.center,
                          ),
                        );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          isRestaurantLoading ? Align(
                            alignment: Alignment.topCenter,
                            child: CircularProgressIndicator( valueColor: AlwaysStoppedAnimation<Color>(
                                              CRIMSON,
                                            ),),
                          )
                          :
                          Padding(
                            padding: const EdgeInsets.only(top: 20, right: 20, left: 20, bottom: 15),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.network(
                                  _restaurant.imageURL,
                                  // width: 4 * MediaQuery.of(context).size.width / 7,
                                  width: MediaQuery.of(context).size.width / 4,
                                  height: MediaQuery.of(context).size.width / 4,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextTranslator(
                                      _restaurant.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.mapMarkerAlt,
                                          size: 12,
                                          color: CRIMSON,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Container(
                                          width: (MediaQuery.of(context).size.width -  MediaQuery.of(context).size.width / 3) - 95,
                                          child: TextTranslator(
                                            _restaurant.address,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.phoneAlt,
                                          size: 12,
                                          color: CRIMSON,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        InkWell(
                                          onTap: () async {
                                            if (_restaurant.phoneNumber != null)
                                            await launch(
                                                "tel:${_restaurant.phoneNumber}");
                                          },
                                             child: TextTranslator(
                                            "Tel : ${_restaurant.phoneNumber ?? "0"}",
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black54),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextTranslator(
                                  AppLocalizations.of(context).translate('all_items'),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                InkWell(
                                  child: Icon(Icons.delete,color: Colors.grey,),
                                  onTap: (){
                                    cartContext.clear();
                                    RouteUtil.goBack(context: context);
                                  },
                                )
                              ],
                            ),
                          ),
                          ...list,
                          Divider(),
                          Card(
                            elevation: 2.0,
                            margin: const EdgeInsets.all(10.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                              child: Container(
                              height: 150,
                              padding: EdgeInsets.symmetric(horizontal: 25),
                              child: TextFormField(
                                controller: _messageController,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                showCursor: true,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Votre commentaire..."
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              if (widget.withPrice)...[
                Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextTranslator(
                              'Frais de livraison : ',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 18,
                                color: Colors.grey
                              ),
                            ),
                            Text(
                              _restaurant?.priceDelevery == null ? "" : '${_restaurant?.priceDelevery/100 ?? ''}€',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.grey
                              ),
                            ),
                          ],
                        ),
                      ),
              Consumer<CartContext>(
                builder: (_, cartContext, __) => cartContext.pricelessItems
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextTranslator(
                              '${AppLocalizations.of(context).translate('total_to_pay')} : ',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                             !Provider.of<CartContext>(context,listen: false).withPrice ? "_" : _restaurant?.priceDelevery == null ? '${cartContext.totalPrice.toStringAsFixed(2)}€' : '${(cartContext.totalPrice + (_restaurant?.priceDelevery/100)).toStringAsFixed(2)}€',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              
              ],
              Padding(
                padding: const EdgeInsets.all(15),
                child: Consumer3<CommandContext, AuthContext, CartContext>(
                  builder: (_, commandContext, authContext, cartContext, __) => 
                  Container(
                        width: MediaQuery.of(context).size.width - 100,
                        child: FlatButton(
                          onPressed: () async {
                            // _command(commandContext, authContext, cartContext);
                            if (cartContext.pricelessItems || !widget.withPrice) {
                              commandContext.commandType = 'on_site';
                              _command(commandContext, authContext, cartContext);
                            } else {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (_) {
                                    return _commandType();
                                  });
                            }
                          },
                          padding: const EdgeInsets.all(
                            20.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          color: Colors.teal,
                          child: TextTranslator(
                            AppLocalizations.of(context).translate('validate'),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  // Spacer(),
                  /*InkWell(
                    
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: CRIMSON
                      ),
                      child: Icon(
                        Icons.comment,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                    onTap: () async {
                      // sendComment
                    },
                  ),*/

                    
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

  _command(commandContext, authContext, CartContext cartContext) async {
    cartContext.comment = _messageController.text;
    if (authContext.currentUser == null) {
      if (commandContext.commandType != 'delivery') {
        if (commandContext.commandType == 'on_site') {
          
          try {
            setState(() {
              sendingCommand = true;
            });

            var command = await Api.instance.sendCommand(
              comment: cartContext.comment,
              relatedUser: authContext.currentUser?.id ?? null,
              commandType: commandContext.commandType,
              items: cartContext.items.entries.where((e) => !e.key.isMenu).map((e) => {'quantity': e.value, 'item': e.key.id, 'options': cartContext.options[e.key.id] != null ? cartContext.options[e.key.id].expand((element) => element).toList() : [],'comment':e.key.message}).toList(),
              restaurant: cartContext.currentOrigin,
              totalPrice: (cartContext.totalPrice * 100).round(),
              menu: 
              cartContext.items.entries.where(
                (e) => e.key.isMenu).map(
                  (e) => 
                  {
                    'quantity': e.value, 
                    'item': e.key.id, 
                    'foods': 
                cartContext.foodMenuSelecteds
              }).toList(),
                priceless: !cartContext.withPrice
            );
            Command cm = Command.fromJson(command);

            cartContext.clear();
            commandContext.clear();
            Provider.of<MenuContext>(context,listen: false).clear();
            Fluttertoast.showToast(
              msg: AppLocalizations.of(context).translate('success'),
            );

            setState(() {
              sendingCommand = false;
            });

            Navigator.of(context).pop(); // pop loading dialog

            RouteUtil.goTo(
              context: context,
              child: Summary(
                commande: cm,
              ),
              routeName: summaryRoute,
              // method: RoutingMethod.atTop,
            );
          } catch (error) {
            setState(() {
              sendingCommand = false;
            });
            Fluttertoast.showToast(
              msg: 'Erreur lors de l\'envoi de la commande',
            );
          }
        } else if (commandContext.commandType == 'takeaway') {
          RouteUtil.goTo(
            context: context,
            child: UserDetailsPage(),
            routeName: userDetailsRoute,
            arguments: _restaurant
          );
        } else {
          RouteUtil.goTo(
            context: context,
            child: UserDetailsPage(),
            routeName: userDetailsRoute,
              arguments: _restaurant
          );
        }
      } else {
        Fluttertoast.showToast(msg: 'Veuillez vous connecter pour pouvoir continuer');
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
          arguments: _restaurant
      );
    } else if (commandContext.commandType == 'takeaway') {
      RouteUtil.goTo(
        context: context,
        child: UserDetailsPage(),
        routeName: userDetailsRoute,
          arguments: _restaurant
      );
    } else if (commandContext.commandType == 'on_site' /* || commandContext.commandType == 'takeaway'*/) {
      try {
        setState(() {
          sendingCommand = true;
        });

        var command = await Api.instance.sendCommand(
          comment: cartContext.comment,
          relatedUser: authContext.currentUser.id,
          commandType: commandContext.commandType,
          items: cartContext.items.entries.where((e) => !e.key.isMenu).map((e) => {'quantity': e.value, 'item': e.key.id, 'options': cartContext.options[e.key.id] != null ? cartContext.options[e.key.id].expand((element) => element).toList() : [],'comment':e.key.message}).toList(),
          restaurant: cartContext.currentOrigin,
          totalPrice: (cartContext.totalPrice * 100).round(),
        menu: cartContext.items.entries.where(
                (e) => 
                e.key.isMenu).map(
                  (e) => 
                  {
                    'quantity': e.value, 
                    'item': e.key.id, 
                    'foods': 
                cartContext.foodMenuSelecteds
              }).toList(),
            priceless: !cartContext.withPrice
        );
        Command cm = Command.fromJson(command);

        cartContext.clear();
        commandContext.clear();
        Provider.of<MenuContext>(context,listen: false).clear();
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context).translate('success'),
        );

        setState(() {
          sendingCommand = false;
        });

        Navigator.of(context).pop();

        RouteUtil.goTo(
          context: context,
          child: Summary(
                commande: cm,
              ),
          routeName: summaryRoute,
          method: RoutingMethod.replaceLast,
        );
      } catch (error) {
        setState(() {
          sendingCommand = false;
        });

        Fluttertoast.showToast(
          msg: 'Erreur lors de l\'envoi de la commande',
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: 'Veuillez sélection un type de commande avant de continuer',
      );
    }
  }

  Widget _commandType() => Consumer3<CommandContext, AuthContext, CartContext>(
        builder: (_, commandContext, authContext, cartContext, __) => Padding(
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextTranslator(
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
                      if (!cartContext.pricelessItems)
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
                              onTap: () {
                                commandContext.commandType = 'delivery';
                                _command(commandContext, authContext, cartContext);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 20,
                                ),
                                width: MediaQuery.of(context).size.width / 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    TextTranslator(
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
                            onTap: () {
                              commandContext.commandType = 'on_site';
                              _command(commandContext, authContext, cartContext);
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 20,
                              ),
                              width: MediaQuery.of(context).size.width / 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  TextTranslator(
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
                            onTap: () {
                              commandContext.commandType = 'takeaway';
                              _command(commandContext, authContext, cartContext);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 20,
                              ),
                              width: MediaQuery.of(context).size.width / 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  TextTranslator(
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
      );
}
