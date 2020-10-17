import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/constants/validators.dart';
import 'package:menu_advisor/src/pages/home.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/providers/CommandContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:provider/provider.dart';

class UserDetailsPage extends StatefulWidget {
  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  GlobalKey<FormState> _formKey = GlobalKey();

  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final FocusNode _displayNameFocus = FocusNode();
  final FocusNode _phoneNumberFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('your_informations'),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Consumer<CommandContext>(
          builder: (_, commandContext, __) => Form(
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
                  AppLocalizations.of(context).translate("mail_address_placeholder"),
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
                    if (commandContext.commandType != 'delivery') {
                      _submitForm();
                    } else {
                      FocusScope.of(context).requestFocus(_addressFocus);
                    }
                  },
                  validator: Validators.required(context),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
                if (commandContext.commandType == 'delivery') ...[
                  SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context).translate("address_placeholder"),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  TextFormField(
                    controller: _addressController,
                    focusNode: _addressFocus,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    onFieldSubmitted: (_) {
                      _addressFocus.unfocus();
                      _submitForm();
                    },
                    validator: Validators.required(context),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ],
                Spacer(),
                FlatButton(
                  color: CRIMSON,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(
                    20.0,
                  ),
                  onPressed: _submitForm,
                  child: Text(
                    commandContext.commandType == 'delivery' ? AppLocalizations.of(context).translate('next') : AppLocalizations.of(context).translate('validate'),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
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
    FormState formState = _formKey.currentState;

    CommandContext commandContext = Provider.of<CommandContext>(
      context,
      listen: false,
    );

    CartContext cartContext = Provider.of<CartContext>(
      context,
      listen: false,
    );

    if (formState.validate()) {
      try {
        await Api.instance.sendCommand(
          commandType: commandContext.commandType,
          items: cartContext.items.entries.map((e) => {'quantity': e.value, 'item': e.key.id}).toList(),
          restaurant: cartContext.currentOrigin,
          totalPrice: (cartContext.totalPrice * 100).round(),
        );

        commandContext.clear();
        cartContext.clear();

        Fluttertoast.showToast(
          msg: 'Commande envoyée avec succès. Nous vous enverrons un mail pour confirmation',
        );
        RouteUtil.goTo(
          context: context,
          child: HomePage(),
          routeName: homeRoute,
        );
      } catch (error) {
        Fluttertoast.showToast(msg: 'Erreur lors de l\'envoi de la commande...');
      }
    }
  }
}
