import 'package:flutter/material.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class CommandHistoryPage extends StatefulWidget {
  @override
  _CommandHistoryPageState createState() => _CommandHistoryPageState();
}

class _CommandHistoryPageState extends State<CommandHistoryPage> with SingleTickerProviderStateMixin {
  TabController tabController;
  int activeTabIndex = 0;

  ItemScrollController itemScrollController = ItemScrollController();
  ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  List<Command> commands = List();

  List<Food> foodDelivery = List();
  List<Food> foodOnSite = List();
  List<Food> foodOnTakeaway = List();

  Map<String, dynamic> commandByType = Map();

  bool loading = true;

  Api api = Api.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    tabController = TabController(
      vsync: this,
      initialIndex: 0,
      length: 3,
    );

    tabController.addListener(() {
      print(tabController.index);
      itemScrollController.jumpTo(index: tabController.index);
    });

    itemPositionsListener.itemPositions.addListener(() {
      print('Scroll position: ${itemPositionsListener.itemPositions.value.first.index}');
      tabController.animateTo(itemPositionsListener.itemPositions.value.first.index);
    });

    AuthContext authContext = Provider.of<AuthContext>(
      context,
      listen: false,
    );

    commands = authContext.currentUser.commands ?? List();

    //loadData();

    setState(() {
      loading = false;
    });
  }

  loadData() async {
    SettingContext settingContext = Provider.of<SettingContext>(
      context,
      listen: false,
    );

    var delivery = commands.where((element) => element.commandType == 'delivery').toList();

    for (var item in delivery) {
      item.items.forEach((element) async {
        var food = await api.getFood(
          id: element['_id'] as String,
          lang: settingContext.languageCode,
        );
        foodDelivery.add(food);
      });
    }

    var onSite = commands.where((element) => element.commandType == 'on_site').toList();

    for (var item in onSite) {
      item.items.forEach((element) async {
        var food = await api.getFood(
          id: element['id'] as String,
          lang: settingContext.languageCode,
        );
        foodOnSite.add(food);
      });
    }

    var takeaway = commands.where((element) => element.commandType == 'takeaway').toList();

    for (var item in takeaway) {
      item.items.forEach((element) async {
        var food = await api.getFood(
          id: element['id'] as String,
          lang: settingContext.languageCode,
        );
        foodOnTakeaway.add(food);
      });
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('command_history'),
        ),
        // backgroundColor: Colors.white,
        bottom: TabBar(
          controller: tabController,
          isScrollable: true,
          unselectedLabelColor: Colors.white,
          labelColor: CRIMSON,
          indicator: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.white),
          tabs: [
            Tab(
              text: AppLocalizations.of(context).translate('a_la_carte'),
            ),
            Tab(
              text: AppLocalizations.of(context).translate('menus'),
            ),
            Tab(
              text: AppLocalizations.of(context).translate('drinks'),
            ),
          ],
        ),
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(CRIMSON),
              ),
            )
          : commands.length == 0
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning,
                        size: 40,
                      ),
                      Text(
                        AppLocalizations.of(context).translate('no_command'),
                        style: TextStyle(
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                )
              : /*SingleChildScrollView(
                child: */
              Column(mainAxisSize: MainAxisSize.max, children: [
                  Expanded(
                      child: ScrollablePositionedList.separated(
                    itemScrollController: itemScrollController,
                    itemPositionsListener: itemPositionsListener,
                    padding: const EdgeInsets.all(20),
                    itemCount: 3,
                    itemBuilder: (_, index) {
                      // return Container(height: 15,width: 5,child: Text("svn"),);
                      if (index == 0)
                        return _renderItems(
                            title: 'delivery');

                      if (index == 1)
                        return _renderItems(
                            title: 'on_site');

                      // if (index == 2)
                      return _renderItems(
                          title: 'takeaway');
                    },
                    separatorBuilder: (_, index) => Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      child: Divider(),
                    ),
                  )),
                ]),
      //),
      //),
    );
  }

  _renderItems({Function function, String title}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.of(context).translate(title),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        _renderViewItem(title)
        //function(),
      ],
    );
  }

  _renderViewItem(String title) {
    var food = commands
        .where((element) => element.commandType == title)
        .map(
          (e) => Card(),
        )
        .toList();
    return food.length == 0
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.warning,
                size: 40,
              ),
              Text(
                "Aucun",
                style: TextStyle(
                  fontSize: 22,
                ),
              ),
            ],
          )
        : SingleChildScrollView(
            child: Column(
              children: commands
                  .where((element) => element.commandType == title)
                  .map(
                    (e) => Card(),
                  )
                  .toList(),
            ),
          );
  }

}
