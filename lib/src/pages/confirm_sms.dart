import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/constants/constant.dart';
import 'package:menu_advisor/src/models/models.dart';
import 'package:menu_advisor/src/pages/choose_payement.dart';
import 'package:menu_advisor/src/pages/summary.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/providers/CommandContext.dart';
import 'package:menu_advisor/src/providers/MenuContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/services/notification_service.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

// ignore: must_be_immutable
class ConfirmSms extends StatefulWidget {
  ConfirmSms({
    Key key,
    this.command,
    this.verificationId,
    this.isFromSignup = false,
    this.phoneNumber,
    this.password,
    this.restaurant,
    this.customer,
    this.code,
    this.fromDelivery = false,
  }) : super(key: key);
  Command command;
  String verificationId;
  bool isFromSignup;
  String phoneNumber;
  String password;
  String code;
  dynamic customer;
  bool fromDelivery;
  Restaurant restaurant;

  @override
  _ConfirmSmsState createState() => _ConfirmSmsState();
}

class _ConfirmSmsState extends State<ConfirmSms> {
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  bool loading = false;

  DateTime dateDelai;

  @override
  void initState() {
    super.initState();
    dateDelai = DateTime.now().add(Duration(minutes: 5));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextTranslator(widget.isFromSignup
            ? "Vérification sms"
            : "confirmation de commande"),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 150,
            ),
            TextTranslator(
              "Code de validation sms",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 15),
            animatingBorders(),
            SizedBox(height: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(
                      EdgeInsets.all(15),
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
                    if (_pinPutController.value.text.isEmpty) {
                      Fluttertoast.showToast(
                        msg: "Entrer votre code",
                        backgroundColor: CRIMSON,
                        textColor: Colors.white,
                      );
                    } else {
                      _submit(_pinPutController.value.text);
                    }
                  },
                  child: loading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: FittedBox(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        )
                      : TextTranslator(
                          "Valider",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                ),
                SizedBox(
                  height: 15,
                ),
                if (widget.isFromSignup)
                  TextButton(
                    onPressed: () {
                      // Provider.of<AuthContext>(context, listen: false).verifyPhoneNumber(
                      //   widget.phoneNumber,
                      //     codeSent: (value){
                      //       widget.verificationId = value;
                      //     });
                    },
                    child: TextTranslator("Renvoyer sms"),
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget animatingBorders() {
    final BoxDecoration pinPutDecoration = BoxDecoration(
      border: Border.all(color: Colors.deepPurpleAccent),
      borderRadius: BorderRadius.circular(15.0),
    );
    return Container(
      width: 250,
      height: 75,
      child: PinPut(
        fieldsCount: widget.isFromSignup ? 4 : 4,
        eachFieldHeight: 50.0,
        onSubmit: (String pin) async {
          _submit(pin);
        },
        focusNode: _pinPutFocusNode,
        controller: _pinPutController,
        submittedFieldDecoration: pinPutDecoration.copyWith(
          borderRadius: BorderRadius.circular(20.0),
        ),
        selectedFieldDecoration: pinPutDecoration,
        followingFieldDecoration: pinPutDecoration.copyWith(
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(
            color: Colors.deepPurpleAccent.withOpacity(.5),
          ),
        ),
      ),
    );
  }

  _submit(String pin) async {
    print(widget.phoneNumber);
    if (_pinPutController.value.text.isEmpty)
      Fluttertoast.showToast(
        msg: "Entrer votre code",
        backgroundColor: CRIMSON,
        textColor: Colors.white,
      );
    if (widget.isFromSignup) {
      AuthContext authContext =
          Provider.of<AuthContext>(context, listen: false);
      try {
        await authContext.confirmPhoneNumber(code: pin);
        await authContext.login(widget.phoneNumber, widget.password);
        RouteUtil.goTo(
          context: context,
          child: HomePage(),
          routeName: homeRoute,
          method: RoutingMethod.atTop,
        );
      } catch (e) {
        print(e['message']);
        switch (e['message']) {
          case "session expired":
            Fluttertoast.showToast(
                msg:
                    "Le code SMS a expiré. Veuillez renvoyer le code de vérification pour réessayer.");
            break;
          case "Invalid confirmation code":
            Fluttertoast.showToast(msg: "Invalide sms code");
            break;
          default:
            Fluttertoast.showToast(msg: "Une erreur est se reproduise");
            break;
        }
      }
    } else {
      CommandContext commandContext = Provider.of<CommandContext>(
        context,
        listen: false,
      );

      CartContext cartContext = Provider.of<CartContext>(
        context,
        listen: false,
      );

      AuthContext authContext =
          Provider.of<AuthContext>(context, listen: false);

      //TODO: COMMENT THIS SMS CHECK FOR TEST DELEVERY
      if (widget.code != pin) {
        Fluttertoast.showToast(msg: "Invalide sms code");
        return;
      }
      //TODO: COMMENT THIS SMS CHECK FOR TEST DELEVERY
      if (this.dateDelai.isBefore(DateTime.now())) {
        Fluttertoast.showToast(
            msg:
                "Votre délai de confirmation est épuisé. Veuillez renvoyer votre code de confirmation.");
        return;
      }

      if (widget.fromDelivery) {
        //TODO: LIVRAISON IMPLEMENTATION
        RouteUtil.goTo(
          context: context,
          child: ChoosePayement(
            restaurant: widget.restaurant,
            customer: widget.customer,
          ),
          routeName: choosePayement,
        );
      } else {
        //TODO: A EMPORTER IMPLEMENTATION
        setState(() {
          loading = true;
        });
        int totalPrice = 0;
        int totalPriceSansRemise = (cartContext.totalPrice * 100).toInt();
        double remiseWithCodeDiscount = cartContext.totalPrice;
        if (commandContext.withCodeDiscount != null) {
          remiseWithCodeDiscount = cartContext.calculremise(
            totalPrice: cartContext.totalPrice,
            discountIsPrice: commandContext.withCodeDiscount.discountIsPrice,
            discountValue: commandContext.withCodeDiscount.value.toDouble(),
          );
        }
        if (widget.restaurant?.discountAEmporter == true) {
          double discountValue = cartContext.discountValueInPlageDiscount(
            discountIsPrice:
                widget.restaurant?.discount?.aEmporter?.discountIsPrice,
            discountValue: widget.restaurant?.discount?.aEmporter?.valueDouble,
            plageDiscount:
                widget.restaurant?.discount?.aEmporter?.plageDiscount,
            totalPriceSansRemise: totalPriceSansRemise.toDouble(),
          );
          totalPrice = cartContext
              .calculremise(
                totalPrice: remiseWithCodeDiscount,
                discountIsPrice:
                    widget.restaurant?.discount?.aEmporter?.discountIsPrice,
                discountValue: discountValue,
              )
              .toInt();
        }

        totalPrice = (totalPrice * 100).toInt();

        ///get tokenFCM
        final sharedPrefs = await SharedPreferences.getInstance();
        final tokenFCM = sharedPrefs.getString(kTokenFCM);

        ///calacul totalDiscount
        final totalDiscount = cartContext.calculTotalDiscount(
            totalPriceSansRemise: totalPriceSansRemise,
            remiseWithCodeDiscount: remiseWithCodeDiscount.toInt());

        ///TODO: await Api.instance.sendCommand - AEMPORTER
        var command = await Api.instance.sendCommand(
          tokenNavigator: tokenFCM,
          totalDiscount: totalDiscount.toString(),
          addCodePromo: commandContext.withCodeDiscount,
          isCodePromo: commandContext.withCodeDiscount != null,
          discount: widget.restaurant?.discount,
          relatedUser: authContext.currentUser?.id ?? null,
          comment: cartContext.comment,
          commandType: commandContext.commandType,
          items: cartContext.items
              .where((e) => !e.isMenu)
              .map((e) => {
                    'quantity': e.quantity,
                    'item': e.id,
                    'options': e.optionSelected != null ? e.optionSelected : [],
                    'comment': e.message
                  })
              .toList(),
          restaurant: cartContext.currentOrigin,
          totalPrice: totalPrice,
          totalPriceSansRemise: totalPriceSansRemise,
          customer: widget.customer,
          shippingTime: commandContext.deliveryDate
                  ?.add(
                    Duration(
                      minutes: commandContext.deliveryTime.hour * 60 +
                          commandContext.deliveryTime.minute,
                    ),
                  )
                  ?.millisecondsSinceEpoch ??
              null,
          menu: cartContext.items
              .where((e) => e.isMenu)
              .map((e) => {
                    'quantity': e.quantity,
                    'item': e.id,
                    'foods': e.foodMenuSelecteds
                  })
              .toList(),
          priceless: !cartContext.withPrice,
        );
        Command cm = Command.fromJson(command);
        cm.codeDiscount = commandContext.withCodeDiscount;
        cm.withCodeDiscount = commandContext.withCodeDiscount != null;

        await sendPushMessage(cm.tokenNavigator,
            message: "Vous avez un commande ${cm.commandType}");

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
        setState(() {
          loading = false;
        });
      }
    }
  }
}
