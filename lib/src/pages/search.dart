import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/components/cards.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/types.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/textFormFieldTranslator.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';
import 'package:menu_advisor/src/utils/extensions.dart';
import 'package:sortedmap/sortedmap.dart';

class SearchPage extends StatefulWidget {
  final String type;
  final Map<String, dynamic> filters;
  final bool showButton;
  final Map location;

  final String barTitle;

  SearchPage({this.type = 'all', this.location,this.filters = const {}, this.showButton = false, this.barTitle = 'Rechercher'});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchValue = '';
  bool _loading = false;
  List<SearchResult> _searchResults;
  Api _api = Api.instance;
  Timer _timer;
  Map<String, dynamic> filters = Map();
  String type;
  int range;
  Map<String, List<SearchResult>> _searchResultsGrouped = Map();

  @override
  void initState() {
    super.initState();

    range = Provider.of<SettingContext>(context,listen: false).range;
    filters.addAll(widget.filters);
    type = widget.type;

    if (type != 'all') _initSearch();
  }

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
    if (type == 'all' && _searchValue == '') {
      _timer?.cancel();
      return;
    }

    setState(() {
      _loading = true;
    });
    try {
      var results = await _api.search(
        _searchValue,
        Provider.of<SettingContext>(
          context,
          listen: false,
        ).languageCode,
        type: type,
        filters: filters,
        range: range,
        location: widget.location
      );
      setState(() {
        _searchResults = results;
        _searchResults.sort((a, b) {
          if (a.type.toString() == "SearchResultType.menu" && b.type.toString() == "SearchResultType.menu"
          || a.type.toString() == "SearchResultType.food" && b.type.toString() == "SearchResultType.menu" ||
              a.type.toString() == "SearchResultType.food" && b.type.toString() == "SearchResultType.food") {
            return (a.content["restaurant"]["name"]).compareTo(b.content["restaurant"]["name"]);

          } else if (a.type.toString() == "SearchResultType.food" && b.type.toString() == "SearchResultType.restaurant") {
            return (a.content["restaurant"]["name"]).compareTo(b.content["name"]);
          }else if (b.type.toString() == "SearchResultType.food" && a.type.toString() == "SearchResultType.restaurant"){
            return (a.content["name"]).compareTo(b.content["restaurant"]["name"]);
          }else /*if (a.type.toString() == "SearchResultType.restaurant" && b.type.toString() == "SearchResultType.restaurant")*/{
            return (a.content["name"]).compareTo(b.content["name"]);
          }
        });
        _searchResultsGrouped = _searchResults.groupBy((s){
            if (s.type.toString() == "SearchResultType.menu"){
              return s.content["restaurant"]["name"];
            }else if (s.type.toString() == "SearchResultType.food") {
            return s.content["restaurant"]["name"];
          }else{
              return s.content['name'];
            }
        });

        print("_searchResultsGrouped ${_searchResultsGrouped.length}");
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
        actions: [
          IconButton(
              icon: Icon(
                Icons.refresh_sharp,
              ),
              onPressed: _initSearch),
        ],
        title: TextTranslator(widget.barTitle),
      ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            RefreshIndicator(
              onRefresh: _initSearch,
              child: Container(
                color: Colors.white,
                height: double.infinity,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(top: 90),
                  physics: AlwaysScrollableScrollPhysics(),
                  child: _searchValue.length == 0 && type == 'all'
                      ? Center(
                          child: TextTranslator(
                            AppLocalizations.of(context).translate('start_by_typing_your_research'),
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
                                    valueColor: AlwaysStoppedAnimation<Color>(CRIMSON),
                                  ),
                                ),
                              if (!_loading && _searchResultsGrouped.length == 0)
                                Center(
                                  child: TextTranslator(
                                    AppLocalizations.of(context).translate('no_result'),
                                  ),
                                ),
                              if (!_loading)
                                for (MapEntry<String, List<SearchResult>> values in _searchResultsGrouped.entries)...[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        // padding: const EdgeInsets.only(top: 15,left: 15,bottom: 15),
                                        margin: EdgeInsets.only(top: 15,bottom: 15),
                                        height: 50,
                                        width: double.infinity,
                                        color: CRIMSON,
                                        child: Center(
                                          child: TextTranslator(values.key,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold
                                          ),
                                          ),
                                        ),
                                      ),
                                      for (SearchResult e in values.value)...[
                                        if (e.type.toString() == 'SearchResultType.restaurant')
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 10,
                                            ),
                                            child: RestaurantCard(
                                              restaurant: Restaurant.fromJson(e.content),
                                            ),
                                          )
                                        else if (e.type.toString() == 'SearchResultType.food')
                                           Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 10,
                                            ),
                                            child: FoodCard(
                                              food: Food.fromJson(e.content),
                                            ),
                                          )
                                        else if (e.type.toString() == 'SearchResultType.menu')
                                           Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 10,
                                            ),
                                            child: MenuCard(
                                              lang: Provider.of<SettingContext>(context).languageCode,
                                              menu: Menu.fromJson(e.content),
                                            ),
                                          )
                                      ]
                                    ],
                                  )
                                ]

                                // ..._searchResultsGrouped.map((String key,List<SearchResult> values) {

                                  // if (e.type.toString() == 'SearchResultType.restaurant')
                                  //   return Padding(
                                  //     padding: const EdgeInsets.only(
                                  //       bottom: 10,
                                  //     ),
                                  //     child: RestaurantCard(
                                  //       restaurant: Restaurant.fromJson(e.content),
                                  //     ),
                                  //   );
                                  // else if (e.type.toString() == 'SearchResultType.food')
                                  //   return Padding(
                                  //     padding: const EdgeInsets.only(
                                  //       bottom: 10,
                                  //     ),
                                  //     child: FoodCard(
                                  //       food: Food.fromJson(e.content),
                                  //     ),
                                  //   );
                                  // else if (e.type.toString() == 'SearchResultType.menu')
                                  //   return Padding(
                                  //     padding: const EdgeInsets.only(
                                  //       bottom: 10,
                                  //     ),
                                  //     child: MenuCard(
                                  //       lang: Provider.of<SettingContext>(context).languageCode,
                                  //       menu: Menu.fromJson(e.content),
                                  //     ),
                                  //   );

                                  // return null;
                                // }).toList(),
                            ],
                          ),
                        ),
                ),
              ),
            ),
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.8),
                  borderRadius: BorderRadius.circular(50),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.search,
                      size: 16,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormFieldTranslator(
                        decoration: InputDecoration.collapsed(
                          hintText: AppLocalizations.of(context).translate("find_something"),
                        ),
                        onChanged: _onChanged,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.contain,
                      child: IconButton(
                        onPressed: () async {
                          var result = await showDialog<Map<String, dynamic>>(
                            context: context,
                            builder: (_) => SearchSettingDialog(
                              languageCode: Provider.of<SettingContext>(context).languageCode,
                              filters: filters,
                              type: type,
                              range: Provider.of<SettingContext>(context).range,
                              isDiscover: widget.barTitle == 'Découvrir' ? true : false,
                            ),
                          );
                          if (result != null && result['filters'] is Map) {
                            setState(() {
                              filters = result['filters'];
                              type = result['type'];
                              range = result['range'];
                            });
                            _initSearch();
                          }
                        },
                        icon: FaIcon(
                          FontAwesomeIcons.slidersH,
                        ),
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
