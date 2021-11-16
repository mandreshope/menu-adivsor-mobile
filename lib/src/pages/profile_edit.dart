import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:menu_advisor/src/components/inputs.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/constants/constant.dart';
import 'package:menu_advisor/src/models/models.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textFormFieldTranslator.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:place_picker/place_picker.dart';
import 'package:provider/provider.dart';

class ProfileEditPage extends StatefulWidget {
  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  TextEditingController lastnameController;
  TextEditingController firstnameController;
  TextEditingController addressController;
  TextEditingController phoneNumberController;
  String parsedPhone = "";

  FocusNode lastnameFocus = FocusNode();
  FocusNode firstnameFocus = FocusNode();
  FocusNode addressFocus = FocusNode();
  FocusNode phoneNumberFocus = FocusNode();

  bool changed = false;
  bool inProgress = false;

  @override
  void initState() {
    super.initState();

    AuthContext authContext = Provider.of<AuthContext>(
      context,
      listen: false,
    );

    lastnameController =
        TextEditingController(text: authContext.currentUser.name?.last ?? '');
    firstnameController =
        TextEditingController(text: authContext.currentUser.name?.first ?? '');
    addressController =
        TextEditingController(text: authContext.currentUser.address ?? '');
    phoneNumberController =
        TextEditingController(text: authContext.currentUser.phoneNumber ?? '');
    PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumberController.text)
        .then((value) async {
      parsedPhone = await PhoneNumber.getParsableNumber(value);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextTranslator(
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
              TextFormFieldTranslator(
                focusNode: lastnameFocus,
                controller: lastnameController,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)
                      .translate("lastname_placeholder"),
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
              TextFormFieldTranslator(
                focusNode: firstnameFocus,
                controller: firstnameController,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)
                      .translate("firstname_placeholder"),
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
              TextFormFieldTranslator(
                focusNode: addressFocus,
                controller: addressController,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)
                      .translate("address_placeholder"),
                ),
                onChanged: (_) {
                  _updateChangedState();
                },
                onFieldSubmitted: (_) {
                  addressFocus.unfocus();
                  _submitForm();
                },
                onTap: () async {
                  // LocationResult result = await showLocationPicker(
                  //   context,
                  //   "AIzaSyBu8U8tbY6BlxJezbjt8g3Lzi4k1I75iYw",
                  //   initialCenter: LatLng(31.1975844, 29.9598339),
                  //   //                      automaticallyAnimateToCurrentLocation: true,
                  //   //                      mapStylePath: 'assets/mapStyle.json',
                  //   myLocationButtonEnabled: true,
                  //   // requiredGPS: true,
                  //   layersButtonEnabled: true,
                  //   // countries: ['AE', 'NG']

                  //   //                      resultCardAlignment: Alignment.bottomCenter,
                  //   desiredAccuracy: LocationAccuracy.best,
                  // );
                  LocationResult result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PlacePicker(
                        GOOGLE_API_KEY,
                        displayLocation: LatLng(31.1975844, 29.9598339),
                      ),
                    ),
                  );
                  print("$logTrace result = ${result.formattedAddress}");
                  addressController.text = result.formattedAddress;
                  _updateChangedState();
                },
              ),
              SizedBox(
                height: 30,
              ),
              PhoneField(
                focusNode: phoneNumberFocus,
                initialValue: phoneInitialCountryCode,
                onInputChanged: (PhoneNumber number) {
                  print(number.phoneNumber);
                  phoneNumberController.text = number.phoneNumber;
                },
                onInputValidated: (bool value) {
                  print(value);
                },
                onSaved: (PhoneNumber number) {
                  phoneNumberFocus.unfocus();
                  _submitForm();
                },
                decoration: InputDecoration(
                  hintText: parsedPhone,
                ),
              ),
              SizedBox(
                height: 30,
              ),
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
                    : TextTranslator(
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

      String firstname = firstnameController.value.text,
          lastname = lastnameController.value.text,
          address = addressController.value.text,
          phoneNumber = phoneNumberController.value.text;

      try {
        await authContext.updateUserProfile({
          'name': {
            'first': firstname,
            'last': lastname,
          },
          'address': address,
          'phoneNumber': phoneNumber
        });
        setState(() {
          inProgress = false;
        });
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context).translate('profile_updated'),
        );
        RouteUtil.goBack(context: context);
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
    String firstname = firstnameController.value.text,
        lastname = lastnameController.value.text,
        address = addressController.value.text,
        phoneNumber = phoneNumberController.value.text;

    User user = authContext.currentUser;

    if (!changed)
      setState(() {
        changed = true;
      });
    else if ((user.name.first == firstname &&
        user.name.last == lastname &&
        user.address == address &&
        user.phoneNumber == phoneNumber))
      setState(() {
        changed = false;
      });
  }
}
