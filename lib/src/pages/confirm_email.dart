import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/pages/login.dart';
import 'package:menu_advisor/src/pages/order.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textFormFieldTranslator.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';

class ConfirmEmailPage extends StatefulWidget {
  final String email;
  final String registrationToken;

  ConfirmEmailPage({
    Key key,
    @required this.registrationToken,
    @required this.email,
  }) : super(key: key);

  @override
  _ConfirmEmailPageState createState() => _ConfirmEmailPageState();
}

class _ConfirmEmailPageState extends State<ConfirmEmailPage> with SingleTickerProviderStateMixin {
  bool loading = false;
  List<FocusNode> _codeFocus = [
    for (var i = 0; i < 4; i++) FocusNode(),
  ];
  List<int> digits = [0, 0, 0, 0];
  AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: 30,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 60.0,
                  left: 40.0,
                  right: 40.0,
                  bottom: 10.0,
                ),
                child: TextTranslator(
                  AppLocalizations.of(context).translate("enter_code").replaceAll('*', widget.email),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              TextTranslator(
                AppLocalizations.of(context).translate("email_not_yours"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CRIMSON,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < 4; i++)
                    Container(
                      width: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: RawKeyboardListener(
                        focusNode: FocusNode(),
                        autofocus: i == 0,
                        onKey: (event) {
                          print(event.character);
                        },
                        child: TextFormFieldTranslator(
                          focusNode: _codeFocus[i],
                          autofocus: i == 0,
                          keyboardType: TextInputType.number,
                          textInputAction: i < 3 ? TextInputAction.next : TextInputAction.done,
                          decoration: InputDecoration(),
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(new RegExp(r'^[0-9]$')),
                          ],
                          onChanged: (value){
                            digits[i] = int.parse(
                              value,
                              radix: 10,
                            );
                          },
                          onFieldSubmitted: (value) {
                            _codeFocus[i].unfocus();
                            digits[i] = int.parse(
                              value,
                              radix: 10,
                            );
                            if (i < 3) {
                              FocusScope.of(context).requestFocus(_codeFocus[i + 1]);
                            } else {
                              _submitForm();
                            }
                          },
                        ),
                      ),
                    ),
                ],
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.all(20),
                child: RaisedButton(
                  padding: EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onPressed: _submitForm,
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
      ),
    );
  }

  _submitForm() async {
    int code = int.parse(digits.join(''));

    AuthContext authContext = Provider.of<AuthContext>(
      context,
      listen: false,
    );

    CartContext cartContext = Provider.of<CartContext>(
      context,
      listen: false,
    );

    try {
      await authContext.validateAccount(
        registrationToken: widget.registrationToken,
        code: code,
      );

      Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translate('validation_successfull'),
      );

      if (cartContext.itemCount > 0)
        RouteUtil.goToAndRemoveUntil(
          context: context,
          child: OrderPage(),
          routeName: orderRoute,
          predicate: (route) => route.settings.name == orderRoute,
        );
      else
        RouteUtil.goTo(
          context: context,
          child: LoginPage(),
          routeName: loginRoute,
          method: RoutingMethod.atTop,
        );
    } catch (error) {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translate('validation_error'),
      );
    }
  }
}
