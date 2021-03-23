import 'package:flutter/material.dart';
// import 'package:flutter_collapse/flutter_collapse.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:intl/intl.dart';
import 'package:menu_advisor/src/components/flutter_collapse.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/constants/date_format.dart';
import 'package:menu_advisor/src/pages/confirm_sms.dart';
import 'package:menu_advisor/src/pages/payment_card_list.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/CommandContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/extensions.dart';
import 'package:menu_advisor/src/utils/textFormFieldTranslator.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_map_location_picker/generated/l10n.dart' as location_picker;
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models.dart';

class DeliveryDetailsPage extends StatefulWidget {
  Restaurant restaurant;
  DeliveryDetailsPage({this.restaurant});
  @override
  _DeliveryDetailsPageState createState() => _DeliveryDetailsPageState();
}

class _DeliveryDetailsPageState extends State<DeliveryDetailsPage> {
  DateTime deliveryDate;
  TimeOfDay deliveryTime;
  GlobalKey<FormState> formKey = GlobalKey();
  DateTime now = DateTime.now();

  Restaurant _restaurant;

  CommandContext commandContext;
  bool sendingCommand = false;
  TextEditingController addrContr = TextEditingController();
  TextEditingController postalCodeContr = TextEditingController();
  TextEditingController codepostalCodeContr = TextEditingController();
  TextEditingController etageContr = TextEditingController();

  bool isCollapseDateTime = false;
  bool isCollapseLivraison = false;

  //Devant la porte - Rdv à la porte - A l'exterieur -- behind_the_door / on_the_door / out -- 

  String optionRdv = "behind_the_door";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _restaurant = widget.restaurant;
    _restaurant.optionLivraison = optionRdv;
    commandContext = Provider.of<CommandContext>(
      context,
      listen: false,
    );

    deliveryDate = now.add(Duration(days: 0));
    deliveryTime = TimeOfDay(hour: now.hour, minute: 00);

