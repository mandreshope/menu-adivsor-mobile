import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/constants/validators.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/pages/home.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/services/stripe.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/input_formatters.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:provider/provider.dart';

class PaymentCardDetailsPage extends StatefulWidget {
  final bool isPaymentStep;

  PaymentCardDetailsPage({
    Key key,
    this.isPaymentStep,
  }) : super(key: key);

  @override
  _PaymentCardDetailsPageState createState() => _PaymentCardDetailsPageState();
}

class _PaymentCardDetailsPageState extends State<PaymentCardDetailsPage> {
  TextEditingController _ownerNameController = TextEditingController();
  TextEditingController _cardNumberController = TextEditingController();
  TextEditingController _expirationDateController = TextEditingController();
  TextEditingController _cvcController = TextEditingController();
  TextEditingController _zipCodeController = TextEditingController();

  FocusNode _ownerNameFocus = FocusNode();
  FocusNode _cardNumberFocus = FocusNode();
  FocusNode _expirationDateFocus = FocusNode();
  FocusNode _cvcFocus = FocusNode();
  FocusNode _zipCodeFocus = FocusNode();

  GlobalKey<FormState> _formKey = GlobalKey();

  bool _onProgress = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => ConfirmationDialog(
            title: AppLocalizations.of(context).translate('abandon_change_dialog_title'),
            content: AppLocalizations.of(context).translate('abandon_change_dialog_content'),
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context).translate('card_details'),
          ),
        ),
        resizeToAvoidBottomInset: false,
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Container(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(30),
                  child: Image.asset('assets/images/stripe-cards.png'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        focusNode: _ownerNameFocus,
                        controller: _ownerNameController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).translate("owner_name_placeholder"),
                        ),
                        validator: Validators.required(context),
                        onFieldSubmitted: (_) {
                          _ownerNameFocus.unfocus();
                          FocusScope.of(context).requestFocus(_cardNumberFocus);
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        focusNode: _cardNumberFocus,
                        controller: _cardNumberController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).translate("card_number_placeholder"),
                        ),
                        validator: Validators.required(context),
                        onFieldSubmitted: (_) {
                          _cardNumberFocus.unfocus();
                          FocusScope.of(context).requestFocus(_expirationDateFocus);
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              focusNode: _expirationDateFocus,
                              controller: _expirationDateController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context).translate("expiration_date_label"),
                                hintText: AppLocalizations.of(context).translate("expiration_date_placeholder"),
                              ),
                              inputFormatters: [
                                ExpiryDateInputFormatter(),
                              ],
                              validator: Validators.required(context),
                              onFieldSubmitted: (_) {
                                _expirationDateFocus.unfocus();
                                FocusScope.of(context).requestFocus(_cvcFocus);
                              },
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              focusNode: _cvcFocus,
                              controller: _cvcController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context).translate("security_code_placeholder"),
                                hintText: "123",
                              ),
                              inputFormatters: [LengthLimitingTextInputFormatter(3)],
                              validator: Validators.required(context),
                              onFieldSubmitted: (_) {
                                _cvcFocus.unfocus();
                                FocusScope.of(context).requestFocus(_zipCodeFocus);
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        focusNode: _zipCodeFocus,
                        controller: _zipCodeController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).translate("zip_code_placeholder"),
                        ),
                        validator: Validators.required(context),
                        onFieldSubmitted: (_) {
                          _zipCodeFocus.unfocus();
                          _submitForm();
                        },
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: FlatButton(
                    color: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    onPressed: _submitForm,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (_onProgress)
                          SizedBox(
                            height: 22,
                            child: FittedBox(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          )
                        else ...[
                          Icon(
                            widget.isPaymentStep ? Icons.check : Icons.save_rounded,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            widget.isPaymentStep ? AppLocalizations.of(context).translate('validate') : AppLocalizations.of(context).translate('save'),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _submitForm() async {
    if (_formKey.currentState.validate()) {
      if (widget.isPaymentStep) {
        StripeService.init();

        BagContext bagContext = Provider.of<BagContext>(context, listen: false);

        setState(() {
          _onProgress = true;
        });
        var response = await StripeService.payViaExistingCard(
          amount: (bagContext.totalPrice * 100).round().toString(),
          currency: 'eur',
          card: PaymentCard(
            cardNumber: _cardNumberController.value.text,
            expiryMonth: _expirationDateController.value.text.split('/')[1],
            expiryYear: _expirationDateController.value.text.split('/')[0],
            securityCode: _cvcController.value.text,
            owner: _ownerNameController.value.text,
            zipCode: _zipCodeController.value.text,
          ),
        );
        setState(() {
          _onProgress = false;
        });
        if (response.success) {
          bagContext.clear();

          RouteUtil.goTo(
            context: context,
            child: HomePage(),
            routeName: homeRoute,
            method: RoutingMethod.atTop,
          );
        } else {
          Fluttertoast.showToast(msg: response.message);
        }
      } else {
        AuthContext authContext = Provider.of<AuthContext>(context, listen: false);

        try {
          setState(() {
            _onProgress = true;
          });
          await authContext.addPaymentCard(
            PaymentCard(
              cardNumber: _cardNumberController.value.text,
              expiryMonth: _expirationDateController.value.text.split('/')[1],
              expiryYear: _expirationDateController.value.text.split('/')[0],
              securityCode: _cvcController.value.text,
              owner: _ownerNameController.value.text,
              zipCode: _zipCodeController.value.text,
            ),
          );
          setState(() {
            _onProgress = false;
          });
          RouteUtil.goBack(context: context);
        } catch (error) {
          setState(() {
            _onProgress = false;
          });
          Fluttertoast.showToast(
            msg: AppLocalizations.of(context).translate('add_payment_card_error'),
          );
        }
      }
    }
  }
}
