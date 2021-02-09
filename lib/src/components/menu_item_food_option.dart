import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/providers/OptionContext.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';

import '../models.dart';

class MenuItemFoodOption extends StatefulWidget {
  MenuItemFoodOption({@required this.food,this.idOption,this.menu,this.withPrice = true,this.subMenu});
  Food food;
  String idOption;
  Menu menu;
  bool withPrice;
  String subMenu;

  @override
  _MenuItemFoodOptionState createState() => _MenuItemFoodOptionState();
}

class _MenuItemFoodOptionState extends State<MenuItemFoodOption> {
  int itemCount = 1;
  List<Option> optionSelected = List();
  List<Option> options = [];
  CartContext _cartContext;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    options = widget.food.options;
    options.forEach((element) {
      element.itemOptionSelected = List();
    });
    _cartContext = Provider.of<CartContext>(context,listen: false);
  }

  @override
  Widget build(BuildContext context) {
    
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: options.length,
              itemBuilder: (_, position) {
                Option option = options[position];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 2,
                    ),
                    TextTranslator('vous avez ${option.maxOptions} choix de ${option.title}', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 25.0),
                        child: ChipsChoice.multiple(
                          value: option.itemOptionSelected,
                          padding: EdgeInsets.zero,
                          onChanged: (value) {
                            if (widget.menu.count > 0) return;
                            // int diff =
                            setState(() {

                              if (option.itemOptionSelected?.length == option.maxOptions) {
                                if (option.itemOptionSelected.length >= value.length) {
                                  option.itemOptionSelected = value.cast<ItemsOption>();
                                  widget.menu.optionSelected = options;
                                  widget.food.optionSelected = options;
                                  _cartContext.addOption(widget.menu, options,key: widget.subMenu);
                                  
                                  
                                  // _cartContext.addItem(widget.menu, 1,true);
                                  _cartContext.refresh();
                                } else {
                                  print("max options");
                                  Fluttertoast.showToast(msg: "maximum selection ${option.title} : ${option.maxOptions}");
                                }
                              } else {
                                var seen = Set<String>();
                                option.itemOptionSelected = value.cast<ItemsOption>().where((element) => seen.add(element.name)).toList();

                                widget.menu.optionSelected = options;
                                widget.food.optionSelected = options;
                                _cartContext.addOption(widget.menu, options,key: widget.subMenu);
                                
                                
                                // _cartContext.addItem(widget.menu, 1,true);
                                _cartContext.refresh();
                              }
                            });
                          },
                          choiceLabelBuilder: (_) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: FadeInImage.assetNetwork(
                                    placeholder: 'assets/images/loading.gif',
                                    image: _.value.imageUrl,
                                    height: 25,
                                    width: 25,
                                    fit: BoxFit.cover,

                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text("${_.value.name}"),
                                SizedBox(
                                  width: 5,
                                ),
                                /*Container(
                                  // padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    // color: _.value.price == 0 ? null : Colors.grey[400]
                                  ),
                                  child: 
                                  !widget.withPrice ? Text("") :
                                      _.value.price == null ? Text("") :
                                  Text(
                                    "${_.value.price == 0 ? '' : _.value.price/100}${_.value.price == 0 ? '' : "€"}",
                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                  ),
                                )*/
                              ],
                            );
                          },
                          choiceItems: C2Choice.listFrom(
                            meta: (position, item) {},
                            source: option.items,
                            value: (i, v) => v,
                            label: (i, v) => v.name,
                          ),

                          // padding: EdgeInsets.zero,
                          // wrapped: true,
                          // textDirection: TextDirection.ltr,
                          direction: Axis.vertical,
                          choiceBuilder: (_){
                            return Consumer<OptionContext>(
                                builder: (context, snapshot,w) {
                                  return Container(
                                    // color: _.selected ? CRIMSON : Colors.grey.withAlpha(1),
                                    padding: EdgeInsets.symmetric(horizontal: 5,vertical: 10),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        !_.selected ?
                                        IconButton(
                                          icon: Icon(Icons.add_circle_outlined,color: Colors.grey,size: 20),
                                          onPressed: (){
                                            if (widget.menu.count > 0) return;
                                            if (option.isMaxOptions){
                                              _.value.quantity = 1;
                                              _.select(!_.selected);
                                            }else{
                                              print("max options");
                                              Fluttertoast.showToast(
                                                  msg: "maximum selection ${option.title} : ${option.maxOptions}"
                                              );
                                            }

                                            /* if (widget.fromMenu){
                                                        menu.optionSelected = options;
                                                        widget.food.optionSelected = options;
                                                        _cartContext.addOption(menu, options,key: widget.subMenu);
                                                      }*/
                                          },)
                                            :
                                        //button incrementation
                                        Container(
                                          padding: EdgeInsets.only(left: 0),
                                          // width: 50,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                  icon: Icon(Icons.remove_circle,color:CRIMSON,size: 25,), onPressed: (){
                                                if (widget.menu.count > 0) return;
                                                if (_.value.quantity == 1){
                                                  _.value.quantity = 0;
                                                  _.select(false);
                                                }else{
                                                  _.value.quantity --;
                                                  _.select(true);
                                                  // snapshot.refresh();
                                                }
                                                /* if (widget.fromMenu){
                                                             menu.optionSelected = _optionSelected;
                                                             widget.food.optionSelected = _optionSelected;
                                                             _cartContext.addOption(menu, options,key: widget.subMenu);
                                                           }else{
                                                             widget.food.optionSelected = _optionSelected;
                                                           }*/
                                                snapshot.refresh();

                                              }),
                                              SizedBox(width: 2,),
                                              Text("${_.value.quantity ?? ""}",style: TextStyle(
                                                  fontSize: 20
                                              ),),
                                              SizedBox(width: 2,),
                                              IconButton(
                                                  icon: Icon(Icons.add_circle_outlined,color:CRIMSON,size: 25), onPressed: (){
                                                // if (_optionContext.quantityOptions == option.maxOptions){
                                                if (widget.menu.count > 0) return;
                                                if (option.isMaxOptions){
                                                  _.value.quantity ++;
                                                  _.select(true);
                                                  snapshot.refresh();
                                                }else{
                                                  print("max options");
                                                  Fluttertoast.showToast(
                                                      msg: "maximum selection ${option.title} : ${option.maxOptions}"
                                                  );
                                                }

                                                /*}else{
                                                              _.value.quantity ++;
                                                              snapshot.refresh();
                                                            }*/

                                              }),
                                            ],
                                          ),
                                        ),

                                        SizedBox(width: 10,),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(50),
                                          child: FadeInImage.assetNetwork(
                                            placeholder: 'assets/images/loading.gif',
                                            image: _.value.imageUrl,
                                            height: 30,
                                            width: 30,
                                            fit: BoxFit.cover,

                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text("${_.value.name}"),
                                        Spacer(),
                                        Container(
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            // shape: BoxShape.circle,
                                            // color: _.value.price == 0 ? null : Colors.grey[400]
                                          ),
                                          child: !_cartContext.withPrice || _.value.price.amount == null ? Text("") : Text("${_.value.price.amount == 0 ? '': _.value.price.amount/100}${_.value.price.amount == 0 ? '': "€"}",
                                            style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                                        ),
                                        Spacer(),
                                      ],
                                    ),

                                  );
                                }
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
