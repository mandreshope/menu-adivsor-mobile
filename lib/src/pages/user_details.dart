import 'package:flutter/material.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/constants/validators.dart';
import 'package:menu_advisor/src/pages/add_payment_card.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';

class UserDetailsPage extends StatefulWidget {
  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  GlobalKey<FormState> _formKey = GlobalKey();

  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final FocusNode _displayNameFocus = FocusNode();
  final FocusNode _phoneNumberFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('your_informations'),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppLocalizations.of(context).translate("your_name"),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: _displayNameController,
                focusNode: _displayNameFocus,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.name,
                onFieldSubmitted: (_) {
                  _displayNameFocus.unfocus();
                  FocusScope.of(context).requestFocus(_phoneNumberFocus);
                },
                validator: Validators.required(context),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
              SizedBox(height: 10),
              Text(
                AppLocalizations.of(context).translate("add_phone_number"),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: _phoneNumberController,
                focusNode: _phoneNumberFocus,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.phone,
                onFieldSubmitted: (_) {
                  _phoneNumberFocus.unfocus();
                  FocusScope.of(context).requestFocus(_emailFocus);
                },
                validator: Validators.required(context),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
              SizedBox(height: 10),
              Text(
                AppLocalizations.of(context)
                    .translate("mail_address_placeholder"),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: _emailController,
                focusNode: _emailFocus,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                onFieldSubmitted: (_) {
                  _emailFocus.unfocus();
                  _submitForm();
                },
                validator: Validators.required(context),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
              Spacer(),
              FlatButton(
                color: CRIMSON,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                onPressed: _submitForm,
                child: Text(
                  AppLocalizations.of(context).translate('next'),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _submitForm() {
    FormState formState = _formKey.currentState;
    if (formState.validate())
      RouteUtil.goTo(
        context: context,
        child: AddPaymentCardPage(
          anonymous: true,
        ),
        routeName: addPaymentCardRoute,
      );
  }
}
