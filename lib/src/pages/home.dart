import 'dart:async';

import 'package:floatingpanel/floatingpanel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:menu_advisor/src/animations/FadeAnimation.dart';
import 'package:menu_advisor/src/components/backgrounds.dart';
import 'package:menu_advisor/src/components/buttons.dart';
import 'package:menu_advisor/src/components/cards.dart';
import 'package:menu_advisor/src/components/logo.dart';
import 'package:menu_advisor/src/components/utilities.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/pages/discover.dart';
import 'package:menu_advisor/src/pages/order.dart';
import 'package:menu_advisor/src/pages/search.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/providers/DataContext.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/services/stripe.dart';
import 'package:menu_advisor/src/types.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool backButtonAlreadyPressed = false;
  bool loading = true;
  bool geolocationDenied = false;
  Location currentLocation;
  String city;

  @override
  void initState() {
    super.initState();

    StripeService.init();

    checkPermission().then((LocationPermission permission) async {
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          geolocationDenied = true;
          loading = false;
        });
      } else if (permission == LocationPermission.denied) {
        await requestPermission();
        Position currentPosition = await getCurrentPosition();
        setState(() {
          currentLocation = Location(
            type: "Point",
            coordinates: [currentPosition.longitude, currentPosition.latitude],
          );
          loading = false;
        });
        String lang = Provider.of<SettingContext>(
          context,
          listen: false,
        ).languageCode;
        await Provider.of<DataContext>(context,listen: false).setCity(currentPosition.latitude, currentPosition.longitude);
        Provider.of<DataContext>(
          context,
          listen: false,
        ).refresh(
          lang,
          currentLocation,
        );
        this.city = Provider.of<DataContext>(context,listen: false).getCity();
      } else {
        Position currentPosition = await getCurrentPosition();
        setState(() {
          currentLocation = Location(
            type: "Point",
            coordinates: [currentPosition.longitude, currentPosition.latitude],
          );
          loading = false;
        });
        String lang = Provider.of<SettingContext>(
          context,
          listen: false,
        ).languageCode;

        await Provider.of<DataContext>(context,listen: false).setCity(currentPosition.latitude, currentPosition.longitude);
        Provider.of<DataContext>(context, listen: false).refresh(
          lang,
          currentLocation,
        );
        this.city = Provider.of<DataContext>(context,listen: false).getCity();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(CRIMSON),
              ),
            ),
          )
        : geolocationDenied
            ? Scaffold(
                body: Center(
                  child: TextTranslator(
                    AppLocalizations.of(context).translate('geolocation_denied'),
                  ),
                ),
              )
            : WillPopScope(
                onWillPop: () async {
                  if (!backButtonAlreadyPressed) {
                    backButtonAlreadyPressed = true;
                    Timer(
                      Duration(
                        seconds: 1,
                      ),
                      () {
                        backButtonAlreadyPressed = false;
                      },
                    );
                    Fluttertoast.showToast(
                      msg: AppLocalizations.of(context).translate('before_exit_message'),
                    );
                    return false;
                  }
                  return true;
                },
                child: ScaffoldWithBottomMenu(
                  body: SafeArea(
                    child: FadeAnimation(
                      0.3,
                      Stack(
                        fit: StackFit.expand,
                        children: [
                          Positioned(
                            top: MediaQuery.of(context).size.height / 2 - 60,
                            left: 0,
                            child: SvgPicture.asset(
                              'assets/images/wave-background-yellow.svg',
                              width: 250,
                            ),
                          ),
                          RefreshIndicator(
                            onRefresh: () async {
                              try {
                                DataContext dataContext = Provider.of<DataContext>(
                                  context,
                                  listen: false,
                                );

                                Position position = await getCurrentPosition();

                                Location location = Location(
                                  type: 'Point',
                                  coordinates: [position.longitude, position.latitude],
                                );

                                return dataContext.refresh(
                                  Provider.of<SettingContext>(
                                    context,
                                    listen: false,
                                  ).languageCode,
                                  location,
                                );
                              } catch (error) {
                                print(error);
                                Fluttertoast.showToast(
                                  msg: AppLocalizations.of(context).translate('gelocation_issue'),
                                );
                              }
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
                                        _renderFoodCategories(),
                                        _renderNearestRestaurants(),

                                        _renderPopularFoods(),
                                        _renderOnSiteFoods(),
                                        _renderBlog()
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Consumer<CartContext>(
                            builder: (_,cart,w){

                              return cart.items.length == 0 ? Container() : Positioned(
                                bottom: 20,
                                right: 20,
                                child: Stack(
                                  children: [
                                    FloatingActionButton(
                                      onPressed: (){
                                        RouteUtil.goTo(
                                          context: context,
                                          child: OrderPage(
                                            withPrice: cart.withPrice,
                                          ),
                                          routeName: orderRoute,
                                        );

                                      },
                                      child: FaIcon(
                                        Icons.shopping_cart_outlined,
                                        color: Colors.white,
                                      ),
                                      backgroundColor: TEAL,
                                      heroTag: "floating",
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                          padding: EdgeInsets.only(bottom: 5),
                                          decoration: BoxDecoration(
                                            color: CRIMSON,
                                            borderRadius: BorderRadius.circular(12.5)
                                          ),
                                          child: Center(
                                            child: Text("${cart.items.length}",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold
                                              ),
                                            )
                                            ,
                                          ),
                                      width: 25,
                                        height: 25,
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                          )

                        ],
                      ),
                    ),
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
                          child: SearchPage(
                            location: {
                              "coordinates":currentLocation?.coordinates ?? [0,0]
                            },
                            filters: {
                              // "city":this.city ?? ""
                              // 'nearest': 'nearest'
                            },
                          ),
                          routeName: searchRoute,
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                /*InkWell(
                  onTap: (){

                  },
                  child: Stack(
                    children: [
                      Icon(Icons.shopping_cart_outlined)
                    ],
                  ),
                ),*/
                /*
                RoundedButton(
                    backgroundColor: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                        spreadRadius: 0,
                      ),
                    ],
                    child: TextTranslator(
                        AppLocalizations.of(context).translate("discover"),
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontFamily: 'Soft Elegance',
                          fontWeight: FontWeight.w800,
                        ),
                      
                    ),
                    onPressed: () =>
                        /*RouteUtil.goTo(
                    context: context,
                    child: DiscoverPage(),
                    routeName: discoverRoute,
                  ),*/
                        RouteUtil.goTo(
                          context: context,
                          child: SearchPage(
                            barTitle: 'Découvrir',
                            type: 'food',
                            location: {
                              "coordinates":currentLocation?.coordinates ?? [0,0]
                            },
                            filters: {
                              // 'category': category.id,
                              "searchCategory": "with_price",
                              // "city": this.city ?? ""
                            },
                            showButton: true,
                          ),
                          routeName: searchRoute,
                        )),
             */
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _renderFoodCategories() {
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
          Consumer<DataContext>(builder: (_, dataContext, __) {
            var foodCategories = dataContext.foodCategories;
            var loading = dataContext.loadingFoodCategories;

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

            if (foodCategories.length == 0)
              return Container(
                height: 200,
                child: Center(
                  child: TextTranslator(
                    AppLocalizations.of(context).translate('no_food_category'),
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
                left: 10,
                right: 10,
                bottom: 10,
              ),
              child: Row(
                children: [
                  for (var category in foodCategories)
                    FadeAnimation(
                      1,
                      CategoryCard(
                        imageURL: category.imageURL,
                        name: category.name[Provider.of<SettingContext>(context).languageCode],
                        onPressed: () {
                          RouteUtil.goTo(
                            context: context,
                            child: SearchPage(
                              type: 'food',
                              location: {
                                "coordinates":currentLocation?.coordinates ?? [0,0]
                              },
                              filters: {
                                "category": category.id,
                                // "city":this.city ?? ""
                                // 'nearest': 'nearest'
                              },
                              showButton: true,
                            ),
                            routeName: searchRoute,
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _renderPopularFoods() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 40,
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
                "Plat populaires",
              ),
              /*Container(
                margin: const EdgeInsets.only(
                  right: 30,
                ),
                child: GestureDetector(
                  onTap: () {
                    RouteUtil.goTo(
                      context: context,
                      child: SearchPage(
                        type: 'food',
                        location: {
                           "coordinates":currentLocation?.coordinates ?? [0,0]
                        },
                        filters: {'searchCategory': 'with_price',
                        // "city":this.city ?? ""
                        // 'nearest': 'nearest'
                        },
                      ),
                      routeName: searchRoute,
                    );
                  },
                  child: TextTranslator(
                    AppLocalizations.of(context).translate("see_all"),
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
              ),*/
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
                    child: TextTranslator(
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
                    for (Food food in foods)
                      if (food.price?.amount == null)
                        SizedBox()
                      else
                        FadeAnimation(
                          1,
                          FoodCard(
                            food: food,
                            minified: true,
                          ),
                        )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _renderNearestRestaurants() {
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 40,
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(
                "Nouveau restaurant",
              ),
              Container(
                margin: const EdgeInsets.only(
                  right: 30,
                ),
                child: GestureDetector(
                  onTap: () {
                    RouteUtil.goTo(
                      context: context,
                      child: SearchPage(
                        type: 'restaurant',
                        location: {
                           "coordinates":currentLocation?.coordinates ?? [0,0]
                        },
                        filters: {
                          // 'city':this.city ?? ""
                          // 'nearest': 'nearest'
                        },
                      ),
                      routeName: searchRoute,
                    );
                  },
                  child: TextTranslator(
                    AppLocalizations.of(context).translate('see_all'),
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
              ),
            ],
          ),
          Consumer<DataContext>(builder: (_, dataContext, __) {
            var restaurants = dataContext.nearestRestaurants;
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
                    TextTranslator(
                      AppLocalizations.of(context).translate('no_restaurant_near') ?? "Aucun restaurant trouvé",
                      style: TextStyle(
                        fontSize: 22,
                      ),
                    ),
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
                    FadeAnimation(
                      1.0,
                      RestaurantCard(
                        restaurant: restaurant,
                        fromHome: true,
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _renderOnSiteFoods() {
    return Visibility(
      visible: false,
          child: Container(
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
                  AppLocalizations.of(context).translate("on_site_foods"),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    right: 30,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      RouteUtil.goTo(
                        context: context,
                        child: SearchPage(
                          type: 'food',
                          location: {
                             "coordinates":currentLocation?.coordinates ?? [0,0]
                          },
                          filters: {
                            // "searchCategory": "with_price",
                            // "price.amount":null,
                            "searchCategory": "onsite"
                            // "city":this.city ?? ""
                          },
                        ),
                        routeName: searchRoute,
                      );
                    },
                    child: TextTranslator(
                      AppLocalizations.of(context).translate("see_all"),
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                ),
              ],
            ),
            Consumer<DataContext>(
              builder: (_, dataContext, __) {
                var foods = dataContext.onSiteFoods;
                var loading = dataContext.loadingOnSiteFoods;

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
                      child: TextTranslator(
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
                        FadeAnimation(
                          1,
                          FoodCard(
                            food: food,
                            imageTag: 'onSitefoodImage${food.id}',
                            showButton: false,
                            minified: true,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _renderBlog() {
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
                  "Blog",
                ),
                Visibility(
                  visible: false,
                  child: Container(
                    margin: const EdgeInsets.only(
                      right: 30,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        RouteUtil.goTo(
                          context: context,
                          child: SearchPage(
                            type: 'food',
                            location: {
                              "coordinates":currentLocation?.coordinates ?? [0,0]
                            },
                            filters: {
                              // "searchCategory": "with_price",
                              // "price.amount":null,
                              "searchCategory": "onsite"
                              // "city":this.city ?? ""
                            },
                          ),
                          routeName: searchRoute,
                        );
                      },
                      child: TextTranslator(
                        AppLocalizations.of(context).translate("see_all"),
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Consumer<DataContext>(
              builder: (_, dataContext, __) {
                var blogs = dataContext.blogs;
                var loading = dataContext.loadingBlog;

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

                if (blogs.length == 0)
                  return Container(
                    height: 200,
                    child: Center(
                      child: TextTranslator(
                        "Acune Blog trouvée",
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
                  child: Column(
                    children: [
                      for (var blog in blogs)
                        FadeAnimation(
                          1,
                          BlogCard(
                            blog
                          )
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
  }

