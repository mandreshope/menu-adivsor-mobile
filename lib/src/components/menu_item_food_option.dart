import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
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
                                option.itemOptionSelected = value.cast<ItemsOption>();
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
                                  child: 
                                  !widget.withPrice ? Text("") : 
                                  Text(
                                    "${_.value.price == 0 ? '' : _.value.price/100}${_.value.price == 0 ? '' : "€"}",
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
          ],
        ),
      ),
    );
  }
}
