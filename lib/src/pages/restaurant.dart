import 'dart:async';

import 'package:flag/flag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:menu_advisor/src/components/buttons.dart';
import 'package:menu_advisor/src/components/cards.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/pages/list_lang.dart';
import 'package:menu_advisor/src/pages/map_polyline.dart';
import 'package:menu_advisor/src/pages/photo_view.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/providers/DataContext.dart';
import 'package:menu_advisor/src/providers/RestaurantContext.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/types.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/map_utils.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textFormFieldTranslator.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:segment_control/segment_control.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:menu_advisor/src/utils/extensions.dart';

class RestaurantPage extends StatefulWidget {
  final String restaurant;
  final bool withPrice;
  final bool fromQrcode;

  const RestaurantPage({
    Key key,
    this.restaurant,
    this.withPrice = true,
    this.fromQrcode = false
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
  String type = '';

  bool _isSearching = false;

  String _lang;
  List<Food> drinks = [];

  String foodType;

  Map<String, List<Food>> foods = Map();

  Restaurant restaurant;

  ItemScrollController itemScrollController = ItemScrollController();
  ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  ScrollController _scrollController = ScrollController();
  bool _canScrollListRestaurant = true;

  String _langTranslate;
  int range;
  List<FoodAttribute> attributeFilter;
  List<Menu> menus;

  Map<int, Widget> _segmentChilder;
  List<FoodTypeItem> _foodTypes = List();

  RestaurantContext _restaurantContext;
  AutoScrollController _autoScrollController;

  @override
  void initState() {
    super.initState();

    _autoScrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
        Rect.fromLTRB(0, 0, MediaQuery.of(context).padding.right, 0),
    axis: Axis.horizontal);
    
     _lang = Provider.of<SettingContext>(context, listen: false).languageCode;
    _langTranslate = Provider.of<SettingContext>(context, listen: false).languageCodeTranslate;
    Provider.of<SettingContext>(context,listen: false).isRestaurantPage = true;
    range = Provider.of<SettingContext>(context,listen: false).range;

    _restaurantContext = Provider.of<RestaurantContext>(context,listen: false);
    // attributeFilter = Provider.of<DataContext>(context,listen: false).attributes;
    attributeFilter = List();


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
        fromQrcode: widget.fromQrcode,
        filters: {
          'type': 'Boisson',
          'restaurant': restaurant.id,
        },
      );

      tabController = TabController(
        vsync: this,
        initialIndex: 0,
        length: 3 /*+ restaurant.foodTypes.length*/,
      );

      _segmentChilder = Map();

      _restaurantContext.init( restaurant.foodTypes);
      _foodTypes = _restaurantContext.foodTypes;

      tabController.addListener(() {
        print(tabController.index);
        // itemScrollController.jumpTo(index: tabController.index);
        if (tabController.index == 0){
          _canScrollListRestaurant = true;
        }else{
          _canScrollListRestaurant = false;
        }
        setState(() {

        });
      });

      itemPositionsListener.itemPositions.addListener(() async {
        print('Scroll position: ${itemPositionsListener.itemPositions.value.first.index}');
        if (tabController.index == 0){
          _restaurantContext.currentIndex = itemPositionsListener.itemPositions.value.first.index;
          _restaurantContext.setFoodTypeSelected(_restaurantContext.currentIndex);
          await _autoScrollController.scrollToIndex(_restaurantContext.currentIndex,preferPosition: AutoScrollPosition.begin);

        }

        // tabController.animateTo(itemPositionsListener.itemPositions.value.first.index);

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
      if (restaurant.foodTypes.length > 0) foodType = restaurant.foodTypes.first['name']['fr'];

      for (int i = 0; i < restaurant.foodTypes.length; i++) {
        var element = restaurant.foodTypes[i]['name']["fr"];
        foods[element] = await api.getFoods(
          Provider.of<SettingContext>(
            context,
            listen: false,
          ).languageCode,
          fromQrcode: widget.fromQrcode,
          filters: {
            'restaurant': widget.restaurant,
            'type': element,
          },
        );
      }
      foods.forEach((key, value) {
        value.forEach((element) {
          /*element.attributes?.forEach((att) async {
            element.foodAttributes.add(att);
          });*/
           element.foodAttributes = element.attributes;
        });
      });

      menus = await api.getMenus(
        _lang,
        restaurant.id,
      );

      /*await Future.forEach(menus, (element){
        return Future.forEach(element.foods, (element) => element = api.getFood(id: element.id,lang: "fr"));
      });*/

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
      searchResults = List();
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
        type: "food",
        range: 10000,
        filters: filters
      );
     /* if (type.isEmpty){
results = await api.search(
        searchValue,
        _lang,
        type: "food",
        range: 10000,
        filters: filters
      );
      }else{
results = await api.search(
        searchValue,
        _lang,
        type: "food",
        range: 10000,
        filters: {
          // 'restaurant': restaurant.id,
          'type':type ?? ""
        },
      );
      }*/
      
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
        Provider.of<SettingContext>(context,listen: false).isRestaurantPage = false;
        Provider.of<CartContext>(context,listen: false).withPrice = true;
        Provider.of<DataContext>(context,listen: false).resetAttributes();

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
                  title: TextTranslator(restaurant.name ?? "",),
                  
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
              foodType = restaurant.foodTypes[index]['name']["fr"];
            else
              foodType = 'all';
          });
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          child: TextTranslator(
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
                    child: TextTranslator(
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
                            child: TextTranslator(
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
                                withPrice: widget.withPrice,
                              ),
                            );
                          else if (e.type.toString() == 'SearchResultType.food')
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: 10,
                              ),
                              child: FoodCard(
                                food: Food.fromJson(e.content),
                                withPrice: widget.withPrice,
                              ),
                            );
                          else if (e.type.toString() == 'SearchResultType.menu')
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: 10,
                              ),
                              child: MenuCard(
                                lang: _lang,
                                withPrice: widget.withPrice,
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
                        barrierDismissible: false,
                        builder: (_) => SearchSettingDialog(
                          languageCode: Provider.of<SettingContext>(context).languageCode,
                          inRestaurant: true,
                          filters: filters,
                          type: type,
                          range: Provider.of<SettingContext>(context).range,
                        ),
                      );
                      if (filters is Map && filters.entries.length > 0) {
                        setState(() {
                          filters = result['filters'];
                          // filters.remove("restaurant");
                          
                          /*type = filters['foodTypes'];
                          range = result['range'];*/
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
                      expandedHeight: restaurant.description.isEmpty ? 400 : 470.0,
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
                                InkWell(
                                  child: Hero(
                                    tag: 'tag:${restaurant.imageURL}',
                                    child: Image.network(
                                      restaurant.imageURL,
                                      // width: 4 * MediaQuery.of(context).size.width / 7,
                                      width: MediaQuery.of(context).size.width / 3,
                                      height: MediaQuery.of(context).size.width / 3,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Center(
                          child: Icon(
                            Icons.fastfood,size: MediaQuery.of(context).size.width / 3,
                          ),
                        ),
                                    ),
                                  ),
                                  onTap: () {
                                    RouteUtil.goTo(context: context, child: PhotoViewPage(tag: 'tag:${restaurant.imageURL}', img: restaurant.imageURL,), routeName: null);
                                  },
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextTranslator(
                                      restaurant.name,
                                      
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    SizedBox(height:5),
                                    _renderCategorie(),
                                    
                                   
                                    SizedBox(height: 5,),
                                     Row(
                                       children: [
                                       /*  Icon(FontAwesomeIcons.mapPin,size: 15,
                                          color: CRIMSON,),
                                           SizedBox(
                                          width: 5,
                                        ),*/
                                         TextTranslator(
                                          "Distance : ${Provider.of<SettingContext>(context).distanceBetweenString(restaurant.location.coordinates.last,restaurant.location.coordinates.first)}",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold
                                          ),
                                    ),
                                       ],
                                     ),
                                    SizedBox(height:5),
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
                                        InkWell(
                                            onTap: () async {
                                              Position currentPosition = await getCurrentPosition();
                                              // Position currentPosition = Provider.of<SettingContext>(context).position;
                                              var coordinates = restaurant.location.coordinates;
                                              // MapUtils.openMap(currentPosition.latitude, currentPosition.longitude,
                                              // coordinates.last,coordinates.first);
                                              RouteUtil.goTo(
                                                context: context,
                                                child: MapPolylinePage(
                                                  restaurant: restaurant,
                                                  initialPosition: LatLng(currentPosition.latitude, currentPosition.longitude),
                                                  destinationPosition: LatLng(coordinates.last, coordinates.first),
                                                ),

                                                routeName: restaurantRoute,
                                              );
                                            },
                                            child: Container(
                                            width: (MediaQuery.of(context).size.width / 2)- 10,
                                            child: TextTranslator(
                                              restaurant.address,
                                              
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blue,
                                                fontSize: 18,
                                                decoration: TextDecoration.underline
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    
                                    
                                    SizedBox(height: 5,),
                                    InkWell(
                                      child: Row(
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
                                          TextTranslator(
                                            "${restaurant.phoneNumber ?? "0"}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue,
                                              decoration: TextDecoration.underline,),
                                            
                                          )
                                        ],
                                      ),
                                      onTap: () async {
                                        if (restaurant.phoneNumber != null)
                                          await launch(
                                              "tel:${restaurant.phoneNumber}");
                                      },
                                    ),
                                    SizedBox(height: 15,),
                                    Row(
                                      children: [
                                        //bouton itineraire
                                        Visibility(
                                            visible: false,
                                            child: Container(
                                            margin: EdgeInsets.only(left: 25),
                                            child: InkWell(
                                              onTap: () async {
                                                Position currentPosition = await getCurrentPosition();;
                                                var coordinates = restaurant.location.coordinates;
                                                MapUtils.openMap(currentPosition.latitude, currentPosition.longitude,
                                                coordinates.last,coordinates.first);
                                              },
                                              child: Container(
                                                    padding: EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.horizontal(left: Radius.circular(15), right: Radius.circular(15)),
                                                      color: Colors.orange,
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(2.0),
                                                      child: TextTranslator(
                                                        "Itinéraire",
                                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                                                      ),
                                                    ),
                                                  )
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 20,),
                                        CircleAvatar(
                                          backgroundColor: Colors.orange,
                                          radius: 15,
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.search,
                                              color: Colors.white,
                                              size: 15,), 
                                              onPressed: (){
                                                setState(() {
                                                  _isSearching = true;
                                                });
                                              })),
                                              SizedBox(width: 10,),
                                              Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: restaurant.isOpen ? TEAL : CRIMSON,
                                                  borderRadius: BorderRadius.circular(25)
                                                ),
                                                child: Text(restaurant.isOpen ? "Ouvert" : "Fermé",
                                                style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600,)),
                                              )
                                      ],

                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  TextTranslator("Livraison",
                                  style: TextStyle(
                                    fontSize: 16
                                  ),),
                                  SizedBox(width: 5,),
                                  Icon(restaurant.delivery ? Icons.check_circle_outline_outlined : Icons.close, color: restaurant.delivery ? TEAL : CRIMSON)
                                ],
                              ),
                              SizedBox(width: 15,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  TextTranslator("Sur place",
                                  style: TextStyle(
                                    fontSize: 16
                                  ),),
                                  SizedBox(width: 5,),
                                  Icon(restaurant.surPlace ? Icons.check_circle_outline_outlined : Icons.close, color: restaurant.surPlace ? TEAL : CRIMSON)
                                ],
                              ),
                              SizedBox(width: 15,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  TextTranslator("A emporter",
                                  style: TextStyle(
                                    fontSize: 16
                                  ),),
                                  SizedBox(width: 5,),
                                  Icon(restaurant.aEmporter ? Icons.check_circle_outline_outlined : Icons.close, color: restaurant.aEmporter ? TEAL : CRIMSON)
                                ],
                              ),
                            ],
                          ),
                          Divider(),
                          Container(
                            padding: EdgeInsets.only(left: 25),
                            height: restaurant.description.isEmpty ? 20 : 30,
                            width: double.infinity,
                            child: TextTranslator(
                              restaurant.description.isEmpty ? "" : restaurant.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          restaurant.description.isNotEmpty ? Divider() : Container(),
                          InkWell(
                            onTap: (){
                              showDialog(context: context,
                                builder: (_){
                                  return SheduleDialog(openingTimes: restaurant.openingTimes,);
                                }
                              );
                            },
                              child: Container(
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
                                  TextTranslator(
                                    "Horaire",
                                    style: TextStyle(fontSize: 18, color: CRIMSON, fontWeight: FontWeight.w600),
                                    
                                  ),
                                  Spacer(),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: CRIMSON,
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          )
                        ],
                      )),
                      bottom: PreferredSize(
                        child: Stack(
                          children: [
                            Container(
                              width:double.infinity,
                              child: Center(
                                child: TabBar(
                                  controller: tabController,
                                  isScrollable: true,
                                  unselectedLabelColor: CRIMSON,
                                  indicator: BoxDecoration(borderRadius: BorderRadius.circular(5), color: CRIMSON),
                                  tabs: [
                                   // Text("TEst"),
                                    FutureBuilder(
                                      future:
                                        AppLocalizations.of(context).translate('a_la_carte').translator(_langTranslate),
                                      builder: (_,data){
                                      return Tab(
                                        text: data.data ?? "",
                                      );
                                    }),

                                    /*for (var foodType in restaurant.foodTypes)
                                      FutureBuilder<String>(
                                      future:
                                        "${foodType["name"]['fr'] ?? ""}".translator(_langTranslate),
                                      builder: (_,data){
                                        return Tab(
                                        text: data.data ?? "",
                                      );
                                      }),*/
                                      FutureBuilder<String>(
                                      future:
                                        AppLocalizations.of(context).translate('menus').translator(_langTranslate),
                                      builder: (_,data){
                                        return Tab(
                                        text: data.data ?? "",
                                      );
                                      }),

                                    FutureBuilder<String>(
                                      future:
                                        AppLocalizations.of(context).translate('menus').translator(_langTranslate),
                                      builder: (_,data){
                                        return Tab(
                                          text: AppLocalizations.of(context).translate('drinks'),
                                      );
                                      }),

                                  ],
                                ),
                              ),
                            ),
                            Align(
                              child: InkWell(
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: CRIMSON,
                                    shape: BoxShape.circle
                                  ),
                                  padding: EdgeInsets.all(5),
                                  child: Center(
                                    child:  Icon(Icons.filter_alt_outlined,color:Colors.white,),
                                  ),
                                  height: 40,
                                  width: 40,
                                  margin: EdgeInsets.only(right: 15),
                                ),
                                onTap: () async {
                                  var result = await showDialog<List<FoodAttribute>>(context: context,
                                      builder: (_){
                                        return AtributesDialog();
                                      });
                                    if (result != null)
                                      attributeFilter = result;
                                  setState(() {

                                  });

                                },
                              ),
                              alignment: Alignment.centerRight,

                            )
                          ],
                        ),
                        preferredSize: Size(MediaQuery.of(context).size.width, 50),
                      ),
                    ),
                  ),
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                ),
              ];
            },
            body: Stack(
              children: [
                Column(
                  children: [
                    // SizedBox(height: 15,),
                    if (tabController.index == 0)
                      SizedBox(height: 75,),
                    Expanded(
                      child: ScrollablePositionedList.separated(
                        itemScrollController: itemScrollController,
                        itemPositionsListener: itemPositionsListener,
                        itemCount: tabController.index == 0 ? restaurant.foodTypes.length : 2,
                        padding: const EdgeInsets.symmetric(horizontal: 0,vertical: 20),
                        physics: _canScrollListRestaurant ? AlwaysScrollableScrollPhysics() : NeverScrollableScrollPhysics(),
                        itemBuilder: (_, index) {

                          if (tabController.index != 0){
                            if (index == 0){
                              return Container();
                            }

                            if (tabController.index == 1)
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15),
                                    child: TextTranslator(
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
                                  SizedBox(
                                    height: 50,
                                  ),
                                ],
                              );
                            /*if (index == 3 + restaurant.foodTypes.length - 1)*/
                            if (tabController.index == 2)
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15),
                                    child: TextTranslator(
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
                              );

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: TextTranslator(
                                    restaurant.foodTypes[index - 1]["name"]["fr"] ?? "",
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),

                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                _renderFoodListOfType(restaurant.foodTypes[index]['name']["fr"]),
                              ],
                            );

                          }else{
                            if (index == 0){
                              if (restaurant.foodTypes[index]['name']["fr"] != "Boisson")
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 15),
                                      child: TextTranslator(
                                        AppLocalizations.of(context).translate('a_la_carte'),
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),

                                      ),
                                    ),
                                    Divider(),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 15),
                                      child: TextTranslator(
                                        restaurant.foodTypes[index]["name"][Provider.of<SettingContext>(context).languageCode] ?? "",
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),

                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    _renderFoodListOfType(restaurant.foodTypes[index]['name']["fr"]),
                                  ],
                                );
                            }
                            if (restaurant.foodTypes[index]['name']["fr"] != "Boisson")
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: TextTranslator(
                                    restaurant.foodTypes[index]["name"][Provider.of<SettingContext>(context).languageCode] ?? "",
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),

                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                _renderFoodListOfType(restaurant.foodTypes[index]['name']["fr"]),
                              ],
                            );
                            return Container();
                          }

                        },
                        separatorBuilder: (_, index) => Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          child: restaurant.foodTypes[index]['name']["fr"] != "Boisson" ? Container() : Divider(),
                        ),
                      ),
                    ),
                    Consumer<CartContext>(builder: (_, cartContext, __) {
                      if (cartContext.itemCount > 0) {
                        return OrderButton(
                          totalPrice: cartContext.totalPrice,
                          withPrice: widget.withPrice,
                        );
                      } else {
                        return SizedBox();
                      }
                    })
                  ],
                ),

                if (tabController.index == 0)
                  _renderFoodType()

              ],
            ),
          ),
          Positioned(
              child: Container(
            width: double.infinity,
            height: 80,
            child: AppBar(
              title: TextTranslator(restaurant.name,),
              actions: [

                InkWell(
                    onTap: (){
                      RouteUtil.goTo(context: context, child: ListLang(), routeName: "null");
                    },
                    child: Consumer<SettingContext>(
                      builder: (context, snapshot,w) {
                        return Flag(snapshot?.languageCodeFlag ?? 'fr',height: 30,width: 30,);
                      }
                    )),

                !showFavoriteButton ? Container(width: 0,height: 0,) :
                switchingFavorite
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
                      ),
                IconButton(icon: Icon(FontAwesomeIcons.share,color: Colors.white,),
                    onPressed: (){
                      Share.share("https://menuadvisor.fr/restaurants/${restaurant.id}");
                    }),
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
              // .where((element) {
              //   return attributeFilter.any((filter) =>
              //   filter.sId == element.attributes.firstWhere((att) =>
              //   att.sId == filter.sId,orElse: ()=> FoodAttribute(sId: "-1")).sId);
              // })
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
              TextTranslator(
                AppLocalizations.of(context).translate('no_drink'),
                
                style: TextStyle(
                  fontSize: 22,
                ),
              ),
            ],
          );
  }

  Widget _renderMenus() {
    /*return FutureBuilder<List<Menu>>(
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

        var menus = snapshot.data;*/
        return menus.length > 0
            ? SingleChildScrollView(
                child: Column(
                  children: menus
                      .map(
                        (e) => Container(
                          margin: EdgeInsets.only(bottom: 25),
                          child: MenuCard(
                            menu: e,
                            lang: _lang,
                            restaurant: widget.restaurant,
                            withPrice: widget.withPrice,
                          ),
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
                  TextTranslator(
                    AppLocalizations.of(context).translate('no_menu'),
                    
                    style: TextStyle(
                      fontSize: 22,
                    ),
                  ),
                ],
              );
    //   },
    // );
  }

  Widget _renderFoodListOfType(String foodType) {
    return foods[foodType].length > 0
        ? Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            child: Column(
              children: foods[foodType]
              .where((element) {
                return !attributeFilter.any((filter){ 
                  if (filter.tag.contains("allergen") )
                    return filter.sId == element.attributes.firstWhere((att) =>
                   att.sId == filter.sId,orElse: ()=> FoodAttribute(sId: "-1")).sId;
                  else 
                    return !(filter.sId == element.attributes.firstWhere((att) =>
                   att.sId == filter.sId,orElse: ()=> FoodAttribute(sId: "-1")).sId);});
              })
                  .map(
                    (food) => RestaurantFoodCard(
                      food: food,
                      withPrice: widget.withPrice,
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
              TextTranslator(
                AppLocalizations.of(context).translate('no_food'),
                style: TextStyle(
                  fontSize: 22,
                ),
              ),
              SizedBox(height: 800,)
            ],
          );
  }

  Widget _renderFoodType() {
    return Consumer<RestaurantContext>(
      builder: (_,restaurantContext,w){
        return Padding(

          padding: EdgeInsets.symmetric(horizontal: 25,vertical: 5),
          child: /*_segmentChilder.length < 2 ?
          Container(
            // width: 350,
            height: 45,
            // padding: EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
              color: CRIMSON
            ),
            // padding: EdgeInsets.only(left: 12, right: 12),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: TextTranslator(restaurant.foodTypes.first['name']['fr'],style:TextStyle(
                    color: Colors.white,
                  fontWeight: FontWeight.bold
                )),
              ),
            ),
          )
              : SegmentControl(
            tabs: _foodTypes,
            // width: 300,
            selected: (_i, _s) {
              restaurantContext.currentIndex = _i;
              itemScrollController.jumpTo(index: _i);
            },
            radius: 5,
            normalBackgroundColor: Color(0xffEDEDED),
            activeBackgroundColor: CRIMSON,
            borderColor: CRIMSON,
            normalTitleStyle: TextStyle(fontSize: 14, color: CRIMSON,fontWeight: FontWeight.bold),
            activeTitleStyle: TextStyle(fontSize: 16, color: Colors.white,fontWeight: FontWeight.bold),
            height: 45,
          )*/
          Consumer<RestaurantContext>(
            builder: (context, snapshot,w) {
              return Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: 50,
                  // width: 500,
                  child: ListView.builder(
                      itemCount: _foodTypes.length,
                      scrollDirection: Axis.horizontal,
                      controller: _autoScrollController,
                      shrinkWrap: true,
                      itemBuilder: (_, position){
                        return  AutoScrollTag(
                            controller: _autoScrollController,
                            key:ValueKey(position),
                            index: position,
                            child: Center(child: _segmentWidget(position)));
                  }),
                ),
              );
            }
          )
        );
      },
    );

  }

  Widget _segmentWidget(int position) {
    FoodTypeItem foodTypeItem = _restaurantContext.foodTypes[position];
    return InkWell(
        onTap: () {
          itemScrollController.jumpTo(index: position);
          _restaurantContext.setFoodTypeSelected(position);
        },
        child: Container(
            width: 150,
            height: 45,
            // padding: EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: foodTypeItem.isSelected ? CRIMSON : Colors.white),
            // padding: EdgeInsets.only(left: 12, right: 12),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: TextTranslator(foodTypeItem.name,
                    style: TextStyle(
                        color:
                            !foodTypeItem.isSelected ? CRIMSON : Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            )));
  }

  Widget _renderCategorie(){
    String name = "";
    for (var type in _foodTypes)
      name += type.name + ", ";
      return TextTranslator(
        name.isEmpty ? name : name.substring(0,name.length-2),
        style: TextStyle(
            fontWeight: FontWeight.bold,
          fontSize: 16
        ),
      );
  }
}

