import 'package:flutter/material.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
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

import '../models.dart';

class DeliveryDetailsPage extends StatefulWidget {
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    commandContext = Provider.of<CommandContext>(
      context,
      listen: false,
    );


    deliveryDate =  now.add(Duration(days: 0));
    deliveryTime = TimeOfDay(hour: now.hour,minute: 00);

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
                            keyboardType: TextInputType.streetAddress,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)
                                  .translate("address_placeholder"),
                            ),
                            onChanged: (value) {
                              commandContext.deliveryAddress = value;
                            },
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 35.0,
                            vertical: 15,
                          ),
                          child: TextTranslator(
                            AppLocalizations.of(context)
                                .translate('date_and_time'),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Container(
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
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 25.0),
                                    title: TextTranslator(
                                      AppLocalizations.of(context)
                                          .translate('as_soon_as_possible'),
                                    ),
                                    leading: Icon(
                                      Icons.timer,
                                    ),
                                    trailing: deliveryDate == null &&
                                            deliveryTime == null
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
                                      deliveryDate =  now.add(Duration(days: 0));
                                      deliveryTime = TimeOfDay(hour: now.hour,minute: 00);

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
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 25.0),
                                    title: TextTranslator(
                                      'Planifier une commande',
                                    ),
                                    leading: Icon(
                                      Icons.calendar_today_outlined,
                                    ),
                                    trailing: deliveryDate != null &&
                                            deliveryTime != null
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
                  FormState formState = formKey.currentState;

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
                      String code = await Api.instance.sendCode(
                          relatedUser: authContext.currentUser?.id ?? null,
                          customer: customer,
                          commandType: commandContext.commandType);

                      RouteUtil.goTo(
                        context: context,
                        child: ConfirmSms(
                          command: null,
                          isFromSignup: false,
                          customer:customer,
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
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
                    :TextTranslator(
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
      color: CRIMSON,
      margin: EdgeInsets.all(0),
        child: Container(
        height: 40,
        width: MediaQuery.of(context).size.width/2-10,
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
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600
                                        )
                                        )
                                        );
                                },
                                iconEnabledColor: Colors.white,
                                iconDisabledColor: Colors.white,
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
        color: CRIMSON,
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
                                          style:TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
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
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600
                                          ),
                                        )
                                      ),
                                    ]
                                  ];
                                  return List.generate(24, (index) => TextTranslator(
                                        "${TimeOfDay(hour: index, minute: 00).format(context)}",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600
                                        ),
                                        ));
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
