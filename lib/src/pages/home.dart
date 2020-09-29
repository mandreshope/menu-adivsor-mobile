import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/components/backgrounds.dart';
import 'package:menu_advisor/src/components/buttons.dart';
import 'package:menu_advisor/src/components/cards.dart';
import 'package:menu_advisor/src/components/logo.dart';
import 'package:menu_advisor/src/components/utilities.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/pages/discover.dart';
import 'package:menu_advisor/src/pages/search.dart';
import 'package:menu_advisor/src/providers/DataContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:provider/provider.dart';

const foodCategories = [
  {
    'image': 'assets/images/foodCategory-dietetic.svg',
    'name': 'Diétetiques',
  },
  {
    'image': 'assets/images/foodCategory-dietetic.svg',
    'name': 'Diétetiques',
  },
  {
    'image': 'assets/images/foodCategory-dietetic.svg',
    'name': 'Diétetiques',
  },
  {
    'image': 'assets/images/foodCategory-dietetic.svg',
    'name': 'Diétetiques',
  },
  {
    'image': 'assets/images/foodCategory-dietetic.svg',
    'name': 'Diétetiques',
  },
  {
    'image': 'assets/images/foodCategory-dietetic.svg',
    'name': 'Diétetiques',
  },
  {
    'image': 'assets/images/foodCategory-dietetic.svg',
    'name': 'Diétetiques',
  },
];

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldWithBottomMenu(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            RefreshIndicator(
              onRefresh: () async {
                DataContext dataContext =
                    Provider.of<DataContext>(context, listen: false);

                return dataContext.refresh();
              },
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _renderHeader(),
                    Transform.translate(
                      offset: Offset(
                        0,
                        -130,
                      ),
                      child: Column(
                        children: [
                          _renderCategories(),
                          _renderPopularFoods(),
                          _renderPopularRestaurants(),
                        ],
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

  Widget _renderHeader() {
    final size = MediaQuery.of(context).size;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.all(size.width / 20),
          child: MenuAdvisorLogo(
            size: size.width / 4,
          ),
        ),
        WaveBackground(
          size: Size(
            3 * size.width / 5,
            2 * size.height / 7,
          ),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MenuAdvisorTextLogo(
                      fontSize: size.width / 14,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    CircleButton(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(12),
                      child: FaIcon(
                        FontAwesomeIcons.search,
                        size: 20,
                        color: CRIMSON,
                      ),
                      onPressed: () {
                        RouteUtil.goTo(
                          context: context,
                          child: SearchPage(),
                          routeName: searchRoute,
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                RoundedButton(
                  backgroundColor: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ],
                  child: Text(
                    AppLocalizations.of(context).translate("discover"),
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontFamily: 'Soft Elegance',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  onPressed: () => RouteUtil.goTo(
                    context: context,
                    child: DiscoverPage(),
                    routeName: discoverRoute,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _renderCategories() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            AppLocalizations.of(context).translate("categories"),
          ),
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: 10,
            ),
            child: Row(
              children: [
                for (var category in foodCategories)
                  CategoryCard(
                    image: category['image'],
                    name: category['name'],
                    onPressed: () {},
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderPopularFoods() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 30,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(
                AppLocalizations.of(context).translate("populars"),
              ),
              Container(
                margin: const EdgeInsets.only(
                  right: 30,
                ),
                child: GestureDetector(
                  onTap: () {
                    RouteUtil.goTo(
                      context: context,
                      child: SearchPage(),
                      routeName: searchRoute,
                    );
                  },
                  child: Text(
                    AppLocalizations.of(context).translate("see_all"),
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
              ),
            ],
          ),
          Consumer<DataContext>(
            builder: (_, dataContext, __) {
              var foods = dataContext.popularFoods;
              var loading = dataContext.loadingPopularFoods;

              if (loading)
                return Container(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        CRIMSON,
                      ),
                    ),
                  ),
                );

              if (foods.length == 0)
                return Container(
                  height: 200,
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context).translate('no_food'),
                      style: TextStyle(
                        fontSize: 22,
                      ),
                    ),
                  ),
                );

              return SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: 10,
                ),
                child: Row(
                  children: [
                    for (var food in foods)
                      FoodCard(
                        food: food,
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _renderPopularRestaurants() {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(
                AppLocalizations.of(context).translate("popular_restaurants"),
              ),
              Container(
                margin: const EdgeInsets.only(
                  right: 30,
                ),
                child: GestureDetector(
                  onTap: () {
                    print("Populaires");
                  },
                  child: Text(
                    "Voir tout",
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
              ),
            ],
          ),
          Consumer<DataContext>(builder: (_, dataContext, __) {
            var restaurants = dataContext.popularRestaurants;
            var loading = dataContext.loadingNearestRestaurants;

            if (loading)
              return Container(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      CRIMSON,
                    ),
                  ),
                ),
              );

            if (restaurants.length == 0)
              return Container(
                height: 200,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context).translate('no_restaurant') ??
                          "Aucun restaurant trouvé",
                      style: TextStyle(
                        fontSize: 22,
                      ),
                    )
                  ],
                ),
              );

            return SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 10,
              ),
              child: Row(
                children: [
                  for (var restaurant in restaurants)
                    RestaurantCard(
                      restaurant: restaurant,
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
