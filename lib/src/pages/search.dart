import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchValue = '';
  bool loading = false;
  bool isSettingExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rechercher"),
      ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(top: 90),
              child: _searchValue.length == 0
                  ? Center(
                      child: Text(
                        "Commencer par entrer votre recherche...",
                      ),
                    )
                  : Column(
                      children: [],
                    ),
            ),
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 100),
                constraints: BoxConstraints(
                  maxHeight: isSettingExpanded ? 200 : 50,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.8),
                  borderRadius: isSettingExpanded
                      ? BorderRadius.circular(10)
                      : BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      spreadRadius: 0,
                      color: Colors.black26,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.search,
                          size: 16,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration.collapsed(
                              hintText: AppLocalizations.of(context)
                                  .translate("find_something"),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchValue = value;
                              });
                            },
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            setState(() {
                              isSettingExpanded = !isSettingExpanded;
                            });
                          },
                          icon: FaIcon(
                            FontAwesomeIcons.slidersH,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
