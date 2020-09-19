import 'package:flutter/material.dart';
import 'package:menu_advisor/src/components/backgrounds.dart';
import 'package:menu_advisor/src/components/buttons.dart';
import 'package:menu_advisor/src/components/cards.dart';
import 'package:menu_advisor/src/components/logo.dart';
import 'package:menu_advisor/src/components/utilities.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/types.dart';

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
            SingleChildScrollView(
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
                        _renderPopulars(),
                        _renderNearestRestaurants(),
                      ],
                    ),
                  ),
                ],
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
                MenuAdvisorTextLogo(
                  fontSize: size.width / 10,
                  color: Colors.white,
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
                    "Découvrir",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontFamily: 'Soft Elegance',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  onPressed: () {},
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
          SectionTitle("Catégories"),
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
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

  Widget _renderPopulars() {
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
              SectionTitle("Populaires"),
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
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 10,
            ),
            child: Row(
              children: [
                for (var _ in foodCategories)
                  FoodCard(
                    food: Food(
                      location: Location(latitude: 40, longitude: 30),
                      name: 'Danze',
                      type: FoodType(type: 'Type danze'),
                      ratings: 4.5,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderNearestRestaurants() {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle("Restaurants d'à côté"),
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
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 10,
            ),
            child: Row(
              children: [
                for (var _ in foodCategories)
                  RestaurantCard(
                    restaurant: Restaurant(
                      name: "Restaurant danze",
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
