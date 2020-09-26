import 'package:flutter/material.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('order'),
        ),
      ),
      body: Container(),
    );
  }
}
