import 'dart:convert';

import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_balloon_slider/flutter_balloon_slider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/components/buttons.dart';
import 'package:menu_advisor/src/components/cards.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/pages/order.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/providers/DataContext.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/button_item_count_widget.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';
import 'package:wave_slider/wave_slider.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final bool isSimple;

  const ConfirmationDialog({
    Key key,
    @required this.title,
    @required this.content,
    this.isSimple = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: isSimple ? Container() : TextTranslator(
        title,
      ),
      content: TextTranslator(
        content,
      ),
      actions: [
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: TextTranslator(
            AppLocalizations.of(context).translate('cancel'),
          ),
        ),
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: TextTranslator(
            AppLocalizations.of(context).translate("confirm"),
          ),
        ),
      ],
    );
  }
}

class BagModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextTranslator(
                  AppLocalizations.of(context).translate("in_cart"),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Consumer<CartContext>(
                  builder: (_, cartContext, __) => Text(
                    'Total: ${cartContext.totalPrice}€',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              physics: BouncingScrollPhysics(),
              child: Consumer<CartContext>(
                builder: (_, cartContext, __) {
                  final List<Widget> list = [];
                  cartContext.items.forEach(
                    (food) {
                      list.add(
                        BagItem(
                          food: food,
                          count: 1,
                        ),
                      );
                    },
                  );

                  if (cartContext.itemCount == 0)
                    return Center(
                      child: TextTranslator(
                        AppLocalizations.of(context).translate('no_item_in_cart'),
                      ),
                    );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: list,
                  );
                },
              ),
            ),
          ),
          Consumer<CartContext>(
            builder: (_, cartContext, __) => FlatButton(
              onPressed: () {
                if (cartContext.itemCount == 0)
                  Fluttertoast.showToast(
                    msg: AppLocalizations.of(context).translate('empty_cart'),
                  );
                else
                  RouteUtil.goTo(
                    context: context,
                    child: OrderPage(),
                    routeName: orderRoute,
                  );
              },
              padding: const EdgeInsets.all(
                20.0,
              ),
              color: Colors.teal,
              child: TextTranslator(
                AppLocalizations.of(context).translate("order"),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddToBagDialog extends StatefulWidget {
  final Food food;

  const AddToBagDialog({
    Key key,
    this.food,
  }) : super(key: key);

  @override
  _AddToBagDialogState createState() => _AddToBagDialogState();
}

class _AddToBagDialogState extends State<AddToBagDialog> {
  int itemCount = 1;
  dynamic optionSelected;
  List<dynamic> options = [];
  String shedule = "ouvert";
  @override
  void initState() {
    super.initState();

    CartContext cartContext = Provider.of<CartContext>(context, listen: false);
    if (cartContext.contains(widget.food)) itemCount = cartContext.getCount(widget.food);
    options = widget.food.options;
    // if (options.length > 0)
    //   optionSelected = options.first;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Consumer<CartContext>(builder: (_, cartContext, __) {
        if (cartContext.contains(widget.food)) itemCount = cartContext.getCount(widget.food);
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 25.0,
                  left: 25.0,
                  right: 25.0,
                ),
                child: TextTranslator(
                  cartContext.contains(widget.food) ? AppLocalizations.of(context).translate('edit') : AppLocalizations.of(context).translate('add_to_cart'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10),
              if (options.isEmpty)
                Container()
              else ...[
                /* Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: TextTranslator("Options"),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ChipsChoice.single(value: optionSelected,
                    padding: EdgeInsets.zero,
                    onChanged: (value) {
                      setState(() {
                        optionSelected = value;
                        widget.food.itemOptionSelected = options[value];
                      });
                    },
                    choiceItems: C2Choice.listFrom(
                      source: options,
                      value: (i, v) => i,
                      label: (i, v) => v['name'][Provider.of<SettingContext>(context).languageCode],
                    ),
                  ),
                ),*/
              ],
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: TextTranslator(
                            AppLocalizations.of(context).translate('item_count'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Row(
                            children: [
                              ButtonItemCountWidget(widget.food, onAdded: (value) {
                                setState(() {
                                  itemCount = value;
                                });
                              }, onRemoved: (value) {
                                if (value > 0)
                                  setState(() {
                                    itemCount = value;
                                  });
                              }, itemCount: itemCount, isContains: true)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 25.0,
                    ),
                    child: RaisedButton(
                      color: CRIMSON,
                      child: TextTranslator(
                        cartContext.contains(widget.food) ? AppLocalizations.of(context).translate('edit') : AppLocalizations.of(context).translate('add'),
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        if (widget.food.options.isNotEmpty && optionSelected == null) {
                          Fluttertoast.showToast(
                            msg: AppLocalizations.of(context).translate('choose_option'),
                          );
                        } else {
                          /* if (cartContext.contains(widget.food))
                                cartContext.setCount(widget.food, itemCount);
                              else*/
                          cartContext.addItem(widget.food, itemCount, true);

                          Navigator.of(context).pop(true);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}

class LanguageDialog extends StatelessWidget {
  final String lang;

  LanguageDialog({this.lang});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(15),
        height: 100,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextTranslator(
              AppLocalizations.of(context).translate('language'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  alignment: Alignment.center,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 0,
                        ),
                        decoration: BoxDecoration(
                          color: lang == 'fr' ? Colors.grey[400].withOpacity(.4) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: SvgPicture.asset('assets/images/france-flag.svg'),
                          onPressed: () => Navigator.of(context).pop<String>('fr'),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 0,
                        ),
                        decoration: BoxDecoration(
                          color: lang == 'en' ? Colors.grey[400].withOpacity(.4) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: SvgPicture.asset('assets/images/usa-flag.svg'),
                          onPressed: () => Navigator.of(context).pop<String>('en'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchSettingDialog extends StatefulWidget {
  final String languageCode;
  final Map<String, dynamic> filters;
  final String type;
  final bool inRestaurant;
  final int range;
  final bool isDiscover;
  final bool fromCategory;
  final bool fromRestaurantHome;

  bool fromMap;
  String shedule;

  SearchSettingDialog({Key key, @required this.languageCode,this.fromRestaurantHome = false,this.shedule, @required this.filters, @required this.type, this.inRestaurant = false, this.range = 1, this.isDiscover = false,this.fromMap = false,this.fromCategory = false}) : super(key: key);

  @override
  _SearchSettingDialogState createState() => _SearchSettingDialogState();
}

class _SearchSettingDialogState extends State<SearchSettingDialog> {
  Map<String, dynamic> filters = Map();
  String type;
  int distanceAround; // 20 km
  ValueNotifier<double> _slider1Value = ValueNotifier<double>(0.0);

  List<String> searchType = [];

  String shedule = "Tous";
  String categorieType = "";

  List<FoodCategory> _foodCategories;
  List<FoodCategory> _foodCategoriesSelected = [];
  DataContext _dataContext;

  List<FoodAttribute> _foodAttribut;
  List<FoodAttribute> _foodAttributSelected = [];

  @override
  void initState() {
    super.initState();
    
    distanceAround = widget.range;
    if (!widget.isDiscover){
    this.shedule = widget.shedule ?? "Tous";
    searchType = [
                      'all',
                      'restaurant',
                      'food',
                    ];

    

    
    type = widget.type;
    filters.addAll(widget.filters);
    _dataContext = Provider.of<DataContext>(context,listen: false);
    _foodCategories = _dataContext.foodCategories;
    _foodAttribut = _dataContext.foodAttributes;

    _foodAttribut.forEach((element) {
      if (filters.containsKey('attributes')){
        List<String> f = filters['attributes'];
        if (f.contains(element.sId)){
          _foodAttributSelected.add(element);
        }
      }
    });

_foodCategories.forEach((element) {
      if (filters.containsKey('category')){
        List<String> f = filters['category'];
        if (f.contains(element.id)){
          _foodCategoriesSelected.add(element);
        }
      }
    });
}
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
          top: 25,
          bottom: 10,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //distan around
            if (!widget.inRestaurant) ...[
              SizedBox(
                height: 20,
              ),
              ValueListenableBuilder(
                valueListenable: _slider1Value,
                builder: (__, value, w) {
                  return Text(
                    "Max distance : $distanceAround km",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              SizedBox(
                height: 15,
              ),
              BalloonSlider(
                  value: widget.range / 100,
                  ropeLength: 55,
                  showRope: true,
                  onChangeStart: (val) {},
                  onChanged: (val) {
                    distanceAround = (val * 100).round();
                    _slider1Value.value = val;
                    Provider.of<SettingContext>(context, listen: false).range = distanceAround;
                    print("$distanceAround km");
                  },
                  onChangeEnd: (val) {},
                  color: Colors.indigo),
              SizedBox(
                height: 15,
              ),
            ],
            SizedBox(
              height: 15,
            ),
            /*WaveSlider(
              onChanged: (value){
                setState(() {
                  distanceAround = value*100;
                  print("$distanceAround km");
                });
                
              },
              color: Colors.black,
              displayTrackball: true,
              // sliderHeight: 50,
            ),*/
            
            if (!widget.fromCategory)...[
              if (!widget.isDiscover) ...[
              if (!widget.inRestaurant && !widget.fromRestaurantHome && !widget.fromMap) ...[
                
                TextTranslator(
                  AppLocalizations.of(context).translate('search_type'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  child: Row(
                    children: 
                    searchType
                        .map(
                          (e) => Theme(
                            data: ThemeData(
                              brightness: type == e ? Brightness.dark : Brightness.light,
                              cardColor: type == e ? CRIMSON : Colors.white,
                            ),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: () {
                                  setState(() {
                                    type = e;
                                    if (type == 'all'){
                                      _foodAttributSelected.clear();
                                      filters.remove('attributes');

                                      _foodCategoriesSelected.clear();
                                      filters.remove('category');
                                    
                                    }else if (type == 'food'){
                                      _foodCategoriesSelected.clear();
                                      filters.remove('category');
                                    }else{
                                      _foodAttributSelected.clear();
                                      filters.remove('attributes');
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  child: TextTranslator(
                                    AppLocalizations.of(context).translate(e),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
              
              ]
            ],
            if(type == 'restaurant' || widget.fromMap || widget.inRestaurant)
                TextTranslator(
                  widget.inRestaurant ? 'Types' : AppLocalizations.of(context).translate('categories'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if(type == 'restaurant' || widget.fromMap || widget.inRestaurant)
                SizedBox(
                  height: 10,
                ),
                if(type == 'restaurant' || widget.fromMap || widget.inRestaurant)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      if (widget.inRestaurant)...[
                        Theme(
                        data: ThemeData(
                          brightness: !filters.containsKey('type') ? Brightness.dark : Brightness.light,
                          cardColor: !filters.containsKey('type') ? CRIMSON : Colors.white,
                        ),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(50),
                            onTap: () {
                              setState(() {
                                filters.remove('type');
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              child: TextTranslator(
                                'Tous',
                              ),
                            ),
                          ),
                        ),
                      ),
                      if(type != 'food')
                        ...Provider.of<DataContext>(context)
                          .foodTypes
                          .map(
                            (e) => Theme(
                              data: ThemeData(
                                brightness: filters.containsKey('type') && filters['type'] == e.name ? Brightness.dark : Brightness.light,
                                cardColor: filters.containsKey('type') && filters['type'] == e.name ? CRIMSON : Colors.white,
                              ),
                              child: Card(
                                color: filters.containsKey('type') && filters['type'] == e.name ? CRIMSON : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(50),
                                  onTap: () {
                                    setState(() {
                                      filters['type'] = e.name;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        TextTranslator(
                                          e.name,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      ]else...[
                    if(type != 'food')
                      Theme(
                        data: ThemeData(
                          brightness: !filters.containsKey('category') ? Brightness.dark : Brightness.light,
                          cardColor: !filters.containsKey('category') ? CRIMSON : Colors.white,
                        ),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(50),
                            onTap: () {
                              setState(() {
                                _foodCategoriesSelected.clear();
                                filters.remove('category');
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              child: TextTranslator(
                                'Tous',
                              ),
                            ),
                          ),
                        ),
                      ),
                      if(type != 'food')
                      ChipsChoice.multiple(
                        value: _foodCategoriesSelected,
                        choiceBuilder: (_){
                           return Theme(
                              data: ThemeData(
                                brightness: _.selected ? Brightness.dark : Brightness.light,
                                cardColor: _.selected ? CRIMSON : Colors.white,
                              ),
                              child: Card(
                                color: _.selected ? CRIMSON : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(50),
                                  onTap: () {
                                    _.select(!_.selected);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    child: TextTranslator(
                                      _.value.name,
                                    ),
                                  ),
                                ),
                              ),
                            );                      
                        },
                        
                        onChanged: (value){
                          setState(() {
                            _foodCategoriesSelected = value.cast<FoodCategory>();  
                            print(_foodCategoriesSelected.toString());
                            filters['category'] = _foodCategoriesSelected.map<String>((e) => e.id).toList();
                          });
                        }, 
                        choiceItems: C2Choice.listFrom(
                                                meta: (position, item){

                                                },
                                                source: _foodCategories,
                                                value: (i, v) => v,
                                                label: (i, v) => v.name,
                                              ),
                                            ),
                      ]
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                if(!widget.fromMap && type != 'all' && type != 'restaurant')
                TextTranslator(
                  AppLocalizations.of(context).translate('attributes'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if(!widget.fromMap && type != 'all' && type != 'restaurant')
               SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      Theme(
                        data: ThemeData(
                          brightness: !filters.containsKey('attributes') ? Brightness.dark : Brightness.light,
                          cardColor: !filters.containsKey('attributes') ? CRIMSON : Colors.white,
                        ),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(50),
                            onTap: () {
                              setState(() {
                                _foodAttributSelected.clear();
                                filters.remove('attributes');
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              child: TextTranslator(
                                'Tous',
                              ),
                            ),
                          ),
                        ),
                      ),
                      ChipsChoice.multiple(
                        value: _foodAttributSelected,
                        choiceBuilder: (_){
                           return Theme(
                              data: ThemeData(
                                brightness: _.selected ? Brightness.dark : Brightness.light,
                                cardColor: _.selected ? CRIMSON : Colors.white,
                              ),
                              child: Card(
                                color: _.selected ? CRIMSON : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(50),
                                  onTap: () {
                                    setState(() {
                                      _.select(!_.selected);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Image.network(
                                        _.value.imageURL,
                                          height: 18,
                                          errorBuilder: (_, __, ___) => Center(
                                            child: Icon(
                                              Icons.fastfood,size: 18,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        TextTranslator(
                                          _.value.locales,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                                                
                        },
                        
                        onChanged: (value){
                          setState(() {
                            _foodAttributSelected = value.cast<FoodAttribute>();  
                            print(_foodAttributSelected.toString());
                            filters['attributes'] = _foodAttributSelected.map<String>((e) => e.sId).toList();
                          });
                        }, 
                        choiceItems: C2Choice.listFrom(
                                                meta: (position, item){

                                                },
                                                source: _foodAttribut,
                                                value: (i, v) => v,
                                                label: (i, v) => v.locales,
                                              ),
                                            ),
                    ],
                  ),
                ),
                
                SizedBox(
                  height: 20,
                ),
           
            ],
            
           if (widget.fromMap)...[

           
            SizedBox(
                  height: 5,
                ),
                TextTranslator(
                  "Horaires",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ChipsChoice.single(
                  value: this.shedule,
                   onChanged: (value){
                     setState(() {
                       this.shedule = value;
                     });
                   }, choiceItems:  C2Choice.listFrom(
                        source: ["Tous","ouvert","fermé"],
                        value: (i, v) => v,
                        label: (i, v) => v,
                      ),),
           ],
                       Align(
              alignment: Alignment.centerRight,
              child: RaisedButton(
                onPressed: () => Navigator.of(context).pop(
                  {'filters': filters, 'type': type,'categorie':categorieType, 'range': distanceAround, "shedule":shedule},
                ),
                child: TextTranslator(
                  AppLocalizations.of(context).translate('confirm'),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OptionChoiceDialog extends StatefulWidget {
  OptionChoiceDialog({this.food, this.withPrice = true});
  Food food;
  bool withPrice;

  @override
  _OptionChoiceDialogState createState() => _OptionChoiceDialogState();
}

class _OptionChoiceDialogState extends State<OptionChoiceDialog> {
  int itemCount = 1;
  List<Option> optionSelected = List();
  List<Option> options = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    options = widget.food.options;
  }

  @override
  Widget build(BuildContext context) {
    CartContext _cartContext = Provider.of<CartContext>(context, listen: false);
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (_, position) {
                  Option option = options[position];
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 15,
                      ),
                      
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      
                      children: [
                        TextTranslator("${option.title}",
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 16),
                        textAlign: TextAlign.start,),
                        TextTranslator("Choisissez-en jusqu'à ${option.maxOptions}", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    
                      ],
                    ),Container(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25.0),
                          child: ChipsChoice.multiple(
                            value: option.itemOptionSelected,
                            padding: EdgeInsets.zero,
                            onChanged: (value) {
                              // int diff =
                              setState(() {
                                if (option.itemOptionSelected?.length == option.maxOptions) {
                                  if (option.itemOptionSelected.length >= value.length) {
                                    option.itemOptionSelected = value.cast<ItemsOption>();
                                    widget.food.optionSelected = options;
                                  } else {
                                    print("max options");
                                    Fluttertoast.showToast(msg: "maximum selection ${option.title} : ${option.maxOptions}");
                                  }
                                } else {
                                  option.itemOptionSelected = value.cast<ItemsOption>();
                                  widget.food.optionSelected = options;
                                }
                              });
                            },
                            choiceLabelBuilder: (_) {
                              return Row(
                                children: [
                                  Text("${_.value.name}"),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                    // padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      // color: _.value.price == 0 ? null : Colors.grey[400]
                                    ),
                                    child: !_cartContext.withPrice
                                        ? Text("")
                                        : Text(
                                            "${_.value.price == 0 ? '' : _.value.price / 100}${_.value.price == 0 ? '' : "€"}",
                                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                          ),
                                  )
                                ],
                              );
                            },
                            choiceItems: C2Choice.listFrom(
                              meta: (position, item) {},
                              source: option.items,
                              value: (i, v) => v,
                              label: (i, v) => v.name,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              RaisedButton(
                padding: EdgeInsets.all(8),
                color: CRIMSON,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onPressed: () => Navigator.of(context).pop(optionSelected),
                child: TextTranslator(
                  AppLocalizations.of(context).translate("validate"),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageDialog extends StatelessWidget {
  MessageDialog({Key key, this.message}) : super(key: key);
  String message;

  TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _messageController.text = message;
    return Dialog(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                color: CRIMSON,
              ),
              height: 50,
              width: double.infinity,
              child: Center(
                child: TextTranslator("Message", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
              ),
            ),
            Container(
              height: 150,
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: TextField(
                controller: _messageController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                showCursor: true,
                decoration: InputDecoration(border: InputBorder.none, hintText: "Votre message..."),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).pop(_messageController.text);
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                  color: TEAL,
                ),
                child: Center(
                  child: TextTranslator("Envoyer", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SheduleDialog extends StatelessWidget {
  SheduleDialog({Key key, this.openingTimes}) : super(key: key);
  List<OpeningTimes> openingTimes;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                color: CRIMSON,
              ),
              height: 50,
              width: double.infinity,
              child: Center(
                child: TextTranslator("Horaire", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
              ),
            ),
            Container(
              // height: 150,
              padding: EdgeInsets.all(25),
              child: ListView.builder(
                  itemCount: openingTimes.length,
                  shrinkWrap: true,
                  itemBuilder: (_, position) {
                    OpeningTimes op = openingTimes[position];
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextTranslator("${op.day}", style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.normal)),
                            Column(
                              children: [
                                ...op.openings.map((e){
                                  return TextTranslator(
                                    "${e.begin.hour.toString()?.padLeft(2, '0')} : ${e.begin.minute.toString()?.padLeft(2, '0')}  -  ${e.end.hour.toString()?.padLeft(2, '0')} : ${e.end.minute.toString()?.padLeft(2, '0')}",
                                    style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.normal),
                                  );
                                }).toList()
                              ],
                            )
                            
                          ],
                        ),
                        Divider()
                      ],
                    );
                  }),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                  color: TEAL,
                ),
                child: Center(
                  child: TextTranslator("Fermer", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AtributesDialog extends StatefulWidget {
  @override
  _AtributesDialogState createState() => _AtributesDialogState();
}

class _AtributesDialogState extends State<AtributesDialog> {
  List<FoodAttribute> attributes;
  DataContext dataContext;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dataContext = Provider.of<DataContext>(context, listen: false);
    attributes = dataContext.foodAttributes;
    // isAllAttribute = dataContext.isAllAttribute;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: CRIMSON,
            ),
            height: 50,
            width: double.infinity,
            child: Center(
              child: TextTranslator("Filtre allergènes", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
            ),
          ),
          /*
          ListTile(
            onTap: (){
              setState(() {
                dataContext.isAllAttribute = !dataContext.isAllAttribute;
                attributes.forEach((element) {
                  element.isChecked = false;
                });
              });
            },
            title: Row(
              children: [
                SizedBox(height: 10,),
                Checkbox(value: dataContext.isAllAttribute, onChanged: (value){
                  setState(() {
                    dataContext.isAllAttribute = value;

                  });
                },
                  checkColor: Colors.white,
                  hoverColor: CRIMSON,
                  activeColor: CRIMSON,),
                SizedBox(width: 10,),
                TextTranslator("Afficher tous les Allergènes",
                style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
              ],
            ),
          ),
         */
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: EdgeInsets.only(left: 35),
            child: TextTranslator("Retirer les allergènes : ", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
                itemCount: attributes.length,
                shrinkWrap: true,
                itemBuilder: (_, position) {
                  FoodAttribute att = attributes[position];
                  if (!att.tag.contains("allergen")) return Container();
                  return ListTile(
                    onTap: () {
                      setState(() {
                        att.isChecked = !att.isChecked;
                        if (att.tag.contains("allergen")) {
                          attributes.forEach((element) {
                            if (!element.tag.contains("allergen")) {
                              element.isChecked = false;
                            }
                          });
                        } else {
                          attributes.forEach((element) {
                            if (element.tag.contains("allergen")) {
                              element.isChecked = false;
                            }
                          });
                        }
                        dataContext.isAllAttribute = false;
                      });
                    },
                    title: Row(
                      children: [
                        
                        FadeInImage.assetNetwork(
                          placeholder: 'assets/images/loading.gif',
                          image: att.imageURL,
                          height: 25,
                          width: 25,
                          imageErrorBuilder: (_, __, ___) => Container(
                                width: 25,
                                height: 25,
                                color: Colors.white,
                              ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        TextTranslator(att.locales),
                        Spacer(),
                        Checkbox(
                          value: dataContext.isAllAttribute ? false : att.isChecked,
                          onChanged: (value) {
                            setState(() {
                              att.isChecked = value;
                              if (att.tag.contains("allergen")) {
                                attributes.forEach((element) {
                                  if (!element.tag.contains("allergen")) {
                                    element.isChecked = false;
                                  }
                                });
                              } else {
                                attributes.forEach((element) {
                                  if (element.tag.contains("allergen")) {
                                    element.isChecked = false;
                                  }
                                });
                              }
                              dataContext.isAllAttribute = false;
                            });
                          },
                          checkColor: Colors.white,
                          hoverColor: CRIMSON,
                          activeColor: CRIMSON,
                        ),
                      ],
                    ),
                  );
                }),
          ),
          if (attributes.where((element) => !element.tag.contains("allergen")).isNotEmpty)...[
          Padding(
            padding: EdgeInsets.only(left: 35),
            child: TextTranslator("Afficher : ", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
                itemCount: attributes.length,
                shrinkWrap: true,
                itemBuilder: (_, position) {
                  FoodAttribute att = attributes[position];
                  if (att.tag.contains("allergen")) return Container();
                  return ListTile(
                    onTap: () {
                      setState(() {
                        att.isChecked = !att.isChecked;
                        if (att.tag.contains("allergen")) {
                          attributes.forEach((element) {
                            if (!element.tag.contains("allergen")) {
                              element.isChecked = false;
                            }
                          });
                        } else {
                          attributes.forEach((element) {
                            if (element.tag.contains("allergen")) {
                              element.isChecked = false;
                            }
                          });
                        }
                        dataContext.isAllAttribute = false;
                      });
                    },
                    title: Row(
                      children: [
                        
                        FadeInImage.assetNetwork(
                          placeholder: 'assets/images/loading.gif',
                          image: att.imageURL,
                          height: 25,
                          width: 25,
                          imageErrorBuilder: (_, __, ___) => Container(
                                width: 25,
                                height: 25,
                                color: Colors.white,
                              ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        TextTranslator(att.locales),
                        Spacer(),
                        Checkbox(
                          value: dataContext.isAllAttribute ? false : att.isChecked,
                          onChanged: (value) {
                            setState(() {
                              att.isChecked = value;
                              if (att.tag.contains("allergen")) {
                                attributes.forEach((element) {
                                  if (!element.tag.contains("allergen")) {
                                    element.isChecked = false;
                                  }
                                });
                              } else {
                                attributes.forEach((element) {
                                  if (element.tag.contains("allergen")) {
                                    element.isChecked = false;
                                  }
                                });
                              }
                              dataContext.isAllAttribute = false;
                            });
                          },
                          checkColor: Colors.white,
                          hoverColor: CRIMSON,
                          activeColor: CRIMSON,
                        ),
                      ],
                    ),
                  );
               
                }),
          ),
          ],
          InkWell(
            onTap: () {
              List<FoodAttribute> selectedAttributes = List();

              // selectedAttributes = dataContext.isAllAttribute ? attributes : attributes.where((element) => element.isChecked).toList();
              selectedAttributes = /*dataContext.isAllAttribute ? List() : */ attributes.where((element) => element.isChecked).toList();

              Navigator.of(context).pop(selectedAttributes);
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: TEAL,
              ),
              child: Center(
                child: TextTranslator("Valider", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
              ),
            ),
          )
        ],
      ),
    );
  }
}

showDialogProgress(BuildContext context,{bool barrierDismissible = true}) {
  showDialog(
    barrierDismissible: barrierDismissible,
      context: context,
      builder: (_) {
        return Container(
          color: Colors.black.withAlpha(50),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    CRIMSON,
                  ),
                ),
                ),
               
                SizedBox(height: 20,),
                TextTranslator("Peut prendre quelque minutes...",
                style: TextStyle(fontSize: 15,color:Colors.white,decoration: TextDecoration.none,fontWeight: FontWeight.w400)) 
              ],
            ),
          ),
        );
      });
}

dismissDialogProgress(context) {
  Navigator.of(context).pop();
}
