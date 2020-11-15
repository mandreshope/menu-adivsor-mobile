import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/components/buttons.dart';
import 'package:menu_advisor/src/components/cards.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/types.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'order.dart';

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

  ScrollController _scrollController = ScrollController();
  bool _canScrollListRestaurant = false;

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
          'restaurant': restaurant.id,
        },
      );

      tabController = TabController(
        vsync: this,
        initialIndex: 0,
        length: 2 + restaurant.foodTypes.length,
      );

      tabController.addListener(() {
        print(tabController.index);
        itemScrollController.jumpTo(index: tabController.index);
      });

      itemPositionsListener.itemPositions.addListener(() {
        print('Scroll position: ${itemPositionsListener.itemPositions.value.first.index}');
        tabController.animateTo(itemPositionsListener.itemPositions.value.first.index);

        //print("_scrollController.offset ${_scrollController.offset}");
        /*if (_scrollController.offset >= 215) {
          setState(() {
            _canScrollListRestaurant = true;
          });
        } else {
          // setState(() {
          _canScrollListRestaurant = false;
          // });
        }*/
      });

      _scrollController.addListener(() {
        print("_scrollController.offset ${_scrollController.offset}");
        // if (itemPositionsListener.itemPositions.value.first.index < itemPositionsListener.itemPositions.value.length)
      });

      filters['restaurant'] = restaurant.id;
      if (restaurant.foodTypes.length > 0) foodType = restaurant.foodTypes.first['tag'];

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
      foods.forEach((key, value) {
        value.forEach((element) {
          element.attributes.forEach((att) async {
            element.foodAttributes.add(await api.getFoodAttribute(id:att));
          });
        });
      });

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
          /*floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
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
          ),*/
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
                  : GestureDetector(
                      onPanUpdate: (up) {
                        print("up");
                      },
                      onVerticalDragDown: (drag) {
                        if ((_scrollController.offset <= 0 && itemPositionsListener.itemPositions.value.first.index == 0)) {
                          setState(() {
                            _canScrollListRestaurant = false;
                          });
                        } else if (_scrollController.offset >= 245 && itemPositionsListener.itemPositions.value.first.index >= 0) {
                          setState(() {
                            _canScrollListRestaurant = true;
                          });
                        }
                      },
                      child: _renderMain()),
          // : _renderMainScreen(),
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
                                menu: Menu.fromJson(e.content,resto: widget.restaurant),
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

  Widget _renderMain() {
    return Scaffold(
      body: Stack(
        children: [
          NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverOverlapAbsorber(
                  sliver: SliverSafeArea(
                    top: false,
                    sliver: SliverAppBar(
                      backgroundColor: Colors.white,
                      expandedHeight: 340.0,
                      floating: false,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                          background: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 65,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20, right: 20, left: 20, bottom: 15),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.network(
                                  restaurant.imageURL,
                                  // width: 4 * MediaQuery.of(context).size.width / 7,
                                  width: MediaQuery.of(context).size.width / 3,
                                  height: MediaQuery.of(context).size.width / 3,
                                  fit: BoxFit.cover,
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      restaurant.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.mapMarkerAlt,
                                          size: 15,
                                          color: CRIMSON,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Container(
                                          width: (MediaQuery.of(context).size.width / 2)- 10,
                                          child: Text(
                                            restaurant.address,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.phoneAlt,
                                          size: 15,
                                          color: CRIMSON,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "Tel : ${restaurant.phoneNumber ?? "0"}",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black54),
                                        )
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          Divider(),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: CRIMSON,
                                ),
                                SizedBox(
                                  width: 25,
                                ),
                                Text(
                                  "De 09:00 à 20:00",
                                  style: TextStyle(fontSize: 18, color: CRIMSON, fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          )
                        ],
                      )),
                      bottom: TabBar(
                        controller: tabController,
                        isScrollable: true,
                        unselectedLabelColor: CRIMSON,
                        indicator: BoxDecoration(borderRadius: BorderRadius.circular(5), color: CRIMSON),
                        tabs: [
                          Tab(
                            text: AppLocalizations.of(context).translate('a_la_carte'),
                          ),
                          for (var foodType in restaurant.foodTypes)
                            Tab(
                              text: foodType["name"][Provider.of<SettingContext>(context).languageCode] ?? "",
                            ),
                          Tab(
                            text: AppLocalizations.of(context).translate('menus'),
                          ),
                         /* Tab(
                            text: AppLocalizations.of(context).translate('drinks'),
                          ),*/
                        ],
                      ),
                    ),
                  ),
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                ),
              ];
            },
            body: Column(
              children: [
                Expanded(
                  child: ScrollablePositionedList.separated(
                    itemScrollController: itemScrollController,
                    itemPositionsListener: itemPositionsListener,
                    itemCount: 2 + restaurant.foodTypes.length,
                    padding: const EdgeInsets.symmetric(horizontal: 0,vertical: 20),
                    physics: _canScrollListRestaurant ? AlwaysScrollableScrollPhysics() : NeverScrollableScrollPhysics(),
                    itemBuilder: (_, index) {
                      if (index == 0)
                        return Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            AppLocalizations.of(context).translate('a_la_carte'),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );

                      if (index == restaurant.foodTypes.length + 1)
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Text(
                                AppLocalizations.of(context).translate('menu'),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            _renderMenus(),
                          ],
                        );

                      /*if (index == 3 + restaurant.foodTypes.length - 1)
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Text(
                                AppLocalizations.of(context).translate('drinks'),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            _renderDrinks(),
                          ],
                        );*/

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Text(
                              restaurant.foodTypes[index - 1]["name"][Provider.of<SettingContext>(context).languageCode] ?? "",
                              style: TextStyle(
                                fontSize: 18,
                              ),
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
                ),
                Consumer<CartContext>(builder: (_, cartContext, __) {
                  if (cartContext.itemCount > 0) {
                    return OrderButton(
                      totalPrice: cartContext.totalPrice,
                    );
                  } else {
                    return SizedBox();
                  }
                })
              ],
            ),
          ),
          Positioned(
              child: Container(
            width: double.infinity,
            height: 80,
            child: AppBar(
              title: Text(restaurant.name),
              actions: [
                SizedBox(
                  width: 25,
                ),
                /*switchingFavorite
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: SizedBox(
                            height: 14,
                            child: FittedBox(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                        ),
                      )
                    : IconButton(
                        onPressed: _toggleFavorite,
                        icon: Icon(
                          isInFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.white,
                        ),
                      ),*/
              ],
            ),
          )),
        ],
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
                          restaurant: widget.restaurant,
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
