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

  const ConfirmationDialog({
    Key key,
    @required this.title,
    @required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TextTranslator(
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
                    (food, count) {
                      list.add(
                        BagItem(
                          food: food,
                          count: count,
                        ),
                      );
                    },
                  );

                  if (cartContext.itemCount == 0)
                    return Center(
                      child: TextTranslator(
                        AppLocalizations.of(context)
                            .translate('no_item_in_cart'),
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
  List<dynamic> options = [
  ];

  @override
  void initState() {
    super.initState();

    CartContext cartContext = Provider.of<CartContext>(context, listen: false);
    if (cartContext.contains(widget.food))
      itemCount = cartContext.getCount(widget.food);
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
      child: Consumer<CartContext>(
        builder: (_, cartContext, __) 
{
  if (cartContext.contains(widget.food))
      itemCount = cartContext.getCount(widget.food);
       return  Container(
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
                  cartContext.contains(widget.food)
                      ? AppLocalizations.of(context).translate('edit')
                      : AppLocalizations.of(context).translate('add_to_cart'),
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
                              ButtonItemCountWidget(
                                  widget.food,
                                  onAdded: (value) {
                                    setState(() {
                                      itemCount = value;
                                    });
                                  },
                                  onRemoved: (value) {
                                    if (value >0)
                                      setState(() {
                                        itemCount = value;
                                      });
                                  },
                                  itemCount: itemCount,
                                  isContains: true)
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
                            cartContext.contains(widget.food)
                                ? AppLocalizations.of(context).translate('edit')
                                : AppLocalizations.of(context).translate('add'),
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            if (widget.food.options.isNotEmpty && optionSelected == null) {
                              Fluttertoast.showToast(msg: AppLocalizations.of(context)
                                  .translate('choose_option'),);
                            }else{
                              if (cartContext.contains(widget.food))
                                cartContext.setCount(widget.food, itemCount);
                              else
                                cartContext.addItem(widget.food, itemCount,true);

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
}     
      ),
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
                          color: lang == 'fr'
                              ? Colors.grey[400].withOpacity(.4)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon:
                              SvgPicture.asset('assets/images/france-flag.svg'),
                          onPressed: () =>
                              Navigator.of(context).pop<String>('fr'),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 0,
                        ),
                        decoration: BoxDecoration(
                          color: lang == 'en'
                              ? Colors.grey[400].withOpacity(.4)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: SvgPicture.asset('assets/images/usa-flag.svg'),
                          onPressed: () =>
                              Navigator.of(context).pop<String>('en'),
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

  SearchSettingDialog({
    Key key,
    @required this.languageCode,
    @required this.filters,
    @required this.type,
    this.inRestaurant = false,
    this.range = 1
  }) : super(key: key);

  @override
  _SearchSettingDialogState createState() => _SearchSettingDialogState();
}

class _SearchSettingDialogState extends State<SearchSettingDialog> {
  Map<String, dynamic> filters = Map();
  String type;
  int distanceAround; // 20 km
  ValueNotifier<double> _slider1Value = ValueNotifier<double>(0.0);

  @override
  void initState() {
    super.initState();

    distanceAround = widget.range;
    type = widget.type;
    filters.addAll(widget.filters);
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
            
            SizedBox(height: 20,),
            ValueListenableBuilder(
              valueListenable: _slider1Value,
              builder: (__,value,w){
                return Text(
                "Max distance : $distanceAround km",
                 style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),);
              },
                          
            ),
             SizedBox(height: 15,),
             BalloonSlider(
                value: widget.range/100,
                ropeLength: 55,
                showRope: true,
                onChangeStart: (val) {},
                onChanged: (val) {
                  
                     distanceAround = (val*100).round();
                     _slider1Value.value = val;
                     Provider.of<SettingContext>(context,listen: false).range = distanceAround;
                     print("$distanceAround km");
                 
                },
                onChangeEnd: (val) {},
                color: Colors.indigo
            ),
            SizedBox(height: 15,),
            
              SizedBox(height: 15,),
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
                children: [
                  if (widget.inRestaurant) ...[
                    'all',
                    'food',
                  ] else ...[
                    'all',
                    'restaurant',
                    'food',
                  ]
                ]
                    .map(
                      (e) => Theme(
                        data: ThemeData(
                          brightness:
                              type == e ? Brightness.dark : Brightness.light,
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
            TextTranslator(
              AppLocalizations.of(context).translate('categories'),
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
                children: [
                  Theme(
                    data: ThemeData(
                      brightness: !filters.containsKey('category')
                          ? Brightness.dark
                          : Brightness.light,
                      cardColor: !filters.containsKey('category')
                          ? CRIMSON
                          : Colors.white,
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () {
                          setState(() {
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
                  ...Provider.of<DataContext>(context)
                      .foodCategories
                      .map(
                        (e) => Theme(
                          data: ThemeData(
                            brightness: filters.containsKey('category') &&
                                    filters['category'] == e.id
                                ? Brightness.dark
                                : Brightness.light,
                            cardColor: filters.containsKey('category') &&
                                    filters['category'] == e.id
                                ? CRIMSON
                                : Colors.white,
                          ),
                          child: Card(
                            color: filters.containsKey('category') &&
                                    filters['category'] == e.id
                                ? CRIMSON
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(50),
                              onTap: () {
                                setState(() {
                                  filters['category'] = e.id;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: TextTranslator(
                                  e.name[Provider.of<SettingContext>(context).languageCode],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            TextTranslator(
              AppLocalizations.of(context).translate('attributes'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              child: Row(
                children: [
                  Theme(
                    data: ThemeData(
                      brightness: !filters.containsKey('attributes')
                          ? Brightness.dark
                          : Brightness.light,
                      cardColor: !filters.containsKey('attributes')
                          ? CRIMSON
                          : Colors.white,
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () {
                          setState(() {
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
                  ...Provider.of<DataContext>(context)
                      .foodAttributes
                      .map(
                        (e) => Theme(
                          data: ThemeData(
                            brightness: filters.containsKey('attributes') &&
                                    filters['attributes'] == e.tag
                                ? Brightness.dark
                                : Brightness.light,
                            cardColor: filters.containsKey('attributes') &&
                                    filters['attributes'] == e.tag
                                ? CRIMSON
                                : Colors.white,
                          ),
                          child: Card(
                            color: filters.containsKey('attributes') &&
                                    filters['attributes'] == e.tag
                                ? CRIMSON
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(50),
                              onTap: () {
                                setState(() {
                                  filters['attributes'] = e.tag;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      e.imageURL,
                                      height: 18,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    TextTranslator(
                                      e.locales,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: RaisedButton(
                onPressed: () => Navigator.of(context).pop(
                  {
                    'filters': filters,
                    'type': type,
                    'range': distanceAround
                  },
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
  OptionChoiceDialog({this.food,this.withPrice = true});
  Food food;
  bool withPrice;

  @override
  _OptionChoiceDialogState createState() => _OptionChoiceDialogState();
}

class _OptionChoiceDialogState extends State<OptionChoiceDialog> {
  int itemCount = 1;
  List<Option> optionSelected = List();
  List<Option> options = [
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    options = widget.food.options;
  }

  @override
  Widget build(BuildContext context) {
    CartContext _cartContext = Provider.of<CartContext>(context,listen: false);
    return WillPopScope(
      onWillPop: () async{
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
                        itemBuilder: (_,position){
                          Option option = options[position];
                            return  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(height: 15,),
                                      TextTranslator(
                                        "Vous avez ${option.maxOptions} choix de ${option.title}",
                                        style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
                                      Container(
                                        child: Padding(
                                                  padding: const EdgeInsets.only(left: 25.0),
                                                  child: ChipsChoice.multiple(
                                                    value: option.itemOptionSelected,
                                                    padding: EdgeInsets.zero,
                                                    onChanged: (value) {
                                                      // int diff = 
                                                      setState(() {
                                                        if (option.itemOptionSelected?.length == option.maxOptions){
                                                          if (option.itemOptionSelected.length >= value.length ){
                                                            option.itemOptionSelected = value.cast<ItemsOption>();
                                                            widget.food.optionSelected = options;
                                                          }else{
                                                            print("max options");
                                                            Fluttertoast.showToast(
                                                            msg: "maximum selection ${option.title} : ${option.maxOptions}"
                                                          );
                                                          }
                                                          
                                                        }else{
                                                          option.itemOptionSelected = value.cast<ItemsOption>();
                                                            widget.food.optionSelected = options;
                                                        }
                                                        
                                                      });
                                                    },
                                                    choiceLabelBuilder: (_){
                                                      return Row(
                                                        children: [
                                                          Text("${_.value.name}"),
                                                          SizedBox(width: 5,),
                                                          Container(
                                                            // padding: EdgeInsets.all(5),
                                                            decoration: BoxDecoration(
                                                              shape: BoxShape.circle,
                                                              // color: _.value.price == 0 ? null : Colors.grey[400]
                                                            ),
                                                            child: !_cartContext.withPrice ? Text("") : Text("${_.value.price == 0 ? '': _.value.price/100}${_.value.price == 0 ? '': "€"}",
                                                            style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                                                          )
                                                        ],
                                                      );
                                                    },
                                                    choiceItems: C2Choice.listFrom(
                                                      meta: (position, item){

                                                      },
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
                                              onPressed: ()=> Navigator.of(context).pop(optionSelected),
                                              child: TextTranslator(
                                                      AppLocalizations.of(context)
                                                          .translate("validate"),
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
   MessageDialog({Key key,this.message}) : super(key: key);
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10))
        ),
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
                child: Text(
                  "Message",
                  textAlign: TextAlign.center,
                  style:TextStyle(color: Colors.white,fontWeight: FontWeight.bold,
                  fontSize: 20)),
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
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Votre message..."
                ),
              ),
            ),
            InkWell(
              onTap: (){
                Navigator.of(context).pop(_messageController.text);
              },
                child: Container(
                height: 50,
               decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                  color: TEAL,
              ),
              child: Center(
                  child: TextTranslator(
                    "Envoyer",
                    textAlign: TextAlign.center,
                    style:TextStyle(color: Colors.white,fontWeight: FontWeight.bold,
                    fontSize: 20)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}