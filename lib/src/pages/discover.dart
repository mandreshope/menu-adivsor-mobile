import 'package:flutter/material.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';

class DiscoverPage extends StatefulWidget {
  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('discover'),
        ),
      ),
      body: Center(
        child: Text(
          "En cours de construction...",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w200,
          ),
        ),
      ),
    );
  }
}
