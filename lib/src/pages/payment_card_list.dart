import 'package:flutter/material.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';

class PaymentCardListPage extends StatefulWidget {
  @override
  _PaymentCardListPageState createState() => _PaymentCardListPageState();
}

class _PaymentCardListPageState extends State<PaymentCardListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate('my_payment_cards'),
        ),
      ),
      body: Container(),
    );
  }
}
