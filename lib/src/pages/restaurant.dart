import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/components/cards.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
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
  bool isInFavorite = false;
  bool loading = false;
  TabController _controller;

  String _searchValue = '';
  List<SearchResult> searchResults = [];
  Api _api = Api.instance;
  Timer _timer;

  void _onChanged(String value) {
    setState(() {
      loading = true;
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

    _controller = TabController(
      vsync: this,
      initialIndex: 0,
      length: 3,
    );

    AuthContext authContext = Provider.of<AuthContext>(context, listen: false);
    if (authContext.currentUser.favoriteRestaurants
            .indexWhere((element) => element.id == widget.restaurant.id) >
        1) isInFavorite = true;
  }

  Future _initSearch() async {
    if (_searchValue == '') {
      _timer?.cancel();
      return;
    }

    setState(() {
      loading = true;
    });
    try {
      var results = await _api.search(_searchValue);
      setState(() {
        searchResults = results;
      });
    } catch (error) {
      print(error.toString());
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translate('connection_issue'),
      );
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  _toggleFavorite() {
    Fluttertoast.showToast(
      msg: AppLocalizations.of(context).translate(
        !isInFavorite ? 'added_to_favorite' : 'removed_from_favorite',
      ),
    );
    setState(() {
      isInFavorite = !isInFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              stretch: true,
              title: Text(
                widget.restaurant.name,
              ),
              bottom: TabBar(
                controller: _controller,
                tabs: [
                  Tab(
                    text: AppLocalizations.of(context).translate('description'),
                    icon: FaIcon(
                      FontAwesomeIcons.infoCircle,
                    ),
                  ),
                  Tab(
                    text: AppLocalizations.of(context).translate('menus'),
                    icon: FaIcon(
                      FontAwesomeIcons.hamburger,
                    ),
                  ),
                  Tab(
                    text: AppLocalizations.of(context).translate('research'),
                    icon: FaIcon(
                      FontAwesomeIcons.search,
                    ),
                  ),
                ],
              ),
              onStretchTrigger: () async {
                print("Danze");
                return;
              },
              actions: [
                IconButton(
                  onPressed: _toggleFavorite,
                  icon: Icon(
                    isInFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white,
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
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 40,
                          left: 40,
                          right: 40,
                          bottom: 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)
                                  .translate('description'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Text(
                              widget.restaurant.description.length > 0
                                  ? widget.restaurant.description
                                  : AppLocalizations.of(context)
                                      .translate('no_description'),
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xff6D6D6D),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              widget.restaurant.description?.length > 0 ?? false
                                  ? widget.restaurant.description
                                  : AppLocalizations.of(context)
                                      .translate('our_foods'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            widget.restaurant.menus.length > 0
                                ? Wrap(
                                    children: widget.restaurant.menus
                                        .map(
                                          (e) => Card(
                                            elevation: 4.0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  )
                                : Text(
                                    widget.restaurant.description.length > 0
                                        ? widget.restaurant.description
                                        : AppLocalizations.of(context)
                                            .translate('no_menu'),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xff6D6D6D),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  widget.restaurant.menus.length > 0
                      ? Column(
                          mainAxisSize: MainAxisSize.max,
                          children: widget.restaurant.menus
                              .map(
                                (e) => MenuCard(
                                  menu: e,
                                ),
                              )
                              .toList(),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.warning,
                              size: 80,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40.0,
                              ),
                              child: Text(
                                AppLocalizations.of(context)
                                    .translate('no_menu'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                  Stack(
                    fit: StackFit.expand,
                    children: [
                      Column(
                        children: [],
                      ),
                      Positioned(
                        top: 20,
                        left: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
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
                                      onChanged: _onChanged,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
