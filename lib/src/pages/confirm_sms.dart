import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/pages/summary.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:provider/provider.dart';

import 'home.dart';

// ignore: must_be_immutable
class ConfirmSms extends StatefulWidget {
  ConfirmSms({Key key, this.command, this.verificationId, this.isFromSignup = false, this.phoneNumber, this.password}) : super(key: key);
  Command command;
  String verificationId;
  bool isFromSignup;
  String phoneNumber;
  String password;
  @override
  _ConfirmSmsState createState() => _ConfirmSmsState();
}

class _ConfirmSmsState extends State<ConfirmSms> {
  TextEditingController _codeController = TextEditingController();
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextTranslator(widget.isFromSignup ? "Vérification sms" : "Confirme commande"),
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
                RaisedButton(
                  padding: EdgeInsets.all(15),
                  color: CRIMSON,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
                  FlatButton(
                      onPressed: () {
                        // Provider.of<AuthContext>(context, listen: false).verifyPhoneNumber(
                        //   widget.phoneNumber,
                        //     codeSent: (value){
                        //       widget.verificationId = value;
                        //     });
                      },
                      child: TextTranslator("Renvoyer sms"))
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
    if (widget.isFromSignup) {
      AuthContext authContext = Provider.of<AuthContext>(context, listen: false);
      try {
        await authContext.confirmPhoneNumber(code: pin);
        await authContext.login(widget.phoneNumber, widget.password);
        // await Provider.of<AuthContext>(context, listen: false).verifyFirebaseSms(widget.verificationId, pin,
        //  onSucced: () {
        //   print("success");
          RouteUtil.goTo(
            context: context,
            child: HomePage(),
            routeName: homeRoute,
            method: RoutingMethod.atTop,
          );

        // }, onFailed: (e) {
        //   print("failed");
        //   switch (e.code) {
        //     case "session-expired":
        //       Fluttertoast.showToast(msg: "Le code SMS a expiré. Veuillez renvoyer le code de vérification pour réessayer.");
        //       break;
        //     case "invalid-verification-code":
        //       Fluttertoast.showToast(msg: "Invalide sms code");
        //       break;
        //     default:
        //   }
        // });
      } catch (e) {
        print(e['message']);
        switch (e['message']) {
            case "session expired":
              Fluttertoast.showToast(msg: "Le code SMS a expiré. Veuillez renvoyer le code de vérification pour réessayer.");
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
      setState(() {
        loading = true;
      });
      Map<String,dynamic> result = await Api.instance.ConfirmSms(widget.command.id, pin,widget.command.commandType);
      setState(() {
        loading = false;
      });
      if (result.containsKey("message") && result["message"].contains("Bad code")){
        Fluttertoast.showToast(msg: "Invalide sms code");
        return ;
      }

      RouteUtil.goTo(
        context: context,
        child: Summary(commande: widget.command),
        routeName: confirmEmailRoute,
      );
    }
  }
}