import 'package:flutter/material.dart';
import 'package:menu_advisor/src/components/cards.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> with SingleTickerProviderStateMixin {
  TabController controller;
  List<Restaurant> favoriteRestaurants = [];
  List<Food> favoriteFoods = [];

  bool loadingFavoriteRestaurants = true;
  bool loadingFavoriteFoods = true;

  Api api = Api.instance;

  @override
  void initState() {
    super.initState();

    controller = TabController(
      vsync: this,
      initialIndex: 0,
      length: 2,
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadDatas();
    });
  }

  loadDatas() async {
    AuthContext authContext = Provider.of<AuthContext>(
      context,
      listen: false,
    );

    SettingContext settingContext = Provider.of<SettingContext>(
      context,
      listen: false,
    );

    for (int i = 0; i < authContext.currentUser.favoriteFoods.length; i++) {
      var id = authContext.currentUser.favoriteFoods[i];
      var food = await api.getFood(
        id: id,
        lang: settingContext.languageCode,
      );
      favoriteFoods.add(food);
    }

    // if (mounted)
    setState(() {
      loadingFavoriteFoods = false;
    });

    for (int i = 0; i < authContext.currentUser.favoriteRestaurants.length; i++) {
      var id = authContext.currentUser.favoriteRestaurants[i];
      var restaurant = await api.getRestaurant(
        id: id,
        lang: settingContext.languageCode,
      );
      favoriteRestaurants.add(restaurant);
    }

    // if (mounted)
    setState(() {
      loadingFavoriteRestaurants = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: AppBarTheme(
          color: Colors.white,
          brightness: Brightness.light,
          centerTitle: false,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: TextTranslator(
            AppLocalizations.of(context).translate('favorites'),
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          bottom: TabBar(
            controller: controller,
            indicatorColor: CRIMSON,
            labelColor: Colors.black,
            tabs: [
              Tab(
                text: AppLocalizations.of(context).translate('restaurants'),
              ),
              Tab(
                text: AppLocalizations.of(context).translate('foods'),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: controller,
          physics: BouncingScrollPhysics(),
          children: [
            loadingFavoriteRestaurants
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(CRIMSON),
                    ),
                  )
                : favoriteRestaurants.length > 0
                    ? SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          children: favoriteRestaurants
                              .map(
                                (e) => Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 10,
                                  ),
                                  child: RestaurantCard(
                                    restaurant: e,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.warning,
                            size: 40,
                          ),
                          TextTranslator(
                            AppLocalizations.of(context).translate('no_favorite_restaurant'),
                            style: TextStyle(
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
            loadingFavoriteFoods
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(CRIMSON),
                    ),
                  )
                : favoriteFoods.length > 0
                    ? SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          children: favoriteFoods.map((e) {
                            e.isPopular = true;
                            return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 10,
                                ),
                                child: FoodCard(
                                  food: e,
                                  imageTag: e.id,
                                ));
                          }).toList(),
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.warning,
                            size: 40,
                          ),
                          TextTranslator(
                            AppLocalizations.of(context).translate('no_favorite_food'),
                            style: TextStyle(
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
          ],
        ),
      ),
    );
  }
}
