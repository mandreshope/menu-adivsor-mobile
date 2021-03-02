import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/constants/constant.dart';
import 'package:menu_advisor/src/constants/date_format.dart';
import 'package:menu_advisor/src/constants/validators.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/pages/confirm_sms.dart';
import 'package:menu_advisor/src/pages/summary.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/providers/CommandContext.dart';
import 'package:menu_advisor/src/providers/MenuContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/extensions.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    AuthContext authContext = Provider.of<AuthContext>(context, listen: false);
    commandContext = Provider.of<CommandContext>(
      context,
      listen: false,
    );

      if (authContext.currentUser != null){
      _displayNameController.text = authContext.currentUser.toString();
      _phoneNumberController.text = authContext.currentUser.phoneNumber.replaceFirst(phonePrefix, "");
      _emailController.text = authContext.currentUser.email;
      _addressController.text = authContext.currentUser.address ?? "";
    }

    deliveryDate =  now.add(Duration(days: 0));
    deliveryTime = TimeOfDay(hour: now.hour,minute: 00);

    commandContext.deliveryDate = deliveryDate;
    commandContext.deliveryTime = deliveryTime;

  }

  @override
  Widget build(BuildContext context) {
    _restaurant = ModalRoute.of(context).settings.arguments;
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
                  maxLength: 9,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    prefixText: phonePrefix,
                    counter: Offstage(),
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
                      LocationResult result = await showLocationPicker(
                                context,
                                "AIzaSyBu8U8tbY6BlxJezbjt8g3Lzi4k1I75iYw",
                                initialCenter: LatLng(31.1975844, 29.9598339),
                                //                      automaticallyAnimateToCurrentLocation: true,
                                //                      mapStylePath: 'assets/mapStyle.json',
                                myLocationButtonEnabled: true,
                                // requiredGPS: true,
                                layersButtonEnabled: true,
                                // countries: ['AE', 'NG']

                                //                      resultCardAlignment: Alignment.bottomCenter,
                                desiredAccuracy: LocationAccuracy.best,
                              );
                              print("result = $result");
                              _addressController.text = result.address;
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
                        DatePicker.showDatePicker(context,
                        locale: DateTimePickerLocale.fr,
                        dateFormat: "dd-MMMM-yyyy,HH:mm",
                        initialDateTime: deliveryDate ?? DateTime.now(),
                        maxDateTime: DateTime.now().add(
                            Duration(days: 3),
                          ),
                        minDateTime: DateTime.now(),
                        onCancel: (){

                        },
                        onConfirm: (date,val){
                          
                            commandContext.deliveryDate = date;
                            commandContext.deliveryTime = TimeOfDay.fromDateTime(date);
                          
                          setState(() {
                              deliveryDate = date;
                              deliveryTime = TimeOfDay.fromDateTime(date);
                            });
                          
                        },pickerMode: DateTimePickerMode.datetime
                        );
                        /*var date = await showRoundedDatePicker(
                          context: context,
                          initialDate: deliveryDate ?? DateTime.now(),
                          firstDate: DateTime.now().add(Duration(hours: -8)),
                          lastDate: DateTime.now().add(
                            Duration(days: 3),
                          ),
                        );
                        if (date != null) {
                          var time = await showRoundedTimePicker(
                            context: context,
                            initialTime: deliveryTime ??
                                TimeOfDay(
                                  hour: DateTime.now().hour,
                                  minute: DateTime.now()
                                      .minute,
                                ),
                          );

                          if (time != null) {
                            commandContext.deliveryDate = date;
                            commandContext.deliveryTime = time;

                            setState(() {
                              deliveryDate = date;
                              deliveryTime = time;
                            });
                          }
                        }*/
                      },
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 25.0),
                        title: TextTranslator(
                          'Planifier une commande',
                        ),
                        leading: Icon(
                          Icons.calendar_today_outlined,
                        ),
                        trailing: /*deliveryDate != null && deliveryTime != null
                            ? Icon(
                                Icons.edit_outlined,
                                color: Colors.green[300],
                              )
                            :*/ null,
                      ),
                    ),
                  ),
                // if (deliveryDate != null) ...[
                  // Divider(),
                  SizedBox(height: 5,),
                  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _datePicker(),
                    _timePicker(),
                  ],
                ),  
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
                FlatButton(
                  color: CRIMSON,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(
                    20.0,
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

    if (!_emailController.text.isValidateEmail()){
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

    CartContext cartContext = Provider.of<CartContext>(
      context,
      listen: false,
    );

    AuthContext authContext = Provider.of<AuthContext>(context,listen: false);

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
              'phoneNumber': phonePrefix+_phoneNumberController.value.text,
              'email': _emailController.value.text
            },
            commandType: commandContext.commandType);

        RouteUtil.goTo(
          context: context,
          child: ConfirmSms(
            command: null,
            isFromSignup: false,
              customer:{
                'name': _displayNameController.value.text,
                'address': _addressController.value.text,
                'phoneNumber': phonePrefix+_phoneNumberController.value.text,
                'email': _emailController.value.text
              },
            code: code,
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
        width: MediaQuery.of(context).size.width/2-25,
        padding: EdgeInsets.symmetric(horizontal: 15),
        
        child: Center(
          child: DropdownButton<DateTime>(
                                elevation: 16,
                                isExpanded: true,
                                isDense: true,
                                value:  deliveryDate,
                                onChanged: (DateTime date) {
                                  String dayName =  DateFormat.EEEE('fr_FR').format(date);
                                  setState(() {
                                    print(dayName);
                                    if(_restaurant.openingTimes.where((v) =>v.day.toLowerCase() == dayName).isNotEmpty) {
                                      print('ouvert');
                                      deliveryDate = date;
                                      commandContext.deliveryDate = deliveryDate;
                                      commandContext.deliveryTime = deliveryTime;
                                    }else {
                                      print('fermé');
                                      Fluttertoast.showToast(msg: 'Le restaurant est fermé');
                                    }
                                     
                                  });
                                   

                                },
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  decoration: TextDecoration.none
                                ),
                                underline: Container(),
                                selectedItemBuilder: (_){
                                  return List.generate(24, (index) => TextTranslator(
                                        index == 0 ? "Aujourd'hui" :
                                        index == 1 ? "Demain" :
                                        "${now.add(Duration(days: index)).dateToString("EE dd MMM")}",
                                         style: TextStyle(
                                          fontSize: 18,
                                          color: CRIMSON,
                                          fontWeight: FontWeight.w600
                                        )
                                        )
                                        );
                                },

                                items: [
                                  for (int i = 0; i < 4; i++)
                                    DropdownMenuItem<DateTime>(
                                      value: now.add(Duration(days: i)),
                                      child: TextTranslator(
                                        i == 0 ? "Aujourd'hui" :
                                        i == 1 ? "Demain" :
                                        "${now.add(Duration(days: i)).dateToString("EE dd MMMM")}",
                                         style: TextStyle(
                                          fontSize: 20
                                        ),)
                                  ),
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
        width: MediaQuery.of(context).size.width/2-25,
        // color: Colors.orange,
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Center(
          child: DropdownButton<TimeOfDay>(
                                // offsetAmount: MediaQuery.of(context).size.height/2 - 50,
                                elevation: 0,
                                isDense: true,
                                isExpanded: true,
                                value:  deliveryTime,
                                selectedItemBuilder: (_){
                                  return [
                                    for (int i = 0; i < 24; i++)...[
                                      if((DateTime.now().hour == TimeOfDay(hour: i, minute: 00).hour) 
                                      && DateTime.now().hour >= TimeOfDay(hour: i, minute: 00).hour)
                                      DropdownMenuItem<TimeOfDay>(
                                        value: TimeOfDay(hour: i, minute: 00),
                                        child: TextTranslator(
                                          "${TimeOfDay(hour: i, minute: (DateTime.now().add(Duration(minutes: 15)).minute)).format(context)}",
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: CRIMSON,
                                            fontWeight: FontWeight.w600
                                          ),
                                        )
                                      ),
                                      if(DateTime.now().hour < TimeOfDay(hour: i, minute: 00).hour)
                                      DropdownMenuItem<TimeOfDay>(
                                        value: TimeOfDay(hour: i, minute: 00),
                                        child: TextTranslator(
                                          "${TimeOfDay(hour: i, minute: 00).format(context)}",
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: CRIMSON,
                                            fontWeight: FontWeight.w600
                                          ),
                                        )
                                      ),
                                    ]
                                  ];
                                },
                                onChanged: (TimeOfDay time) {
                                  print(time);
                                  setState(() {
                                     deliveryTime = time;
                                     commandContext.deliveryTime = deliveryTime;
                                  });
                                   

                                },
                                style: TextStyle(
                                  color: Colors.grey[700],
                                ),
                                underline: Container(),
                                items: [
                                  for (int i = 0; i < 24; i++)...[
                                    if((DateTime.now().hour == TimeOfDay(hour: i, minute: 00).hour) 
                                    && DateTime.now().hour >= TimeOfDay(hour: i, minute: 00).hour)
                                    DropdownMenuItem<TimeOfDay>(
                                      value: TimeOfDay(hour: i, minute: 00),
                                      child: TextTranslator(
                                        "${TimeOfDay(hour: i, minute: (DateTime.now().add(Duration(minutes: 15)).minute)).format(context)}",
                                        style: TextStyle(
                                          fontSize: 20
                                        ),
                                      )
                                    ),
                                    if(DateTime.now().hour < TimeOfDay(hour: i, minute: 00).hour)
                                    DropdownMenuItem<TimeOfDay>(
                                      value: TimeOfDay(hour: i, minute: 00),
                                      child: TextTranslator(
                                        "${TimeOfDay(hour: i, minute: 00).format(context)}",
                                        style: TextStyle(
                                          fontSize: 20
                                        ),
                                      )
                                    ),
                                  ]
                                ],
                              ),
        ),
      ),
    );
  }

}
