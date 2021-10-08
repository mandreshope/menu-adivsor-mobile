import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/constants/constant.dart';
import 'package:menu_advisor/src/models/models.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:provider/provider.dart';

class ChoiceOption extends StatelessWidget {
  final Option option;
  final Food food;
  final List<Option> options;
  ChoiceOption({
    @required this.option,
    @required this.food,
    this.options,
  });

  @override
  Widget build(BuildContext context) {
    CartContext _cartContext = Provider.of<CartContext>(context, listen: true);
    return Container(
      child: ListView.builder(
          itemCount: option.items.length,
          shrinkWrap: true,
          itemBuilder: (_, position) {
            ItemsOption itemsOption = option.items[position];
            return Container(
              // color: _.selected ? CRIMSON : Colors.grey.withAlpha(1),
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  itemsOption.isSelected
                      ? IconButton(
                          icon: Icon(Icons.add_circle_outlined, color: Colors.grey, size: 25),
                          onPressed: () {
                            itemsOption.quantity = 1;
                            itemsOption.isSelected = !itemsOption.isSelected;
                            _cartContext.refresh();
                          },
                        )
                      :
                      //button incrementation
                      Container(
                          padding: EdgeInsets.only(left: 0),
                          // width: 50,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  icon: Icon(
                                    Icons.remove_circle,
                                    color: CRIMSON,
                                    size: 35,
                                  ),
                                  onPressed: () {
                                    if (itemsOption.quantity == 1) {
                                      itemsOption.quantity = 0;
                                      itemsOption.isSelected = false;
                                    } else {
                                      itemsOption.quantity--;
                                    }
                                    _cartContext.refresh();
                                  }),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                "${itemsOption.quantity ?? ""}${itemsOption.quantity != null ? "x" : ""}",
                                style: TextStyle(fontSize: 20),
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              IconButton(
                                  icon: Icon(Icons.add_circle_outlined, color: CRIMSON, size: 35),
                                  onPressed: () {
                                    if (option.isMaxOptions) {
                                      itemsOption.quantity++;
                                      _cartContext.refresh();
                                    } else {
                                      print("$logTrace max options");
                                      Fluttertoast.showToast(msg: "maximum selection ${option.title} : ${option.maxOptions}");
                                    }
                                  }),
                            ],
                          ),
                        ),
                  SizedBox(
                    width: 10,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/images/loading.gif',
                      image: itemsOption.imageUrl,
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                      imageErrorBuilder: (_, __, ___) => Container(
                        width: 50,
                        height: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text("${itemsOption.name}"),
                  SizedBox(
                    width: 5,
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    child: !_cartContext.withPrice || itemsOption.price.amount == null
                        ? Text("")
                        : Text(
                            "${itemsOption.price.amount == 0 ? '' : itemsOption.price.amount / 100}${itemsOption.price.amount == 0 ? '' : "€"}",
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                  ),
                  Spacer(),
                ],
              ),
            );
          }),
    );
  }
}
