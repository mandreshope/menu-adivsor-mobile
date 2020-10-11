import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/types.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:provider/provider.dart';

class RestaurantPage extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantPage({
    Key key,
    this.restaurant,
  }) : super(key: key);

  @override
  _RestaurantPageState createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage>
    with SingleTickerProviderStateMixin {
  bool _isInFavorite = false;
  bool _showFavoriteButton = true;
  bool _loading = false;
  TabController _controller;
  int _activeTabIndex = 0;

  String _searchValue = '';
  List<SearchResult> _searchResults = [];
  Api _api = Api.instance;
  Timer _timer;

  bool _isSearching = false;

  String _lang;

  void _onChanged(String value) {
    setState(() {
      _loading = true;
      _searchValue = value;
    });

    if (_timer?.isActive ?? false) {
      _timer.cancel();
    }

    _timer = Timer(Duration(seconds: 1), _initSearch);
  }

  @override
  void initState() {
    super.initState();

    _lang = Provider.of<SettingContext>(context, listen: false).languageCode;

    _controller = TabController(
      vsync: this,
      initialIndex: 0,
      length: 3,
    );

    AuthContext authContext = Provider.of<AuthContext>(context, listen: false);
    if (authContext.currentUser == null) _showFavoriteButton = false;
    if (authContext.currentUser != null &&
        authContext.currentUser.favoriteRestaurants
                ?.indexWhere((element) => element.id == widget.restaurant.id) >
            1) _isInFavorite = true;
  }

  Future _initSearch() async {
    if (_searchValue == '') {
      _timer?.cancel();
      return;
    }

    if (!mounted) return;

    setState(() {
      _loading = true;
    });
    try {
      var results = await _api.search(
        _searchValue,
        filters: {
          'restaurant': widget.restaurant.id,
        },
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

  _toggleFavorite() {
    Fluttertoast.showToast(
      msg: AppLocalizations.of(context).translate(
        !_isInFavorite ? 'added_to_favorite' : 'removed_from_favorite',
      ),
    );
    setState(() {
      _isInFavorite = !_isInFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isSearching) {
          setState(() {
            _isSearching = false;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (_) => BagModal(),
              backgroundColor: Colors.transparent,
            );
          },
          child: FaIcon(
            FontAwesomeIcons.shoppingBag,
            color: Colors.white,
          ),
        ),
        appBar: _isSearching
            ? AppBar(
                title: Text(widget.restaurant.name),
              )
            : null,
        body: SafeArea(
          child: _isSearching
              ? Container()
              : CustomScrollView(
                  physics: BouncingScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 160.0,
                      floating: false,
                      pinned: true,
                      stretch: true,
                      title: Column(
                        children: [
                          Text(
                            widget.restaurant.name,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_on),
                              SizedBox(width: 5),
                              Text(widget.restaurant.address),
                            ],
                          ),
                        ],
                      ),
                      bottom: TabBar(
                        controller: _controller,
                        tabs: [
                          Tab(
                            text: AppLocalizations.of(context)
                                .translate('a_la_carte'),
                            icon: FaIcon(
                              FontAwesomeIcons.list,
                            ),
                          ),
                          Tab(
                            text:
                                AppLocalizations.of(context).translate('menus'),
                            icon: FaIcon(
                              FontAwesomeIcons.hamburger,
                            ),
                          ),
                          Tab(
                            text: AppLocalizations.of(context)
                                .translate('drinks'),
                            icon: FaIcon(
                              FontAwesomeIcons.wineGlass,
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        if (_showFavoriteButton)
                          IconButton(
                            onPressed: _toggleFavorite,
                            icon: Icon(
                              _isInFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.white,
                            ),
                          ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _isSearching = true;
                            });
                          },
                          icon: Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            String lang = await showDialog<String>(
                              context: context,
                              builder: (_) => LanguageDialog(lang: _lang),
                            );
                            print('Lang: $lang');
                          },
                          icon: Icon(
                            Icons.language,
                          ),
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: Image.network(
                          widget.restaurant.imageURL,
                          fit: BoxFit.cover,
                          color: Colors.black45,
                          colorBlendMode: BlendMode.darken,
                        ),
                        stretchModes: [
                          StretchMode.zoomBackground,
                        ],
                      ),
                    ),
                    SliverFillRemaining(
                      fillOverscroll: true,
                      child: TabBarView(
                        controller: _controller,
                        physics: BouncingScrollPhysics(),
                        children: [
                          Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                  top: 50,
                                  left: 20,
                                  right: 20,
                                ),
                                decoration: BoxDecoration(
                                  color: BACKGROUND_COLOR,
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.grey[400],
                                      style: BorderStyle.solid,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: SingleChildScrollView(
                                  physics: BouncingScrollPhysics(),
                                  child: Column(),
                                ),
                              ),
                              Positioned(
                                top: 10,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 41,
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  child: ListView(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      tab(
                                        text: "Entrées",
                                        index: 0,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      tab(
                                        text: "Entrées",
                                        index: 1,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      tab(
                                        text: "Entrées",
                                        index: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(),
                          Column(),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget tab({
    String text,
    int index,
  }) {
    return Material(
      child: InkWell(
        onTap: () {
          setState(() {
            _activeTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Text(
            text,
          ),
          decoration: BoxDecoration(
            color: BACKGROUND_COLOR,
            border: Border(
              top: BorderSide(
                width: 1,
                style: BorderStyle.solid,
                color: Colors.grey[400],
              ),
              right: BorderSide(
                width: 1,
                style: BorderStyle.solid,
                color: Colors.grey[400],
              ),
              left: BorderSide(
                width: 1,
                style: BorderStyle.solid,
                color: Colors.grey[400],
              ),
              bottom: _activeTabIndex == index
                  ? BorderSide(
                      width: 1,
                      style: BorderStyle.solid,
                      color: BACKGROUND_COLOR,
                    )
                  : BorderSide(
                      width: 1,
                      style: BorderStyle.solid,
                      color: Colors.grey[400],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
