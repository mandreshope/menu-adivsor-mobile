import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/components/cards.dart';
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
  final String restaurant;

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
  bool showFavoriteButton = true;
  bool searchLoading = false;
  bool loading = true;
  TabController controller;
  int activeTabIndex = 0;

  String searchValue = '';
  List<SearchResult> searchResults = [];
  Api api = Api.instance;
  Timer timer;

  Map<String, dynamic> filters = Map();
  String type = 'all';

  bool _isSearching = false;

  String _lang;
  List<Food> drinks = [];

  String foodType;

  Restaurant restaurant;

  @override
  void initState() {
    super.initState();

    _lang = Provider.of<SettingContext>(context, listen: false).languageCode;

    controller = TabController(
      vsync: this,
      initialIndex: 0,
      length: 3,
    );

    api.getRestaurant(id: widget.restaurant).then((res) {
      setState(() {
        restaurant = res;
        loading = false;
        drinks = restaurant.foods
                .where((element) => element.type == 'drink')
                .toList() ??
            [];

        foodType = restaurant.foodTypes.first['name'];
      });

      filters['restaurant'] = restaurant.id;
      AuthContext authContext =
          Provider.of<AuthContext>(context, listen: false);
      if (authContext.currentUser == null) showFavoriteButton = false;
      if (authContext.currentUser != null &&
          authContext.currentUser.favoriteRestaurants
                  ?.indexWhere((element) => element.id == restaurant.id) >
              1) isInFavorite = true;
    });
  }

  void _onChanged(String value) {
    setState(() {
      searchLoading = true;
      searchValue = value;
    });

    if (timer?.isActive ?? false) {
      timer.cancel();
    }

    timer = Timer(
      Duration(seconds: 1),
      _initSearch,
    );
  }

  Future _initSearch() async {
    if (searchValue == '') {
      timer?.cancel();
      return;
    }

    if (!mounted) return;

    setState(() {
      searchLoading = true;
    });
    try {
      var results = await api.search(
        searchValue,
        _lang,
        filters: {
          'restaurant': restaurant.id,
        },
      );
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
        searchLoading = false;
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
                title: Text(restaurant.name),
              )
            : null,
        body: SafeArea(
          child: loading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(CRIMSON),
                  ),
                )
              : _isSearching
                  ? _renderSearchView()
                  : _renderMainScreen(),
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
            activeTabIndex = index;
            if (restaurant.foodTypes.length > 0)
              foodType = restaurant.foodTypes[index]['tag'];
            else
              foodType = 'all';
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
              bottom: activeTabIndex == index
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

  Widget _renderSearchView() {
    return Stack(
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
            child: searchValue.length == 0
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
                        if (searchLoading)
                          Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(CRIMSON),
                            ),
                          ),
                        if (!searchLoading && searchResults.length == 0)
                          Center(
                            child: Text(
                              AppLocalizations.of(context)
                                  .translate('no_result'),
                            ),
                          ),
                        ...searchResults.map((SearchResult e) {
                          if (e.type.toString() ==
                              'SearchResultType.restaurant')
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: 10,
                              ),
                              child: RestaurantCard(
                                restaurant: Restaurant.fromJson(e.content),
                              ),
                            );
                          else if (e.type.toString() == 'SearchResultType.food')
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: 10,
                              ),
                              child: FoodCard(
                                food: Food.fromJson(e.content),
                              ),
                            );
                          else if (e.type.toString() == 'SearchResultType.menu')
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: 10,
                              ),
                              child: MenuCard(
                                menu: Menu.fromJson(e.content),
                              ),
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
                  child: TextFormField(
                    decoration: InputDecoration.collapsed(
                      hintText: AppLocalizations.of(context)
                          .translate("find_something"),
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
                          languageCode:
                              Provider.of<SettingContext>(context).languageCode,
                          inRestaurant: true,
                          filters: filters,
                          type: type,
                        ),
                      );
                      if (filters is Map && filters.entries.length > 0) {
                        setState(() {
                          filters = result['filters'];
                          type = result['type'];
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
    );
  }

  Widget _renderMainScreen() {
    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 160.0,
          floating: false,
          pinned: true,
          stretch: true,
          centerTitle: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                restaurant.name,
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 14,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    restaurant.address,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          bottom: TabBar(
            controller: controller,
            tabs: [
              Tab(
                text: AppLocalizations.of(context).translate('a_la_carte'),
                icon: FaIcon(
                  FontAwesomeIcons.list,
                ),
              ),
              Tab(
                text: AppLocalizations.of(context).translate('menus'),
                icon: FaIcon(
                  FontAwesomeIcons.hamburger,
                ),
              ),
              Tab(
                text: AppLocalizations.of(context).translate('drinks'),
                icon: FaIcon(
                  FontAwesomeIcons.wineGlass,
                ),
              ),
            ],
          ),
          actions: [
            if (showFavoriteButton)
              IconButton(
                onPressed: _toggleFavorite,
                icon: Icon(
                  isInFavorite ? Icons.favorite : Icons.favorite_border,
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
                if (lang != null)
                  setState(() {
                    _lang = lang;
                  });
              },
              icon: Icon(
                Icons.language,
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Image.network(
              restaurant.imageURL,
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
            controller: controller,
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
                    child: _renderFoodListOfType(foodType),
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
                          if (restaurant.foodTypes.length > 0)
                            for (int i = 0;
                                i < restaurant.foodTypes.length;
                                i++) ...[
                              tab(
                                index: i,
                                text: restaurant.foodTypes[i][
                                    Provider.of<SettingContext>(context)
                                        .languageCode],
                              ),
                              if (i < restaurant.foodTypes.length - 1)
                                SizedBox(
                                  width: 5,
                                ),
                            ]
                          else
                            tab(
                              index: 0,
                              text:
                                  AppLocalizations.of(context).translate('all'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              restaurant.menus.length > 0
                  ? Column(
                      children: restaurant.menus
                          .map(
                            (e) => Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                              ),
                            ),
                          )
                          .toList(),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.warning,
                          size: 40,
                        ),
                        Text(
                          AppLocalizations.of(context).translate('no_menu'),
                          style: TextStyle(
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
              drinks.length > 0
                  ? Column(
                      children: drinks
                          .map(
                            (food) => Card(
                              elevation: 2.0,
                              margin: const EdgeInsets.all(10.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    food.imageURL != null
                                        ? CircleAvatar(
                                            backgroundImage: NetworkImage(
                                              food.imageURL,
                                            ),
                                            onBackgroundImageError: (_, __) {},
                                            backgroundColor: Colors.grey,
                                            maxRadius: 20,
                                          )
                                        : Icon(
                                            Icons.fastfood,
                                          ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            food.name,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (food.price != null)
                                            Text(
                                              '${food.price.amount / 100}€',
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.warning,
                          size: 40,
                        ),
                        Text(
                          AppLocalizations.of(context).translate('no_drink'),
                          style: TextStyle(
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _renderFoodListOfType(String foodType) {
    var foods = foodType != 'all'
        ? restaurant.foods.where((food) => food.type == foodType).toList() ?? []
        : restaurant.foods;

    return foods.length > 0
        ? SingleChildScrollView(
            child: Column(
              children: foods
                  .map(
                    (e) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                width: MediaQuery.of(context).size.width / 8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      e.imageURL,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          )
        : Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.warning,
                size: 40,
              ),
              Text(
                AppLocalizations.of(context).translate('no_food'),
                style: TextStyle(
                  fontSize: 22,
                ),
              ),
            ],
          );
  }
}
