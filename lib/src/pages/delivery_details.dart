import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// import 'package:flutter_collapse/flutter_collapse.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/constants/constant.dart';
import 'package:menu_advisor/src/models/restaurants/restaurant_discount_model.dart';
import 'package:menu_advisor/src/pages/confirm_sms.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/providers/CommandContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/extensions.dart';
import 'package:menu_advisor/src/utils/textFormFieldTranslator.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:place_picker/place_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/models.dart';

class DeliveryDetailsPage extends StatefulWidget {
  final Restaurant restaurant;

  DeliveryDetailsPage({this.restaurant});

  @override
  _DeliveryDetailsPageState createState() => _DeliveryDetailsPageState();
}

class _DeliveryDetailsPageState extends State<DeliveryDetailsPage> {
  DateTime deliveryDate;
  TimeOfDay deliveryTime;
  GlobalKey<FormState> formKey = GlobalKey();
  DateTime now = DateTime.now();

  Restaurant _restaurant;

  CommandContext commandContext;
  AuthContext authContext;
  bool sendingCommand = false;
  TextEditingController addrContr = TextEditingController();
  TextEditingController postalCodeContr = TextEditingController();
  TextEditingController codepostalCodeContr = TextEditingController();
  TextEditingController etageContr = TextEditingController();

  bool myAddressLoading = false;

  //Devant la porte - Rdv à la porte - A l'exterieur -- behind_the_door / on_the_door / out --

  String optionRdv = "behind_the_door";

  @override
  void initState() {
    super.initState();
    _restaurant = widget.restaurant;
    _restaurant.optionLivraison = optionRdv;
    commandContext = Provider.of<CommandContext>(
      context,
      listen: false,
    );
    authContext = Provider.of<AuthContext>(
      context,
      listen: false,
    );

    deliveryDate = now.add(Duration(days: 0));
    deliveryTime = TimeOfDay(hour: now.hour, minute: 00);

    commandContext.deliveryTime = deliveryTime;
    commandContext.deliveryDate = deliveryDate;
  }

