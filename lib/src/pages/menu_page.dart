import 'package:flutter/material.dart';
import 'package:menu_advisor/src/components/cards.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/providers/MenuContext.dart';
import 'package:menu_advisor/src/types.dart';
import 'package:provider/provider.dart';

class MenuPage extends StatefulWidget {
   MenuPage({Key key, this.menu}) : super(key: key);
   Menu menu;

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  MenuContext _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller = Provider.of<MenuContext>(context, listen: false);

    widget.menu = me;

    _controller.menu = widget.menu;
    _controller.foodsGrouped = widget.menu.foods;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Menu"),
      ),
      body: SingleChildScrollView(child: MenuCard(menu: me, lang: "name"))
    );
  }

  Widget _bodyHead() => Container(
        width: double.infinity,
        height: 150,
        child: Stack(
          children: [
            // menu : image
            Positioned(top: 10, left: 15, 
            child: Hero(tag: _controller.menu.imageURL, child: 
            Image.network(_controller.menu.imageURL, width: 50, height: 50, fit: BoxFit.cover))),

            // menu : name, description
            Positioned(
                top: 10,
                left: 30,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("menu.name"),
                    Text("menu.description"),
                  ],
                )),
          ],
        ),
      );

  Widget _bodyHeadContent() => Expanded(
          child: SingleChildScrollView(
        child: Column(
          children: [for (var entry in _controller.foodsGrouped.entries) _itemContent(title: entry.key, foods: entry.value)],
        ),
      ));

  Widget _itemContent({String title, List<Food> foods}) => Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(title),
          Divider(),
          for (var food in foods)
            Card(
              elevation: 2,
              child: Container(
                margin: EdgeInsets.all(15),
                child: Center(
                  child: Text(food.name),
                ),
              ),
            )
        ],
      );
}

Menu me = Menu(
    name: {'name': "mon menu"},
    description: {'name': "menu description"},
    imageURL: "https://assets.lightspeedhq.fr/img/2019/04/45199c86-6291056e-c205d230-ultimate-guide-to-menu-design-1024x536.jpg",
    foods: [
      Food(
          id: "id1",
          name: "food 1",
          category: FoodCategory(
            id: "food cat1",
            name: {'name': "mon menu"},
            imageURL: "null",
          ),
          restaurant: null,
          price: Price(amount: 12, currency: "€"),
          type: FoodType(tag: 'starter')),
      Food(
          id: "id1",
          name: "food 1",
          category: FoodCategory(
            id: "food cat1",
            name: {'name': "mon menu"},
            imageURL: "null",
          ),
          restaurant: null,
          price: Price(amount: 12, currency: "€"),
          type: FoodType(tag: 'starter')),
      Food(
          id: "id1",
          name: "food 1",
          category: FoodCategory(
            id: "food cat1",
            name: {'name': "mon menu"},
            imageURL: "null",
          ),
          restaurant: null,
          price: Price(amount: 12, currency: "€"),
          type: FoodType(tag: 'xp')),
      Food(
          id: "id1",
          name: "food 1",
          category: FoodCategory(
            id: "food cat1",
            name: {'name': "mon menu"},
            imageURL: "null",
          ),
          restaurant: null,
          price: Price(amount: 12, currency: "€"),
          type: FoodType(tag: 'xp')),
      Food(
          id: "id1",
          name: "food 1",
          category: FoodCategory(
            id: "food cat1",
            name: {'name': "mon menu"},
            imageURL: "null",
          ),
          restaurant: null,
          price: Price(amount: 12, currency: "€"),
          type: FoodType(tag: 'abc')),
      Food(
          id: "id1",
          name: "food 1",
          category: FoodCategory(
            id: "food cat1",
            name: {'name': "mon menu"},
            imageURL: "null",
          ),
          restaurant: null,
          price: Price(amount: 12, currency: "€"),
          type: FoodType(tag: 'abc')),
      Food(
          id: "id1",
          name: "food 1",
          category: FoodCategory(
            id: "food cat1",
            name: {'name': "mon menu"},
            imageURL: "null",
          ),
          restaurant: null,
          price: Price(amount: 12, currency: "€"),
          type: FoodType(tag: 'abc')),
      Food(
          id: "id1",
          name: "food 1",
          category: FoodCategory(
            id: "food cat1",
            name: {'name': "mon menu"},
            imageURL: "null",
          ),
          restaurant: null,
          price: Price(amount: 12, currency: "€"),
          type: FoodType(tag: 'ET')),
    ]);
