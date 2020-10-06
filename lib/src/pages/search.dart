import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/components/cards.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/types.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';

class SearchPage extends StatefulWidget {
  final String type;

  SearchPage({
    this.type = 'all',
  });

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchValue = '';
  bool _loading = false;
  bool isSettingExpanded = false;
  List<SearchResult> _searchResults = [];
  Api _api = Api.instance;
  Timer _timer;
  Map<String, dynamic> filters = Map();

  void _onChanged(String value) {
    setState(() {
      _loading = true;
      _searchValue = value;
      _searchResults = [];
    });

    if (_timer?.isActive ?? false) {
      _timer.cancel();
    }

    _timer = Timer(Duration(seconds: 1), _initSearch);
  }

  Future _initSearch() async {
    if (_searchValue == '') {
      _timer?.cancel();
      return;
    }

    setState(() {
      _loading = true;
    });
    try {
      var results = await _api.search(
        _searchValue,
        type: widget.type,
        filters: filters,
      );
      setState(() {
        _searchResults = results;
      });
    } catch (error) {
      print(error.toString());
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translate('connection_issue'),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

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
            RefreshIndicator(
              onRefresh: () async {
                await _initSearch();
                return;
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.only(top: 90),
                physics: BouncingScrollPhysics(),
                child: _searchValue.length == 0
                    ? Center(
                        child: Text(
                          AppLocalizations.of(context)
                              .translate('start_by_typing_your_research'),
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (_loading)
                              Center(
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(CRIMSON),
                                ),
                              ),
                            if (!_loading && _searchResults.length == 0)
                              Center(
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate('no_result'),
                                ),
                              ),
                            ..._searchResults.map((SearchResult e) {
                              if (e.type.toString() ==
                                  'SearchResultType.restaurant')
                                return RestaurantCard(
                                  restaurant: Restaurant.fromJson(e.content),
                                );
                              else if (e.type.toString() ==
                                  'SearchResultType.food')
                                return FoodCard(
                                  food: Food.fromJson(e.content),
                                );
                              else if (e.type.toString() ==
                                  'SearchResultType.menu')
                                return MenuCard(
                                  menu: Menu.fromJson(e.content),
                                );

                              return null;
                            }).toList(),
                          ],
                        ),
                      ),
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
                  vertical: 15,
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
                child: Row(
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
                        onChanged: _onChanged,
                      ),
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