  @override
  Widget build(BuildContext context) {
    _restaurant = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: TextTranslator(
          AppLocalizations.of(context).translate('delivery_details'),
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Consumer<CommandContext>(
                    builder: (_, commandContext, __) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(
                            30,
                          ),
                          color: Colors.white,
                          child: TextFormFieldTranslator(
                            suffixIcon: SizedBox(
                              width: 100,
                              child: TextButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(CRIMSON)),
                                onPressed: () async {
                                  setState(() {
                                    myAddressLoading = true;
                                  });
                                  final res =
                                      await commandContext.getLatLngFromAddress(
                                          authContext.currentUser.address);
                                  if (res != null) {
                                    addrContr.text =
                                        authContext.currentUser.address;
                                    // addrContr.text = res.formattedAddress;
                                    final latLng = LatLng(
                                        res.geometry.location.lat,
                                        res.geometry.location.lng);
                                    commandContext.deliveryLatLng = latLng;
                                    commandContext.deliveryAddress =
                                        authContext.currentUser.address;
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: 'Adresse introvable',
                                    );
                                  }

                                  setState(() {
                                    myAddressLoading = false;
                                  });
                                },
                                child: myAddressLoading
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : TextTranslator(
                                        "Utiliser mon addresse",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                            controller: addrContr,
                            keyboardType: TextInputType.streetAddress,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)
                                  .translate("address_placeholder"),
                            ),
                            onChanged: (value) {
                              commandContext.deliveryAddress = value;
                            },
                            onTap: () async {
                              LocationResult result =
                                  await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => PlacePicker(
                                    GOOGLE_API_KEY,
                                    displayLocation:
                                        LatLng(31.1975844, 29.9598339),
                                  ),
                                ),
                              );
                              print("$logTrace result = $result");
                              addrContr.text = result.formattedAddress;
                              commandContext.deliveryAddress =
                                  result.formattedAddress;
                              commandContext.deliveryLatLng = result.latLng;
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                              left: 30, right: 30, bottom: 30),
                          color: Colors.white,
                          child: TextFormFieldTranslator(
                            controller: codepostalCodeContr,
                            enabled: addrContr.text.isEmpty ? false : true,
                            keyboardType: TextInputType.streetAddress,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: "Code Appartement",
                            ),
                            onChanged: (value) {
                              // commandContext.deliveryAddress = value;
                              _restaurant.codeappartement =
                                  codepostalCodeContr.text;
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                              left: 30, right: 30, bottom: 30),
                          color: Colors.white,
                          child: TextFormFieldTranslator(
                            controller: postalCodeContr,
                            enabled: addrContr.text.isEmpty ? false : true,
                            keyboardType: TextInputType.streetAddress,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: "Appartement",
                            ),
                            onChanged: (value) {
                              // commandContext.deliveryAddress = value;
                              _restaurant.appartement = postalCodeContr.text;
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                              left: 30, right: 30, bottom: 30),
                          color: Colors.white,
                          child: TextFormFieldTranslator(
                            controller: etageContr,
                            enabled: addrContr.text.isEmpty ? false : true,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: "Etage",
                            ),
                            onChanged: (value) {
                              // commandContext.deliveryAddress = value;
                              if (etageContr.text.isNotEmpty)
                                _restaurant.etage = int.parse(etageContr.text);
                            },
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        ExpandableNotifier(
                          child: Container(
                            color: Colors.white,
                            child: ScrollOnExpand(
                              scrollOnExpand: true,
                              scrollOnCollapse: false,
                              child: ExpandablePanel(
                                theme: const ExpandableThemeData(
                                  headerAlignment:
                                      ExpandablePanelHeaderAlignment.center,
                                  tapBodyToCollapse: true,
                                  hasIcon: true,
                                ),
                                header: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 35.0,
                                    vertical: 15,
                                  ),
                                  child: TextTranslator(
                                    "Options de livraison",
                                    textAlign: TextAlign.start,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                collapsed: Container(),
                                expanded: Container(
                                  color: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                  ),
                                  child: Column(
                                    children: [
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              optionRdv = "behind_the_door";
                                              _restaurant.optionLivraison =
                                                  optionRdv;
                                            });
                                          },
                                          child: ListTile(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 25.0),
                                            title: TextTranslator(
                                              "Devant la porte",
                                            ),
                                            leading: Icon(
                                              Icons.timer,
                                            ),
                                            trailing: optionRdv ==
                                                    "behind_the_door"
                                                ? Icon(
                                                    Icons.check,
                                                    color: Colors.green[300],
                                                  )
                                                : null,
                                          ),
                                        ),
                                      ),
                                      Divider(),
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              optionRdv = "on_the_door";
                                              _restaurant.optionLivraison =
                                                  optionRdv;
                                            });
                                          },
                                          child: ListTile(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 25.0),
                                            title: TextTranslator(
                                              "Rdv à la porte",
                                            ),
                                            leading: Icon(
                                              Icons.timer,
                                            ),
                                            trailing: optionRdv == "on_the_door"
                                                ? Icon(
                                                    Icons.check,
                                                    color: Colors.green[300],
                                                  )
                                                : null,
                                          ),
                                        ),
                                      ),
                                      Divider(),
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              optionRdv = "out";
                                              _restaurant.optionLivraison =
                                                  optionRdv;
                                            });
                                          },
                                          child: ListTile(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 25.0),
                                            title: TextTranslator(
                                              "A l'exterieur",
                                            ),
                                            leading: Icon(
                                              Icons.timer,
                                            ),
                                            trailing: optionRdv == "out"
                                                ? Icon(
                                                    Icons.check,
                                                    color: Colors.green[300],
                                                  )
                                                : null,
                                          ),
                                        ),
                                      ),
                                      Divider(),
                                    ],
                                  ),
                                ),
                                builder: (_, collapsed, expanded) {
                                  return Expandable(
                                    collapsed: collapsed,
                                    expanded: expanded,
                                    theme: const ExpandableThemeData(
                                        crossFadePoint: 0),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        ExpandableNotifier(
                          child: Container(
                            color: Colors.white,
                            child: ScrollOnExpand(
                              scrollOnExpand: true,
                              scrollOnCollapse: false,
                              child: ExpandablePanel(
                                theme: const ExpandableThemeData(
                                  headerAlignment:
                                      ExpandablePanelHeaderAlignment.center,
                                  tapBodyToCollapse: true,
                                  hasIcon: true,
                                ),
                                header: Container(
                                  // color: Colors.grey,
                                  // width: MediaQuery.of(context).size.width - 50,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 35.0,
                                    vertical: 15,
                                  ),
                                  child: TextTranslator(
                                    AppLocalizations.of(context)
                                        .translate('date_and_time'),
                                    textAlign: TextAlign.start,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                collapsed: Container(),
                                expanded: Container(
                                  color: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                  ),
                                  child: Column(
                                    children: [
                                      /*Material( TODO: Remove dès que possible option - DELIVERY
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              deliveryDate = null;
                                              deliveryTime = null;
                                            });
                                          },
                                          child: ListTile(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 25.0),
                                            title: TextTranslator(
                                              AppLocalizations.of(context)
                                                  .translate(
                                                      'as_soon_as_possible'),
                                            ),
                                            leading: Icon(
                                              Icons.timer,
                                            ),
                                            trailing: deliveryDate == null &&
                                                    deliveryTime == null
                                                ? Icon(
                                                    Icons.check,
                                                    color: Colors.green[300],
                                                  )
                                                : null,
                                          ),
                                        ),
                                      ),
                                      Divider(),*/
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () async {
                                            setState(() {
                                              deliveryDate =
                                                  now.add(Duration(days: 0));
                                              deliveryTime = TimeOfDay(
                                                  hour: now.hour, minute: 00);

                                              commandContext.deliveryDate =
                                                  deliveryDate;
                                              commandContext.deliveryTime =
                                                  deliveryTime;
                                            });
                                          },
                                          child: ListTile(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 25.0),
                                            title: TextTranslator(
                                              'Planifier une commande',
                                            ),
                                            leading: Icon(
                                              Icons.calendar_today_outlined,
                                            ),
                                            trailing: deliveryDate != null &&
                                                    deliveryTime != null
                                                ? Icon(
                                                    Icons.check,
                                                    color: Colors.green[300],
                                                  )
                                                : null,
                                          ),
                                        ),
                                      ),
                                      if (deliveryDate != null) ...[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            _datePicker(),
                                            _timePicker(),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                builder: (_, collapsed, expanded) {
                                  return Expandable(
                                    collapsed: collapsed,
                                    expanded: expanded,
                                    theme: const ExpandableThemeData(
                                        crossFadePoint: 0),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(
                20,
              ),
              child: ElevatedButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                    EdgeInsets.all(20),
                  ),
                  backgroundColor: MaterialStateProperty.all(
                    CRIMSON,
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                onPressed: () async {
                  if (!_restaurant.isOpenByDate(deliveryDate, deliveryTime)) {
                    print('fermé');
                    Fluttertoast.showToast(msg: 'Le restaurant est fermé');
                    return;
                  }
                  FormState formState = formKey.currentState;

                  if (addrContr.text.isEmpty) {
                    Fluttertoast.showToast(
                      msg: "Entrer votre adresse de livraison",
                    );
                    return;
                  }

                  if (formState.validate()) {
                    AuthContext authContext = Provider.of<AuthContext>(
                      context,
                      listen: false,
                    );
                    CartContext cartContext = Provider.of<CartContext>(
                      context,
                      listen: false,
                    );

                    if (widget.restaurant.deliveryFixed == true) {
                      _next(authContext);
                      return;
                    }

                    if (widget.restaurant
                        .isFreeCP(commandContext.deliveryAddress)) {
                      await Fluttertoast.showToast(
                        msg: "Livraison est gratuite à ce CP",
                      );
                      _next(authContext);
                      return;
                    }

                    if (widget.restaurant
                        .isFreeCity(commandContext.deliveryAddress)) {
                      await Fluttertoast.showToast(
                        msg: "Livraison est gratuite à cette ville",
                      );
                      _next(authContext);
                      return;
                    }
                    final distance = commandContext
                        .getDeliveryDistanceByMiles(widget.restaurant)
                        .round();

                    if (distance > widget.restaurant.distanceMaxDouble) {
                      await Fluttertoast.showToast(
                        msg:
                            "Pas de livraison plus ${widget.restaurant.distanceMaxDouble} km",
                      );
                      return;
                    }

                    ///delivery process - init all params
                    int totalPrice = 0;
                    int totalPriceSansRemise =
                        (cartContext.totalPrice * 100).round();
                    int priceLivraison = 0;
                    final priceLivraisonSansRemise = commandContext
                        .getDeliveryPriceByMiles(widget.restaurant)
                        .round();
                    double remise = 0; //in €
                    String remiseType = "totalité";
                    int discountCode =
                        0; // prix en euro an'le code promo, default value : 0

                    if (widget.restaurant.deliveryFixed) {
                      priceLivraison = (widget.restaurant.priceDelevery != null
                              ? widget.restaurant.priceDelevery
                              : 0)
                          .round();
                      totalPrice =
                          (cartContext.totalPrice + priceLivraison).round();
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
                          double remiseWithCodeDiscount =
                              cartContext.totalPrice;
                          if (commandContext.withCodeDiscount != null) {
                            remiseWithCodeDiscount = cartContext.calculremise(
                              totalPrice: cartContext.totalPrice,
                              discountIsPrice: commandContext
                                  .withCodeDiscount.discountIsPrice,
                              discountValue: commandContext
                                  .withCodeDiscount.value
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
                              remiseType = "livraison";
                              remise = cartContext.discountValueInPlageDiscount(
                                plageDiscounts: widget.restaurant?.discount
                                    ?.delivery?.plageDiscount,
                                price: totalPriceSansRemise.toDouble(),
                              );
                              priceLivraison = cartContext
                                  .calculremise(
                                    totalPrice: priceLivraison.toDouble(),
                                    discountIsPrice: true,
                                    discountValue: remise,
                                  )
                                  .round();
                              totalPrice =
                                  (remiseWithCodeDiscount + priceLivraison)
                                      .round();
                            } else if (widget.restaurant?.discount?.delivery
                                    ?.discountType ==
                                DiscountType.SurCommande) {
                              ///remise sur le commande
                              remiseType = "commande";
                              remise = cartContext.discountValueInPlageDiscount(
                                plageDiscounts: widget.restaurant?.discount
                                    ?.delivery?.plageDiscount,
                                price: totalPriceSansRemise.toDouble(),
                              );
                              int totalPriceWithRemise = cartContext
                                  .calculremise(
                                      totalPrice: remiseWithCodeDiscount,
                                      discountIsPrice: true,
                                      discountValue: remise)
                                  .round();
                              totalPrice =
                                  (totalPriceWithRemise + priceLivraison)
                                      .round();
                            } else {
                              ///remise sur la totalité
                              remiseType = "totalité";
                              remise = cartContext.discountValueInPlageDiscount(
                                plageDiscounts: widget.restaurant?.discount
                                    ?.delivery?.plageDiscount,
                                price: totalPriceSansRemise.toDouble(),
                              );
                              totalPrice = cartContext
                                  .calculremise(
                                      totalPrice: remiseWithCodeDiscount +
                                          priceLivraison,
                                      discountIsPrice: true,
                                      discountValue: remise)
                                  .round();
                            }
                          }
                        }
                      }
                      totalPrice = totalPrice.round();
                    }

                    final confirm = await showDialog(
                      context: context,
                      builder: (_) => ConfirmationDialog(
                          title: "",
                          isSimple: true,
                          content: null,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextTranslator(
                                    "Total ",
                                  ),
                                  TextTranslator(
                                    "${totalPriceSansRemise / 100} €",
                                  ),
                                ],
                              ),
                              Divider(),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextTranslator(
                                        "Frais de livraison",
                                      ),
                                      TextTranslator(
                                        "+$priceLivraisonSansRemise €",
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (commandContext.withCodeDiscount != null) ...[
                                Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextTranslator(
                                      "Remise avec code promo ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextTranslator(
                                      "-$discountCode €",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                              Divider(),
                              if (remise != 0) ...[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextTranslator(
                                      "Remise sur $remiseType",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextTranslator(
                                      "-${remise.round()} €",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Divider(),
                              ],
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextTranslator(
                                    "Total à payer",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextTranslator(
                                    "$totalPrice €",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          )),
                    );
                    if (confirm != true) {
                      return;
                    }
                    _next(authContext);
                  }
                },
                child: this.sendingCommand
                    ? Center(
                        child: SizedBox(
                          height: 23,
                          width: 23,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      )
                    : TextTranslator(
                        AppLocalizations.of(context).translate('next'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future _next(AuthContext authContext) async {
    if (authContext.currentUser != null) {
      var customer = {
        'name': authContext.currentUser?.name,
        'address': authContext.currentUser?.address,
        'phoneNumber': authContext.currentUser?.phoneNumber,
        'email': authContext.currentUser?.email
      };
      setState(() {
        sendingCommand = true;
      });
      String code = await Api.instance.sendCode(
        relatedUser: authContext.currentUser?.id ?? null,
        customer: customer,
        commandType: commandContext.commandType,
      );
      // String code = "1234";
      RouteUtil.goTo(
        context: context,
        child: ConfirmSms(
          command: null,
          isFromSignup: false,
          customer: customer,
          code: code,
          fromDelivery: true,
          restaurant: _restaurant,
        ),
        routeName: homeRoute,
        // method: RoutingMethod.atTop,
      );
      setState(() {
        sendingCommand = false;
      });
    }
  }

  Widget _datePicker() {
    return Card(
      elevation: 1,
      margin: EdgeInsets.all(0),
      child: Container(
        height: 40,
        width: MediaQuery.of(context).size.width / 2 - 25,
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Center(
          child: DropdownButton<DateTime>(
            elevation: 16,
            isExpanded: true,
            isDense: true,
            value: deliveryDate,
            onChanged: (DateTime date) {
              String dayName = DateFormat.EEEE('fr_FR').format(date);
              setState(() {
                print(dayName);
                if (_restaurant.openingTimes
                    .where((v) => v.day.toLowerCase() == dayName)
                    .isNotEmpty) {
                  print('ouvert');
                  deliveryDate = date;
                  commandContext.deliveryDate = deliveryDate;

                  if (deliveryDate.day == now.day) {
                    if (deliveryTime.hour <= now.hour) {
                      deliveryTime = TimeOfDay(hour: now.hour, minute: 00);
                    }
                  } else if (deliveryTime.hour <=
                      _restaurant.getFirstOpeningHour(deliveryDate,
                          force: true)) {
                    deliveryTime = TimeOfDay(
                        hour: _restaurant.getFirstOpeningHour(deliveryDate),
                        minute: 00);
                  }

                  commandContext.deliveryTime = deliveryTime;
                  // isToday = deliveryDate.day == now.day;
                  // print("isToday $isToday");

                } else {
                  print('fermé');
                  Fluttertoast.showToast(msg: 'Le restaurant est fermé');
                }
              });
            },
            style: TextStyle(
                color: Colors.grey[700], decoration: TextDecoration.none),
            underline: Container(),
            selectedItemBuilder: (_) {
              return List.generate(24, (index) {
                // isToday = index == 0 ;

                return TextTranslator(
                    index == 0
                        ? "Aujourd'hui"
                        : index == 1
                            ? "Demain"
                            : "${now.add(Duration(days: index)).dateToString("EE dd MMM")}",
                    style: TextStyle(
                        fontSize: 18,
                        color: CRIMSON,
                        fontWeight: FontWeight.w600));
              });
            },
            items: [
              for (int i = 0; i < 4; i++)
                DropdownMenuItem<DateTime>(
                    value: now.add(Duration(days: i)),
                    child: TextTranslator(
                      i == 0
                          ? "Aujourd'hui"
                          : i == 1
                              ? "Demain"
                              : "${now.add(Duration(days: i)).dateToString("EE dd MMMM")}",
                      style: TextStyle(fontSize: 20),
                    )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timePicker() {
    return Card(
      elevation: 1,
      margin: EdgeInsets.all(0),
      child: Container(
        height: 40,
        width: MediaQuery.of(context).size.width / 2 - 25,
        color: CRIMSON,
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Center(
          child: DropdownButton<TimeOfDay>(
            elevation: 0,
            isDense: true,
            isExpanded: true,
            value: deliveryTime,
            selectedItemBuilder: (_) {
              return [
                for (int i = deliveryDate.day == now.day
                        ? now.hour
                        : _restaurant.getFirstOpeningHour(deliveryDate);
                    i < 24;
                    i++) ...[
                  DropdownMenuItem<TimeOfDay>(
                      value: TimeOfDay(hour: i, minute: 00),
                      child: TextTranslator(
                        now.hour == i
                            ? "${TimeOfDay(hour: i, minute: (DateTime.now().add(Duration(minutes: 15)).minute)).format(context)}"
                            : "${TimeOfDay(hour: i, minute: 00).format(context)}",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      )),
                ]
              ];
            },
            onChanged: (TimeOfDay time) {
              setState(() {
                deliveryTime = time;
                commandContext.deliveryTime = deliveryTime;
              });
            },
            iconEnabledColor: Colors.white,
            iconDisabledColor: Colors.white,
            style: TextStyle(
              color: Colors.grey[700],
            ),
            underline: Container(),
            items: [
              for (int i = deliveryDate.day == now.day
                      ? now.hour
                      : _restaurant.getFirstOpeningHour(deliveryDate);
                  i < 24;
                  i++) ...[
                // if (deliveryDate.day == now.day && now.hour <= i)...[
                DropdownMenuItem<TimeOfDay>(
                    value: TimeOfDay(hour: i, minute: 00),
                    child: TextTranslator(
                      now.hour == i
                          ? "${TimeOfDay(hour: i, minute: (DateTime.now().add(Duration(minutes: 15)).minute)).format(context)}"
                          : "${TimeOfDay(hour: i, minute: 00).format(context)}",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    )),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