    commandContext.deliveryTime = deliveryTime;
    commandContext.deliveryDate = deliveryDate;
  }

  @override
  Widget build(BuildContext context) {
    _restaurant = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: TextTranslator(
          AppLocalizations.of(context).translate('delivery_details'),
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Consumer<CommandContext>(
                    builder: (_, commandContext, __) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(
                            30,
                          ),
                          color: Colors.white,
                          child: TextFormFieldTranslator(
                            controller: addrContr,
                            keyboardType: TextInputType.streetAddress,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context).translate("address_placeholder"),
                            ),
                            onChanged: (value) {
                              commandContext.deliveryAddress = value;
                            },
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
                             /* List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(result.latLng.latitude, result.latLng.longitude);
                              
                                // this is all you need
                              geo.Placemark placeMark  = placemarks[0]; 
                              String name = placeMark.name;
                              String subLocality = placeMark.subLocality;
                              String locality = placeMark.locality;
                              String administrativeArea = placeMark.administrativeArea;
                              String postalCode = placeMark.postalCode;
                              String country = placeMark.country;
                              String address = "${name}, ${subLocality}, ${locality}, ${administrativeArea} ${postalCode}, ${country}";
  
                              print("adress $address");*/

                              addrContr.text = result.address;
                              commandContext.deliveryAddress = result.address;
                              
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                            left: 30,
                            right: 30,
                            bottom: 30
                          ),
                          color: Colors.white,
                          child: TextFormFieldTranslator(
                            controller: codepostalCodeContr,
                            enabled: addrContr.text.isEmpty ? false : true,
                            keyboardType: TextInputType.streetAddress,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: "Code Appartement",
                            ),
                            onChanged: (value) {
                              // commandContext.deliveryAddress = value;
                              _restaurant.codeappartement = codepostalCodeContr.text;
                            },
                            
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                            left: 30,
                            right: 30,
                            bottom: 30
                          ),
                          color: Colors.white,
                          child: TextFormFieldTranslator(
                            controller: postalCodeContr,
                            enabled: addrContr.text.isEmpty ? false : true,
                            keyboardType: TextInputType.streetAddress,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: "Appartement",
                            ),
                            onChanged: (value) {
                              // commandContext.deliveryAddress = value;
                              _restaurant.appartement = postalCodeContr.text;
                            },
                            
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                            left: 30,
                            right: 30,
                            bottom: 30
                          ),
                          color: Colors.white,
                          child: TextFormFieldTranslator(
                            controller:etageContr,
                            enabled: addrContr.text.isEmpty ? false : true,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: "Etage",
                            ),
                            onChanged: (value) {
                              // commandContext.deliveryAddress = value;
                              if (etageContr.text.isNotEmpty)
                                _restaurant.etage = int.parse(etageContr.text);
                            },
                            
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Collapse(
                          onChange: (value){
                            setState(() {
                              isCollapseLivraison = value;
                            });
                          },
                          value: isCollapseLivraison,
                          title: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 35.0,
                              vertical: 15,
                            ),
                            child: TextTranslator(
                              "Options de livraison",
                              textAlign: TextAlign.start,
                            style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                          ),
                          body: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 5,
                          ),
                          child: Column(
                            children: [
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      optionRdv = "behind_the_door";
                                      _restaurant.optionLivraison = optionRdv;
                                    });
                                  },
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 25.0),
                                    title: TextTranslator(
                                      "Devant la porte",
                                      
                                    ),
                                    leading: Icon(
                                      Icons.timer,
                                    ),
                                    trailing: optionRdv == "behind_the_door"
                                        ? Icon(
                                            Icons.check,
                                            color: Colors.green[300],
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                              Divider(),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      optionRdv = "on_the_door";
                                      _restaurant.optionLivraison = optionRdv;
                                    });
                                  },
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 25.0),
                                    title: TextTranslator(
                                      "Rdv à la porte",
                                    ),
                                    leading: Icon(
                                      Icons.timer,
                                    ),
                                    trailing: optionRdv == "on_the_door"
                                        ? Icon(
                                            Icons.check,
                                            color: Colors.green[300],
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                              Divider(),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      optionRdv = "out";
                                      _restaurant.optionLivraison = optionRdv;
                                    });
                                  },
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 25.0),
                                    title: TextTranslator(
                                      "A l'exterieur",
                                    ),
                                    leading: Icon(
                                      Icons.timer,
                                    ),
                                    trailing: optionRdv == "out"
                                        ? Icon(
                                            Icons.check,
                                            color: Colors.green[300],
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                              Divider(),
                              ],
                          ),
                        ),
                      
                        )
                        ,

                        Collapse(
                          padding: EdgeInsets.zero,
                          onChange: (value){
                            setState(() {
                              isCollapseDateTime = value;
                            });
                          },
                          value: isCollapseDateTime,
                          title: Container(
                            // color: Colors.grey,
                            // width: MediaQuery.of(context).size.width - 50,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 35.0,
                              vertical: 15,
                            ),
                            child: TextTranslator(
                              AppLocalizations.of(context).translate('date_and_time'),
                              textAlign: TextAlign.start,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            
                        ),
                          ),
                          body: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 5,
                          ),
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
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 25.0),
                                    title: TextTranslator(
                                      AppLocalizations.of(context).translate('as_soon_as_possible'),
                                    ),
                                    leading: Icon(
                                      Icons.timer,
                                    ),
                                    trailing: deliveryDate == null && deliveryTime == null
                                        ? Icon(
                                            Icons.check,
                                            color: Colors.green[300],
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                              Divider(),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    setState(() {
                                      deliveryDate = now.add(Duration(days: 0));
                                      deliveryTime = TimeOfDay(hour: now.hour, minute: 00);

                                      commandContext.deliveryDate = deliveryDate;
                                      commandContext.deliveryTime = deliveryTime;
                                    });

                                    return;
                                    DatePicker.showDatePicker(context,
                                        locale: DateTimePickerLocale.fr,
                                        dateFormat: "dd-MMMM-yyyy,HH:mm",
                                        initialDateTime: deliveryDate ?? DateTime.now(),
                                        maxDateTime: DateTime.now().add(
                                          Duration(days: 3),
                                        ),
                                        minDateTime: DateTime.now(),
                                        onCancel: () {}, onConfirm: (date, val) {
                                      commandContext.deliveryDate = date;
                                      commandContext.deliveryTime = TimeOfDay.fromDateTime(date);

                                      setState(() {
                                        deliveryDate = date;
                                        deliveryTime = TimeOfDay.fromDateTime(date);
                                      });
                                    }, pickerMode: DateTimePickerMode.datetime);
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
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 25.0),
                                    title: TextTranslator(
                                      'Planifier une commande',
                                    ),
                                    leading: Icon(
                                      Icons.calendar_today_outlined,
                                    ),
                                    trailing: deliveryDate != null && deliveryTime != null
                                        ? Icon(
                                            Icons.check,
                                            color: Colors.green[300],
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                              if (deliveryDate != null) ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _datePicker(),
                                    _timePicker(),
                                  ],
                                ),
                                // Divider(),
                                // Divider(),

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
                              ],
                            ],
                          ),
                        ),
                      
                        )
                        
                        ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(
                20,
              ),
              child: RaisedButton(
                padding: EdgeInsets.all(20),
                color: CRIMSON,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onPressed: () async {

                  if (!_restaurant.isOpenByDate(deliveryDate,deliveryTime)){
                     print('fermé');
                     Fluttertoast.showToast(msg: 'Le restaurant est fermé');
                     return;
                  }
                  FormState formState = formKey.currentState;

                  if (addrContr.text.isEmpty) {
                    Fluttertoast.showToast(
                      msg: "Entrer votre adresse de livraison",
                    );
                    return;
                  }

                  if (formState.validate()) {
                    AuthContext authContext = Provider.of<AuthContext>(
                      context,
                      listen: false,
                    );

                    if (authContext.currentUser != null) {
                      var customer = {
                        'name': authContext.currentUser?.name,
                        'address': authContext.currentUser?.address,
                        'phoneNumber': authContext.currentUser?.phoneNumber,
                        'email': authContext.currentUser?.email
                      };
                      setState(() {
                        sendingCommand = true;
                      });
                      String code = await Api.instance.sendCode(relatedUser: authContext.currentUser?.id ?? null, customer: customer, commandType: commandContext.commandType);

                      RouteUtil.goTo(
                        context: context,
                        child: ConfirmSms(
                          command: null,
                          isFromSignup: false,
                          customer: customer,
                          code: code,
                          fromDelivery: true,
                          restaurant: _restaurant,
                        ),
                        routeName: homeRoute,
                        // method: RoutingMethod.atTop,
                      );
                      setState(() {
                        sendingCommand = false;
                      });

                      /*
                      RouteUtil.goTo(
                        context: context,
                        child: PaymentCardListPage(
                          isPaymentStep: true,
                          restaurant: _restaurant,
                        ),
                        routeName: paymentCardListRoute,
                      );*/
                    }
                  }
                },
                child: this.sendingCommand
                    ? Center(
                        child: SizedBox(
                          height: 23,
                          width: 23,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
    );
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

                                      if (deliveryDate.day == now.day){
                                        if (deliveryTime.hour <= now.hour){
                                          deliveryTime = TimeOfDay(hour: now.hour, minute: 00) ;
                                        }
                                      }

                                      else if (deliveryTime.hour <= _restaurant.getFirstOpeningHour(deliveryDate,force: true)){
                                        deliveryTime = TimeOfDay(hour: _restaurant.getFirstOpeningHour(deliveryDate), minute: 00) ;
                                      }

                                      commandContext.deliveryTime = deliveryTime;
                                      // isToday = deliveryDate.day == now.day;
                                      // print("isToday $isToday");

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
                                  return List.generate(24, (index){ 
                                    
                                    // isToday = index == 0 ;  
                                    
                                    return TextTranslator(
                                        index == 0 ? "Aujourd'hui" :
                                        index == 1 ? "Demain" :
                                        "${now.add(Duration(days: index)).dateToString("EE dd MMM")}",
                                         style: TextStyle(
                                          fontSize: 18,
                                          color: CRIMSON,
                                          fontWeight: FontWeight.w600
                                        )
                                        );
                                        }
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
                for (int i = 
              deliveryDate.day == now.day ? now.hour 
              : _restaurant.getFirstOpeningHour(deliveryDate); i < 24; i++) ...[
                    DropdownMenuItem<TimeOfDay>(
                        value: TimeOfDay(hour: i, minute: 00),
                        child: TextTranslator(
                          now.hour == i ? "${TimeOfDay(hour: i, minute: (DateTime.now().add(Duration(minutes: 15)).minute)).format(context)}" :
                          "${TimeOfDay(hour: i, minute: 00).format(context)}",
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
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
              for (int i = 
              deliveryDate.day == now.day ? now.hour 
              : _restaurant.getFirstOpeningHour(deliveryDate); i < 24; i++) ...[
                  // if (deliveryDate.day == now.day && now.hour <= i)...[
                    DropdownMenuItem<TimeOfDay>(
                        value: TimeOfDay(hour: i, minute: 00),
                        child: TextTranslator(
                          now.hour == i ? "${TimeOfDay(hour: i, minute: (DateTime.now().add(Duration(minutes: 15)).minute)).format(context)}" :
                          "${TimeOfDay(hour: i, minute: 00).format(context)}",
                          style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600),
                        )),
                ]
            ],
          ),
        ),
      ),
    );
  }
 


}
