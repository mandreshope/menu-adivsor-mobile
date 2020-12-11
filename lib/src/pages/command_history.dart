import 'package:flutter/material.dart';
import 'package:menu_advisor/src/components/cards.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/pages/food.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
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

  String commandType = 'delivery';

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
      // itemScrollController.jumpTo(index: tabController.index);
      switch (tabController.index) {
        case 0:
          commandType = 'delivery';
          break;
        case 1:
          commandType = 'on_site';
          break;
        case 2:
          commandType = 'takeaway';
          break;
        default:
        commandType = 'delivery';
          break;
      }
      setState(() {});
    });

   /* itemPositionsListener.itemPositions.addListener(() {
      print('Scroll position: ${itemPositionsListener.itemPositions.value.first.index}');
      tabController.animateTo(itemPositionsListener.itemPositions.value.first.index);
    });*/

    loadData();

    // setState(() {
    //   loading = false;
    // });
  }

  loadData() async {
    SettingContext settingContext = Provider.of<SettingContext>(
      context,
      listen: false,
    );

    AuthContext authContext = Provider.of<AuthContext>(
      context,
      listen: false,
    );

    this.commands = await authContext.getCommandOfUser(
      limit: 100,
    );

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextTranslator(
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
              text: AppLocalizations.of(context).translate('delivery'),
            ),
            Tab(
              text: AppLocalizations.of(context).translate('on_site'),
            ),
            Tab(
              text: AppLocalizations.of(context).translate('takeaway'),
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
                      TextTranslator(
                        AppLocalizations.of(context).translate('no_command'),
                        style: TextStyle(
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                )
              : _renderViewItem(commandType)
              /*Column(mainAxisSize: MainAxisSize.max, children: [
                  Expanded(
                      child: ScrollablePositionedList.separated(
                    itemScrollController: itemScrollController,
                    itemPositionsListener: itemPositionsListener,
                    padding: const EdgeInsets.all(20),
                    itemCount: 3,
                    itemBuilder: (_, index) {
                      if (index == 0) return _renderItems(title: 'delivery');

                      if (index == 1) return _renderItems(title: 'on_site');

                      return _renderItems(title: 'takeaway');
                    },
                    separatorBuilder: (_, index) => Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      child: Divider(),
                    ),
                  )),
                ]),*/
    );
  }

  _renderItems({String title}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextTranslator(
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
      ],
    );
  }

  _renderViewItem(String title) {
    var commandTemp = commands
        .where((element) => element.commandType == title)
        
        .toList();
        print(commandTemp);
    return commandTemp.length == 0
        ? Padding(
          padding: const EdgeInsets.only(top:25),
          child: Align(
            alignment: Alignment.topCenter,
                    child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning,
                    size: 40,
                  ),
                  TextTranslator(
                    "Aucun",
                    style: TextStyle(
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
          ),
        )
        : ListView.builder(
          itemCount: commandTemp.length,
          itemBuilder: (_,position){
            return CommandHistoryItem(command: commandTemp[position],);
          });
        /*SingleChildScrollView(
            child: Column(
              children: [
                for(var item in commandTemp)
                  item.items.length == 0 ? Container() : 
                  CommandHistoryItem(command: item,)
              ]
            ),
          );*/
  }
}
