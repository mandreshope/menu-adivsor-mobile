import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:menu_advisor/src/components/inputs.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/constants/constant.dart';
import 'package:menu_advisor/src/constants/validators.dart';
import 'package:menu_advisor/src/models/models.dart';
import 'package:menu_advisor/src/pages/confirm_sms.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/CommandContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/extensions.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:place_picker/place_picker.dart';
import 'package:provider/provider.dart';

// import 'package:menu_advisor/src/components/customDropDown.dart' as drop;
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
  String parsedPhone = "";

  final FocusNode _displayNameFocus = FocusNode();
  final FocusNode _phoneNumberFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();

  DateTime deliveryDate;
  TimeOfDay deliveryTime;

  bool sendingCommand = false;
  DateTime now = DateTime.now();
  Restaurant _restaurant;

  CommandContext commandContext;
  bool isToday = true;
  bool isOpen = true;

  @override
  void initState() {
    super.initState();

    AuthContext authContext = Provider.of<AuthContext>(context, listen: false);
    commandContext = Provider.of<CommandContext>(
      context,
      listen: false,
    );

    if (authContext.currentUser != null) {
      _displayNameController.text = authContext.currentUser.toString();
      //_phoneNumberController.text = authContext.currentUser.phoneNumber.replaceFirst(phonePrefix, "");
      _phoneNumberController.text = authContext.currentUser.phoneNumber;
      _emailController.text = authContext.currentUser.email;
      _addressController.text = authContext.currentUser.address ?? "";

      PhoneNumber.getRegionInfoFromPhoneNumber(_phoneNumberController.text)
          .then((value) async {
        parsedPhone = await PhoneNumber.getParsableNumber(value);
        setState(() {});
      });
    }

    deliveryDate = now.add(Duration(days: 0)); //.add(Duration(days: 0));
    deliveryTime = TimeOfDay(hour: now.hour, minute: 00);

    commandContext.deliveryDate = deliveryDate;
    commandContext.deliveryTime = deliveryTime;
  }

  @override
  Widget build(BuildContext context) {
    _restaurant = ModalRoute.of(context).settings.arguments;
    this.isOpen = _restaurant.isOpen;
    return Scaffold(
      appBar: AppBar(
        title: TextTranslator(
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
              mainAxisSize: MainAxisSize.max,
              children: [
                TextTranslator(
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
                TextTranslator(
                  AppLocalizations.of(context).translate("add_phone_number"),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                PhoneField(
                  focusNode: _phoneNumberFocus,
                  initialValue: phoneInitialCountryCode,
                  onInputChanged: (PhoneNumber number) {
                    print(number.phoneNumber);
                    _phoneNumberController.text = number.phoneNumber;
                  },
                  onInputValidated: (bool value) {
                    print(value);
                  },
                  onSaved: (PhoneNumber number) {
                    _phoneNumberFocus.unfocus();
                    FocusScope.of(context).requestFocus(_emailFocus);
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    counter: Offstage(),
                    hintText: parsedPhone,
                  ),
                ),
                SizedBox(height: 10),
                TextTranslator(
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
                  TextTranslator(
                    AppLocalizations.of(context)
                        .translate("address_placeholder"),
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
                    onTap: () async {
                      LocationResult result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PlacePicker(
                            GOOGLE_API_KEY,
                            displayLocation: LatLng(31.1975844, 29.9598339),
                          ),
                        ),
                      );
                      print("$logTrace result = ${result.formattedAddress}");
                      _addressController.text = result.formattedAddress;
                      _submitForm();
                    },
                  ),
                ],
                SizedBox(height: 25),
                if (commandContext.commandType == 'takeaway')
                  Material(
                    color: Colors.white,
                    child: InkWell(
                      onTap: () async {
                        return;
                        // DatePicker.showDatePicker(context,
                        //     locale: DateTimePickerLocale.fr,
                        //     dateFormat: "dd-MMMM-yyyy,HH:mm",
                        //     initialDateTime: deliveryDate ?? DateTime.now(),
                        //     maxDateTime: DateTime.now().add(
                        //       Duration(days: 3),
                        //     ),
                        //     minDateTime: DateTime.now(),
                        //     onCancel: () {}, onConfirm: (date, val) {
                        //   commandContext.deliveryDate = date;
                        //   commandContext.deliveryTime = TimeOfDay.fromDateTime(date);

                        //   setState(() {
                        //     deliveryDate = date;
                        //     deliveryTime = TimeOfDay.fromDateTime(date);
                        //   });
                        // }, pickerMode: DateTimePickerMode.datetime);
                      },
                      child: Column(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  deliveryDate = null;
                                  deliveryTime = null;
                                });
                              },
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 25.0),
                                title: TextTranslator(
                                  AppLocalizations.of(context)
                                      .translate('as_soon_as_possible'),
                                ),
                                leading: Icon(
                                  Icons.timer,
                                ),
                                trailing:
                                    deliveryDate == null && deliveryTime == null
                                        ? Icon(
                                            Icons.check,
                                            color: Colors.green[300],
                                          )
                                        : null,
                              ),
                            ),
                          ),
                          Divider(),
                          ListTile(
                              onTap: () {
                                setState(() {
                                  deliveryDate = now.add(Duration(days: 0));
                                  deliveryTime =
                                      TimeOfDay(hour: now.hour, minute: 00);

                                  commandContext.deliveryDate = deliveryDate;
                                  commandContext.deliveryTime = deliveryTime;
                                });
                              },
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
                              title: TextTranslator(
                                'Planifier une commande',
                              ),
                              leading: Icon(
                                Icons.calendar_today_outlined,
                              ),
                              trailing:
                                  deliveryDate != null && deliveryTime != null
                                      ? Icon(
                                          Icons.edit_outlined,
                                          color: Colors.green[300],
                                        )
                                      : null),
                        ],
                      ),
                    ),
                  ),
                // if (deliveryDate != null) ...[
                // Divider(),
                SizedBox(
                  height: 5,
                ),
                if (deliveryDate != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _datePicker(),
                      _timePicker(),
                    ],
                  ),
                ],

                /*Container(
                    color: CRIMSON,
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 25.0),
                      title: TextTranslator(
                        '${deliveryDate?.dateToString(DATE_FORMATED_ddMMyyyy) ?? ""}    ${deliveryTime?.hour ?? ""} : ${deliveryTime?.minute ?? ""}',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.white,//CRIMSON.withOpacity(0.9),
                          fontSize: 20,
                          fontWeight: FontWeight.w400
                        ),
                      ),
                      leading: Container(width: 1,height: 1,),
                      trailing: null,
                    ),
                  ),*/
                // ],
                Spacer(),
                TextButton(
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
                  onPressed: _submitForm,
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
                          commandContext.commandType == 'delivery'
                              ? AppLocalizations.of(context).translate('next')
                              : AppLocalizations.of(context)
                                  .translate('validate'),
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
    if (!_emailController.text.isValidateEmail()) {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translate("invalid_email"),
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
      return;
    }

    FormState formState = _formKey.currentState;

    CommandContext commandContext = Provider.of<CommandContext>(
      context,
      listen: false,
    );

    AuthContext authContext = Provider.of<AuthContext>(context, listen: false);

    if (formState.validate() && deliveryDate != null && deliveryTime != null) {
      setState(() {
        sendingCommand = true;
      });
      try {
        String code = await Api.instance.sendCode(
            relatedUser: authContext.currentUser?.id ?? null,
            customer: {
              'name': _displayNameController.value.text,
              'address': _addressController.value.text,
              'phoneNumber': _phoneNumberController.value.text,
              'email': _emailController.value.text
            },
            commandType: commandContext.commandType);

        RouteUtil.goTo(
          context: context,
          child: ConfirmSms(
            command: null,
            isFromSignup: false,
            customer: {
              'name': _displayNameController.value.text,
              'address': _addressController.value.text,
              'phoneNumber': _phoneNumberController.value.text,
              'email': _emailController.value.text
            },
            code: code,
            restaurant: _restaurant,
          ),
          routeName: homeRoute,
          // method: RoutingMethod.atTop,
        );
        setState(() {
          sendingCommand = false;
        });
      } catch (error) {
        setState(() {
          sendingCommand = false;
        });
        Fluttertoast.showToast(
            msg: 'Erreur lors de l\'envoi de la commande...');
      }
    } else {
      setState(() {
        sendingCommand = false;
      });
      Fluttertoast.showToast(msg: 'Compléter les informations');
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
                  isToday = deliveryDate.day == now.day;
                  print("isToday $isToday");
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
                isToday = index == 0;

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
