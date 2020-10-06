import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:provider/provider.dart';

class AddPaymentCardPage extends StatefulWidget {
  @override
  _AddPaymentCardPageState createState() => _AddPaymentCardPageState();
}

class _AddPaymentCardPageState extends State<AddPaymentCardPage> {
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => ConfirmationDialog(
            title: AppLocalizations.of(context)
                .translate('abandon_change_dialog_title'),
            content: AppLocalizations.of(context)
                .translate('abandon_change_dialog_content'),
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
                          labelText: AppLocalizations.of(context)
                              .translate("owner_name_placeholder"),
                        ),
                        validator: _required,
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
                          labelText: AppLocalizations.of(context)
                              .translate("card_number_placeholder"),
                        ),
                        onFieldSubmitted: (_) {
                          _cardNumberFocus.unfocus();
                          FocusScope.of(context)
                              .requestFocus(_expirationDateFocus);
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
                                labelText: AppLocalizations.of(context)
                                    .translate("expiration_date_label"),
                                hintText: AppLocalizations.of(context)
                                    .translate("expiration_date_placeholder"),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]{2}\/[0-9]{2}'),
                                ),
                              ],
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
                                labelText: AppLocalizations.of(context)
                                    .translate("security_code_placeholder"),
                                hintText: "123",
                              ),
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(3)
                              ],
                              onFieldSubmitted: (_) {
                                _cvcFocus.unfocus();
                                FocusScope.of(context)
                                    .requestFocus(_zipCodeFocus);
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
                          labelText: AppLocalizations.of(context)
                              .translate("zip_code_placeholder"),
                        ),
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 10),
                    onPressed: _submitForm,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.save_rounded,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          AppLocalizations.of(context).translate('save'),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
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

  String _required(String value) {
    if (value.isEmpty)
      return AppLocalizations.of(context).translate('field_must_not_be_blank');

    return null;
  }

  _submitForm() {
    if (_formKey.currentState.validate()) {
      AuthContext authContext =
          Provider.of<AuthContext>(context, listen: false);

      try {} catch (error) {}
    }
  }
}
