import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
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

class _RestaurantPageState extends State<RestaurantPage> {
  bool isInFavorite = false;

  @override
  void initState() {
    super.initState();

    AuthContext authContext = Provider.of<AuthContext>(context, listen: false);
    if (authContext.currentUser.favoriteRestaurants
            .indexWhere((element) => element.id == widget.restaurant.id) >
        1) isInFavorite = true;
  }

  _toggleFavorite() {
    Fluttertoast.showToast(
      msg: AppLocalizations.of(context).translate(
        !isInFavorite ? 'added_to_favorite' : 'removed_from_favorite',
      ),
    );
    setState(() {
      isInFavorite = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  actions: [
                    IconButton(
                      onPressed: _toggleFavorite,
                      icon: Icon(
                        isInFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.white,
                      ),
                    )
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Image.network(
                      widget.restaurant.imageURL,
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      widget.restaurant.name,
                    ),
                  ),
                ),
                SliverFillRemaining(
                  fillOverscroll: true,
                  child: Column(
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
                                      .translate('our_menus'),
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
