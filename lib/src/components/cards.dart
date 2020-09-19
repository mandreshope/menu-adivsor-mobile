import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models.dart';

class CategoryCard extends StatelessWidget {
  final String image;

  final String name;

  final void Function() onPressed;

  const CategoryCard({
    Key key,
    @required this.image,
    @required this.name,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: EdgeInsets.symmetric(horizontal: 3),
      child: AspectRatio(
        aspectRatio: 3 / 5,
        child: Card(
          elevation: 4.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: TITLE_COLOR,
                      width: 2,
                    ),
                  ),
                  child: SvgPicture.asset(
                    image,
                    height: 40,
                    color: TITLE_COLOR,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  name,
                  style: TextStyle(
                    color: TITLE_COLOR,
                    fontFamily: 'Golden Ranger',
                    fontSize: 18,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: TITLE_COLOR,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_right,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FoodCard extends StatelessWidget {
  final Food food;

  const FoodCard({
    Key key,
    @required this.food,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      child: AspectRatio(
        aspectRatio: 1.7,
        child: Card(
          elevation: 4.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantCard({
    Key key,
    @required this.restaurant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      child: AspectRatio(
        aspectRatio: 1.7,
        child: Card(
          elevation: 4.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
