import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/components/cards.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models/models.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/types/types.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/textFormFieldTranslator.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';
import 'package:menu_advisor/src/utils/extensions.dart';

class SearchPage extends StatefulWidget {
  final String type;
  final Map<String, dynamic> filters;
  final bool showButton;
  final Map location;
  final bool fromCategory;
  final bool fromRestaurantHome;

  final String barTitle;

  SearchPage({
    this.type = 'all',
    this.fromRestaurantHome = false,
    this.location,
    this.filters = const {},
    this.showButton = false,
    this.barTitle = 'Rechercher',
    this.fromCategory = false,
  });

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
  List<FoodAttribute> _foodAttributSelected = [];

  @override
  void initState() {
    super.initState();

    range = Provider.of<SettingContext>(context, listen: false).range;
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
        type: filters.containsKey("category") && !filters.containsKey("attributes") ? type = 'restaurant' : type,
        filters: filters,
        range: range,
        location: widget.location,
      );
      setState(() {
        _searchResults = results.where((search) {
          if (search.type.toString() == "SearchResultType.food") {
            Food f = Food.fromJson(search.content);
            f.isPopular = true;
            return f.restaurant['referencement'] && f.restaurant['status'];
          } else if (search.type.toString() == "SearchResultType.restaurant") {
            Restaurant f = Restaurant.fromJson(search.content);
            return f.status && f.accessible;
          } else if (search.type.toString() == "SearchResultType.menu") {
            Menu f = Menu.fromJson(search.content);
            return f.restaurant.status && f.restaurant.accessible;
          }
          return true;
        }).toList();
        _searchResults.sort((a, b) {
          if (a.type.toString() == "SearchResultType.menu" && b.type.toString() == "SearchResultType.menu" ||
              a.type.toString() == "SearchResultType.food" && b.type.toString() == "SearchResultType.menu" ||
              a.type.toString() == "SearchResultType.food" && b.type.toString() == "SearchResultType.food") {
            return (a.content["restaurant"]["name"]).compareTo(b.content["restaurant"]["name"]);
          } else if (a.type.toString() == "SearchResultType.food" && b.type.toString() == "SearchResultType.restaurant") {
            return (a.content["restaurant"]["name"]).compareTo(b.content["name"]);
          } else if (b.type.toString() == "SearchResultType.food" && a.type.toString() == "SearchResultType.restaurant") {
            return (a.content["name"]).compareTo(b.content["restaurant"]["name"]);
          } else /*if (a.type.toString() == "SearchResultType.restaurant" && b.type.toString() == "SearchResultType.restaurant")*/ {
            return (a.content["name"]).compareTo(b.content["name"]);
          }
        });

        final allergenSelectedList = _foodAttributSelected.where((e) => e.tag.contains("allergen")).toList();
        if (allergenSelectedList.length != null) {
          for (final allergenSelected in allergenSelectedList) {
            _searchResults.retainWhere((search) {
              final getAllergenIds = (search.content["allergene"] as List).map((allergen) => allergen['_id']).toList();
              // retain where allergen not find
              return !getAllergenIds.contains(allergenSelected.sId);
            });
          }
        }

        _searchResultsGrouped = _searchResults.groupBy((s) {
          if (s.type.toString() == "SearchResultType.menu") {
            return s.content["restaurant"]["name"];
          } else if (s.type.toString() == "SearchResultType.food") {
            return s.content["restaurant"]["name"];
          } else {
            return s.content['name'];
          }
        });

        print("_searchResultsGrouped ${_searchResultsGrouped.length}");
      });
    } catch (error) {
      print(error.toString());
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
            onPressed: _initSearch,
          ),
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
                                for (MapEntry<String, List<SearchResult>> values in _searchResultsGrouped.entries) ...[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        // padding: const EdgeInsets.only(top: 15,left: 15,bottom: 15),
                                        margin: EdgeInsets.only(top: 15, bottom: 15),
                                        height: 50,
                                        width: double.infinity,
                                        color: CRIMSON,
                                        child: Center(
                                          child: TextTranslator(
                                            values.key,
                                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      for (SearchResult e in values.value) ...[
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
                                              food: Food.fromJson(e.content, isPopular: true),
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
                              // else if (e.type.toString() == '')
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
                              fromCategory: widget.fromCategory,
                              fromRestaurantHome: widget.fromRestaurantHome,
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
                              _foodAttributSelected = result['foodAttributSelected'];
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
