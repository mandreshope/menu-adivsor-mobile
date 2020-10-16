import 'package:flutter/material.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/pages/payment_card_list.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/CommandContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:provider/provider.dart';

class DeliveryDetailsPage extends StatefulWidget {
  @override
  _DeliveryDetailsPageState createState() => _DeliveryDetailsPageState();
}

class _DeliveryDetailsPageState extends State<DeliveryDetailsPage> {
  DateTime deliveryDate;
  TimeOfDay deliveryTime;
  GlobalKey<FormState> formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text(
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
                          child: TextFormField(
                            keyboardType: TextInputType.streetAddress,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context).translate("address_placeholder"),
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
                          child: Text(
                            AppLocalizations.of(context).translate('date_and_time'),
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
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 25.0),
                                    title: Text(
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
                                    var date = await showDatePicker(
                                      context: context,
                                      initialDate: deliveryDate ?? DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(
                                        Duration(days: 30),
                                      ),
                                    );
                                    if (date != null) {
                                      var time = await showTimePicker(
                                        context: context,
                                        initialTime: deliveryTime ??
                                            TimeOfDay(
                                              hour: 6,
                                              minute: 0,
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
                                    }
                                  },
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 25.0),
                                    title: Text(
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
                onPressed: () {
                  FormState formState = formKey.currentState;

                  if (formState.validate()) {
                    AuthContext authContext = Provider.of<AuthContext>(
                      context,
                      listen: false,
                    );

                    if (authContext.currentUser != null) {
                      RouteUtil.goTo(
                        context: context,
                        child: PaymentCardListPage(
                          isPaymentStep: true,
                        ),
                        routeName: paymentCardListRoute,
                      );
                    }
                  }
                },
                child: Text(
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
}
