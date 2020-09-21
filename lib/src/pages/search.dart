import 'package:flutter/material.dart';
import 'package:menu_advisor/src/components/utilities.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldWithBottomMenu(
      appBar: AppBar(
        title: Text("Rechercher"),
      ),
      body: Container(),
    );
  }
}
