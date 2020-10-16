import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:provider/provider.dart';

class ProfileEditPage extends StatefulWidget {
  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  TextEditingController lastnameController;
  TextEditingController firstnameController;
  TextEditingController addressController;

  FocusNode lastnameFocus = FocusNode();
  FocusNode firstnameFocus = FocusNode();
  FocusNode addressFocus = FocusNode();

  bool changed = false;
  bool inProgress = false;

  @override
  void initState() {
    super.initState();

    AuthContext authContext = Provider.of<AuthContext>(
      context,
      listen: false,
    );

    lastnameController = TextEditingController(text: authContext.currentUser.name?.last ?? '');
    firstnameController = TextEditingController(text: authContext.currentUser.name?.first ?? '');
    addressController = TextEditingController(text: authContext.currentUser.address ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context).translate('edit_profile'),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                focusNode: lastnameFocus,
                controller: lastnameController,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).translate("lastname_placeholder"),
                ),
                onChanged: (_) {
                  _updateChangedState();
                },
                onFieldSubmitted: (_) {
                  lastnameFocus.unfocus();
                  FocusScope.of(context).requestFocus(firstnameFocus);
                },
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                focusNode: firstnameFocus,
                controller: firstnameController,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).translate("firstname_placeholder"),
                ),
                onChanged: (_) {
                  _updateChangedState();
                },
                onFieldSubmitted: (_) {
                  firstnameFocus.unfocus();
                  FocusScope.of(context).requestFocus(addressFocus);
                },
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                focusNode: addressFocus,
                controller: addressController,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).translate("address_placeholder"),
                ),
                onChanged: (_) {
                  _updateChangedState();
                },
                onFieldSubmitted: (_) {
                  addressFocus.unfocus();
                  _submitForm();
                },
              ),
              SizedBox(
                height: 30,
              ),
              RaisedButton(
                padding: EdgeInsets.all(15),
                color: CRIMSON,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onPressed: _submitForm,
                child: inProgress
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
                    : Text(
                        AppLocalizations.of(context).translate("save"),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
              ),
            ],
          ),
        ));
  }

  _submitForm() async {
    if (changed) {
      AuthContext authContext = Provider.of<AuthContext>(
        context,
        listen: false,
      );

      setState(() {
        inProgress = true;
      });

      String firstname = firstnameController.value.text, lastname = lastnameController.value.text, address = addressController.value.text;

      try {
        await authContext.updateUserProfile({
          'name': {
            'first': firstname,
            'last': lastname,
          },
          'address': address,
        });
        setState(() {
          inProgress = false;
        });
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context).translate('profile_updated'),
        );
      } catch (error) {
        setState(() {
          inProgress = false;
        });
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context).translate('connection_error'),
        );
      }
    }
  }

  _updateChangedState() {
    AuthContext authContext = Provider.of<AuthContext>(
      context,
      listen: false,
    );
    String firstname = firstnameController.value.text, lastname = lastnameController.value.text, address = addressController.value.text;

    User user = authContext.currentUser;

    if (!changed)
      setState(() {
        changed = true;
      });
    else if ((user.name.first == firstname && user.name.last == lastname && user.address == address))
      setState(() {
        changed = false;
      });
  }
}
