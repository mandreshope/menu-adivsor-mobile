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
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class RestaurantPage extends StatefulWidget {
  final String restaurant;

  const RestaurantPage({
    Key key,
    this.restaurant,
  }) : super(key: key);

  @override
  _RestaurantPageState createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> with SingleTickerProviderStateMixin {
  bool isInFavorite = false;
  bool showFavoriteButton = true;
  bool searchLoading = false;
  bool loading = true;
  bool switchingFavorite = false;
  TabController tabController;
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

  Map<String, List<Food>> foods = Map();

  Restaurant restaurant;

  ItemScrollController itemScrollController = ItemScrollController();
  ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();

    _lang = Provider.of<SettingContext>(context, listen: false).languageCode;

    api
        .getRestaurant(
      id: widget.restaurant,
      lang: Provider.of<SettingContext>(
        context,
        listen: false,
      ).languageCode,
    )
        .then((res) async {
      restaurant = res;
      AuthContext authContext = Provider.of<AuthContext>(
        context,
        listen: false,
      );

      if (authContext.currentUser == null) showFavoriteButton = false;
      if (authContext.currentUser != null && authContext.currentUser.favoriteRestaurants.contains(restaurant.id)) isInFavorite = true;

      drinks = await api.getFoods(
        Provider.of<SettingContext>(
          context,
          listen: false,
        ).languageCode,
        filters: {
          'type': 'drink',
        },
      );

      tabController = TabController(
        vsync: this,
        initialIndex: 0,
        length: 3 + restaurant.foodTypes.length,
      );

      tabController.addListener(() {
        print(tabController.index);
        itemScrollController.scrollTo(
          index: tabController.index,
          duration: Duration(
            milliseconds: 400,
          ),
        );
      });

      itemPositionsListener.itemPositions.addListener(() {
        print('Scroll position: ${itemPositionsListener.itemPositions.value.first.index}');
        tabController.animateTo(itemPositionsListener.itemPositions.value.first.index);
      });

      filters['restaurant'] = restaurant.id;
      foodType = restaurant.foodTypes.first['tag'];

      for (int i = 0; i < restaurant.foodTypes.length; i++) {
        var element = restaurant.foodTypes[i]['tag'];
        foods[element] = await api.getFoods(
          Provider.of<SettingContext>(
            context,
            listen: false,
          ).languageCode,
          filters: {
            'restaurant': widget.restaurant,
            'type': element,
          },
        );
      }

      setState(() {
        loading = false;
      });
    }).catchError((error) {
      print(error);
      Fluttertoast.showToast(
        msg: 'Erreur lors du chargement...',
      );
      RouteUtil.goBack(context: context);
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
        type: type,
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

  _toggleFavorite() async {
    if (switchingFavorite) return;

    AuthContext authContext = Provider.of<AuthContext>(
      context,
      listen: false,
    );

    setState(() {
      switchingFavorite = true;
    });
    if (isInFavorite)
      await authContext.removeFromFavoriteRestaurants(restaurant);
    else
      await authContext.addToFavoriteRestaurants(restaurant);

    await Fluttertoast.showToast(
      msg: AppLocalizations.of(context).translate(
        !isInFavorite ? 'added_to_favorite' : 'removed_from_favorite',
      ),
    );
    if (mounted)
      setState(() {
        isInFavorite = !isInFavorite;
        switchingFavorite = false;
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
      child: Localizations.override(
        context: context,
        locale: Locale(_lang),
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
          body: loading
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
                      AppLocalizations.of(context).translate('start_by_typing_your_research'),
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
                              valueColor: AlwaysStoppedAnimation<Color>(CRIMSON),
                            ),
                          ),
                        if (!searchLoading && searchResults.length == 0)
                          Center(
                            child: Text(
                              AppLocalizations.of(context).translate('no_result'),
                            ),
                          ),
                        ...searchResults.map((SearchResult e) {
                          if (e.type.toString() == 'SearchResultType.restaurant')
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
                                lang: _lang,
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
          controller: tabController,
          isScrollable: true,
          tabs: [
            Tab(
              text: AppLocalizations.of(context).translate('a_la_carte'),
            ),
            for (var foodType in restaurant.foodTypes)
              Tab(
                text: foodType[Provider.of<SettingContext>(context).languageCode],
              ),
            Tab(
              text: AppLocalizations.of(context).translate('menus'),
            ),
            Tab(
              text: AppLocalizations.of(context).translate('drinks'),
            ),
          ],
        ),
        actions: [
          if (showFavoriteButton)
            switchingFavorite
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: SizedBox(
                        height: 14,
                        child: FittedBox(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(CRIMSON),
                          ),
                        ),
                      ),
                    ),
                  )
                : IconButton(
                    onPressed: _toggleFavorite,
                    icon: Icon(
                      isInFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isInFavorite ? CRIMSON : Colors.white,
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                restaurant.imageURL,
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            color: Colors.black.withOpacity(.6),
          ),
        ),
      ),
      body: ScrollablePositionedList.separated(
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        itemCount: 3 + restaurant.foodTypes.length,
        padding: const EdgeInsets.all(20),
        physics: BouncingScrollPhysics(),
        itemBuilder: (_, index) {
          if (index == 0)
            return Text(
              AppLocalizations.of(context).translate('a_la_carte'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            );

          if (index == 3 + restaurant.foodTypes.length - 2)
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppLocalizations.of(context).translate('menu'),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                _renderMenus(),
              ],
            );

          if (index == 3 + restaurant.foodTypes.length - 1)
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppLocalizations.of(context).translate('drinks'),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                _renderDrinks(),
              ],
            );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                restaurant.foodTypes[index - 1][Provider.of<SettingContext>(context).languageCode],
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              _renderFoodListOfType(restaurant.foodTypes[index - 1]['tag']),
            ],
          );
        },
        separatorBuilder: (_, index) => Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          child: Divider(),
        ),
      ),
    );
  }

  Widget _renderDrinks() {
    return drinks.length > 0
        ? SingleChildScrollView(
            child: Column(
              children: drinks
                  .map(
                    (food) => DrinkCard(
                      food: food,
                    ),
                  )
                  .toList(),
            ),
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
          );
  }

  Widget _renderMenus() {
    return FutureBuilder<List<Menu>>(
      future: api.getMenus(
        _lang,
        restaurant.id,
      ),
      builder: (_, snapshot) {
        if (!snapshot.hasData)
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(CRIMSON),
            ),
          );

        var menus = snapshot.data;
        return menus.length > 0
            ? SingleChildScrollView(
                child: Column(
                  children: menus
                      .map(
                        (e) => MenuCard(
                          menu: e,
                          lang: _lang,
                        ),
                      )
                      .toList(),
                ),
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
              );
      },
    );
  }

  Widget _renderFoodListOfType(String foodType) {
    return foods[foodType].length > 0
        ? SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            child: Column(
              children: foods[foodType]
                  .map(
                    (food) => RestaurantFoodCard(
                      food: food,
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
                size: 20,
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
