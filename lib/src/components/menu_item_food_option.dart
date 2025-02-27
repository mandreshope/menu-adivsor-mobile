import 'package:chips_choice/chips_choice.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/constants/constant.dart';
import 'package:menu_advisor/src/pages/photo_view.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/providers/OptionContext.dart';
import 'package:menu_advisor/src/utils/price_formated.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../models/models.dart';

class MenuItemFoodOption extends StatefulWidget {
  MenuItemFoodOption({
    @required this.food,
    this.idOption,
    this.menu,
    this.withPrice = true,
    this.subMenu,
  });
  final Food food;
  final String idOption;
  final Menu menu;
  final bool withPrice;
  final String subMenu;

  @override
  _MenuItemFoodOptionState createState() => _MenuItemFoodOptionState();
}

class _MenuItemFoodOptionState extends State<MenuItemFoodOption> {
  int itemCount = 1;
  List<Option> optionSelected = [];
  List<Option> options = [];
  CartContext _cartContext;

  @override
  void initState() {
    super.initState();
    options = widget.food.options;
    options.forEach((option) {
      option.itemOptionSelected = [];
      option.singleItemOptionSelected = null;
    });
    _cartContext = Provider.of<CartContext>(context, listen: false);
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
                    if (position != 0) Divider(),
                    ExpandableNotifier(
                      initialExpanded:
                          option.isObligatory == true ? true : false,
                      child: ScrollOnExpand(
                        scrollOnExpand: true,
                        scrollOnCollapse: false,
                        child: ExpandablePanel(
                          theme: const ExpandableThemeData(
                            headerAlignment:
                                ExpandablePanelHeaderAlignment.center,
                            tapBodyToCollapse: true,
                            hasIcon: false,
                          ),
                          header: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ExpandableIcon(
                                theme: const ExpandableThemeData(
                                  iconColor: Colors.transparent,
                                  hasIcon: false,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextTranslator(
                                        "${option.title}",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                        textAlign: TextAlign.start,
                                      ),
                                      Visibility(
                                        visible: option.isObligatory,
                                        child: TextTranslator(
                                          " (Obligatoire)",
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        replacement: TextTranslator(
                                          " (Facultatif)",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextTranslator(
                                    "Choisissez-en jusqu'à ${option.maxOptions}",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              ExpandableIcon(
                                theme: const ExpandableThemeData(
                                  expandIcon: Icons.keyboard_arrow_right,
                                  collapseIcon: Icons.keyboard_arrow_down,
                                  iconColor: Colors.grey,
                                  iconSize: 28.0,
                                  iconRotationAngle: math.pi / 2,
                                  iconPadding: EdgeInsets.only(right: 5),
                                  hasIcon: false,
                                ),
                              ),
                            ],
                          ),
                          collapsed: Container(),
                          expanded: Container(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 25.0),
                              child: _choice(
                                option,
                                option.maxOptions == 1 ? true : false,
                              ),
                            ),
                          ),
                          builder: (_, collapsed, expanded) {
                            return Expandable(
                              collapsed: collapsed,
                              expanded: expanded,
                              theme:
                                  const ExpandableThemeData(crossFadePoint: 0),
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

  Widget _choice(Option option, bool isSingle) {
    if (isSingle) {
      return ChipsChoice.single(
        value: option.singleItemOptionSelected,
        choiceStyle: C2ChoiceStyle(
          borderColor: Colors.white,
          disabledColor: Colors.white,
          borderRadius: BorderRadius.zero,
          showCheckmark: false,
          padding: EdgeInsets.zero,
          labelPadding: EdgeInsets.zero,
          avatarBorderColor: Colors.white,
        ),
        padding: EdgeInsets.zero,
        direction: Axis.vertical,
        onChanged: (value) {
          setState(() {
            option.singleItemOptionSelected = value;
            option.singleItemOptionSelected.isSingle = true;
            option.singleItemOptionSelected.quantity = 1;
            if (option.itemOptionSelected.isEmpty)
              option.itemOptionSelected = [];

            option.itemOptionSelected
                .removeWhere((element) => element.isSingle);
            option.itemOptionSelected.add(value);

            widget.menu.optionSelected =
                options.map((o) => Option.copy(o)).toList();
            widget.food.optionSelected = options;
            _cartContext.addOption(widget.menu, options, key: widget.subMenu);
          });
        },
        choiceBuilder: (_) {
          return InkWell(
            onTap: () {
              _.select(!_.selected);
            },
            child: Container(
              margin: EdgeInsets.only(top: 15),
              color: Colors.white,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    width: 25,
                  ),
                  InkWell(
                    onTap: () {
                      RouteUtil.goTo(
                          context: context,
                          child: PhotoViewPage(
                            tag: 'tag:${_.value.imageUrl}',
                            img: _.value.imageUrl,
                          ),
                          routeName: null);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/images/loading.gif',
                        image: _.value.imageUrl,
                        imageErrorBuilder: (_, o, s) {
                          return Container(
                            width: 65,
                            height: 65,
                            color: Colors.white,
                          );
                        },
                        height: 65,
                        width: 65,
                        fit: BoxFit.cover,
                      ),
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
                    child: !_cartContext.withPrice ||
                            _.value.price.amount == null ||
                            widget.menu.type == 'priceless'
                        ? Text("")
                        : Text(
                            priceFormated(_.value.price.amount / 100),
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                  Spacer(),
                  InkWell(
                    onTap: () {
                      print("$logTrace food checked");
                      _.select(!_.selected);
                      _cartContext.refresh();
                      setState(() {});
                    },
                    child: _.selected
                        ? Icon(
                            Icons.radio_button_checked,
                            color: CRIMSON,
                            size: 25,
                          )
                        : Icon(
                            Icons.add_circle_outlined,
                            color: Colors.grey,
                            size: 25,
                          ),
                  ),
                  SizedBox(
                    width: 10,
                  )
                ],
              ),
            ),
          );
        },
        choiceItems: C2Choice.listFrom(
          meta: (position, item) {},
          source: option.items,
          value: (i, v) => v,
          label: (i, v) => v.name,
        ),
      );
    }

    return ChipsChoice.multiple(
      value: option.itemOptionSelected,
      padding: EdgeInsets.zero,
      onChanged: (value) {
        setState(() {
          if (option.itemOptionSelected?.length == option.maxOptions) {
            if (option.itemOptionSelected.length >= value.length) {
              option.itemOptionSelected = value.cast<ItemsOption>();
              widget.menu.optionSelected = options;
              widget.food.optionSelected = options;
              _cartContext.addOption(widget.menu, options, key: widget.subMenu);
              _cartContext.refresh();
            } else {
              print("$logTrace max options");
              Fluttertoast.showToast(
                  msg:
                      "maximum selection ${option.title} : ${option.maxOptions}");
            }
          } else {
            var seen = Set<String>();
            option.itemOptionSelected = value
                .cast<ItemsOption>()
                .where((element) => seen.add(element.name))
                .toList();

            widget.menu.optionSelected = options;
            widget.food.optionSelected = options;
            _cartContext.addOption(widget.menu, options, key: widget.subMenu);

            _cartContext.refresh();
          }
        });
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
      choiceBuilder: (_) {
        return Consumer<OptionContext>(
          builder: (context, snapshot, w) {
            return Container(
              // color: _.selected ? CRIMSON : Colors.grey.withAlpha(1),
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 25,
                  ),
                  InkWell(
                    onTap: () {
                      RouteUtil.goTo(
                          context: context,
                          child: PhotoViewPage(
                            tag: 'tag:${_.value.imageUrl}',
                            img: _.value.imageUrl,
                          ),
                          routeName: null);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/images/loading.gif',
                        image: _.value.imageUrl,
                        height: 65,
                        imageErrorBuilder: (_, o, s) {
                          return Container(
                            width: 65,
                            height: 65,
                            color: Colors.white,
                          );
                        },
                        width: 65,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text("${_.value.name}"),
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        // shape: BoxShape.circle,
                        // color: _.value.price == 0 ? null : Colors.grey[400]
                        ),
                    child: !_cartContext.withPrice ||
                            _.value.price.amount == null ||
                            widget.menu.type == 'priceless'
                        ? Text("")
                        : Text(
                            priceFormated(_.value.price.amount / 100),
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                  Spacer(),
                  !_.selected
                      ? IconButton(
                          icon: Icon(Icons.add_circle_outlined,
                              color: Colors.grey, size: 25),
                          onPressed: () {
                            if (option.isMaxOptions) {
                              _.value.quantity = 1;
                              _.select(!_.selected);
                            } else {
                              print("$logTrace max options");
                              Fluttertoast.showToast(
                                  msg:
                                      "maximum selection ${option.title} : ${option.maxOptions}");
                            }
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
                                    size: 25,
                                  ),
                                  onPressed: () {
                                    if (_.value.quantity == 1) {
                                      _.value.quantity = 0;
                                      _.select(false);
                                    } else {
                                      _.value.quantity--;
                                      _.select(true);
                                      // snapshot.refresh();
                                    }
                                    snapshot.refresh();
                                  }),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                "${_.value.quantity ?? ""}",
                                style: TextStyle(fontSize: 20),
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              IconButton(
                                icon: Icon(Icons.add_circle_outlined,
                                    color: CRIMSON, size: 25),
                                onPressed: () {
                                  if (option.isMaxOptions) {
                                    _.value.quantity++;
                                    _.select(true);
                                    snapshot.refresh();
                                  } else {
                                    print("$logTrace max options");
                                    Fluttertoast.showToast(
                                        msg:
                                            "maximum selection ${option.title} : ${option.maxOptions}");
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
