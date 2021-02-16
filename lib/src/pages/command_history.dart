import 'package:flutter/material.dart';
import 'package:flutter_collapse/flutter_collapse.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/components/cards.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/pages/food.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/HistoryContext.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:menu_advisor/src/utils/extensions.dart';

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

  List<Command> commandDelivery = List();
  List<Command> commandOnSite = List();
  List<Command> commandOnTakeaway = List();

  Map<String, List<Command>> commandByType = Map();
  Map<String, List<Command>> commandByTypeDate = Map();
  Map<String, bool> commandByTypeValue = Map();
  // List<bool> commandByTypeValue = List();

  bool loading = true;

  Api api = Api.instance;

  String commandType = 'delivery';
  HistoryContext _historyContext;

  DateTime dateTri;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _historyContext = Provider.of<HistoryContext>(context,listen: false);

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
    loadData(null);
   /* itemPositionsListener.itemPositions.addListener(() {
      print('Scroll position: ${itemPositionsListener.itemPositions.value.first.index}');
      tabController.animateTo(itemPositionsListener.itemPositions.value.first.index);
    });*/



    // setState(() {
    //   loading = false;
    // });
  }

  loadData(String commandType) async {
    setState(() {
      loading = true;
    });
    SettingContext settingContext = Provider.of<SettingContext>(
      context,
      listen: false,
    );

    AuthContext authContext = Provider.of<AuthContext>(
      context,
      listen: false,
    );
try {
 
    this.commands = await authContext.getCommandOfUser(
      limit: 500,
      commandType: commandType
    ); 
} catch (e) {
  this.commands = List();
}

   /* commandByType = this.commands.groupBy((c) =>
        c.createdAt.day.toString().padLeft(2,"0") +"/"+ c.createdAt.month.toString().padLeft(2,"0")+"/"+ c.createdAt.year.toString()
      );

    commandByType.forEach((key, value) {
      commandByTypeValue[key] = false;
    });*/

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
              : Column(

                children: [
                  Expanded(child: _renderViewItem(commandType)),
                  /*SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RaisedButton(
                        padding: EdgeInsets.all(15),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onPressed: () async {
                          setState(() {
                            dateTri = null;
                          });
                        },
                        child: TextTranslator(
                          "Afficher tous",
                          style: TextStyle(
                            color: CRIMSON,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      RaisedButton(
                        padding: EdgeInsets.all(15),
                        color: CRIMSON,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onPressed: () async {
                          DateTime date = await showDatePicker(
                              context: context, initialDate: DateTime.now(), firstDate: DateTime(2021), lastDate: DateTime(2984));

                          if (date != null){
                            setState(() {
                              dateTri = date;
                            });
                          }else{
                            print("date null");
                          }
                        },
                        child: TextTranslator(
                          "Trie par date",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    
                    ],
                  ),*/
                  SizedBox(height: 10,),
                ],
              )
    );
  }

  Widget _renderViewItem(String title) {
    /// test tri par date
 /*   var commandTemp = commands
        .where((element){
          if (dateTri != null) {
            if (element.commandType == title &&
            element.createdAt.day == dateTri.day &&
            element.createdAt.month == dateTri.month &&
            element.createdAt.year == dateTri.year) {
              return true;
            }
            return false;
          }
          if (element.commandType == title) return true;
            return false;


    })
        
        .toList();*/
            var commandTemp = commands
        .where((element) => element.commandType == title).toList();
        print(commandTemp);


    commandByType = commandTemp.groupBy((c) =>
      c.createdAt.month.toString().padLeft(2,"0").month +" "+ c.createdAt.year.toString()
    );

    commandByTypeValue.clear();
    commandByType.forEach((key, value) {
      commandByTypeValue[key] = dateTri == null ? false : true;
      // commandByTypeValue.add(false);
      commandByTypeDate = value.groupBy((c) =>
        c.createdAt.day.toString().padLeft(2,"0") +"/"+ c.createdAt.month.toString().padLeft(2,"0")
      );
    });
   /* commandByTypeDate.forEach((key, value) {
      commandByTypeValue[key] = false;
    });*/
    _historyContext.commandByTypeValue = commandByTypeValue;

    return commandByType.length == 0
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
        : SingleChildScrollView(
          child: Consumer<HistoryContext>(
            builder: (context, snapshot,w) {
              return Column(
                   children: [
                     ...commandByType.entries.map((e) {

                       Map<String, List<Command>> tempSemaine = Map();

                       // tempSemaine = e.value.groupBy((g) =>
                       //     g.createdAt.
                       // );

                       return Collapse(
                         value: snapshot.commandByTypeValue[e.key],
                         onChange: (value) {
                           print(value);
                           snapshot.setCollapse(e.key, value);
                         },
                         title: TextTranslator(
                           e.key,
                           style: TextStyle(fontSize: 18, fontWeight: FontWeight
                               .bold),
                         ),
                         body: ListView.builder(
                             shrinkWrap: true,
                             itemCount: commandByType[e.key].length,
                             // itemCount: commandByTypeDate.keys.toList().length,
                             physics: NeverScrollableScrollPhysics(),
                             itemBuilder: (_, position) {
                              /* String k = commandByTypeDate.keys.toList()[position];
                               return Collapse(
                                 value: snapshot.commandByTypeValue[k],
                                 onChange: (value) {
                                   print(value);
                                   snapshot.setCollapse(k, value);
                                 },
                                 title: TextTranslator(
                                   k,
                                   style: TextStyle(fontSize: 18,
                                       fontWeight: FontWeight
                                       .bold,
                                   color: CRIMSON),
                                   textAlign: TextAlign.right,
                                 ),
                                 showBorder: true,
                                 body: ListView.builder(
                                     shrinkWrap: true,
                                     itemCount: commandByTypeDate[k].length,
                                     physics: NeverScrollableScrollPhysics(),
                                     itemBuilder: (_, position) {

                                       return CommandHistoryItem(
                                         command: commandByTypeDate[k][position],);
                                     }),
                               );*/
                               return CommandHistoryItem(
                                 command: commandByType[e.key][position],);
                             }),
                       );
                     }).toList()
                   ],
              );
            }
          ),
        );

    /*ListView.builder(
          itemCount: commandByType.length,
          itemBuilder: (_,position){
            return Collapse(
              value: commandByTypeValue[position],
              onChange: (value){
                // setState(() {
                  commandByTypeValue[position] = value;
                // });
              },
              title: commandByType,
            );
            return CommandHistoryItem(command: commandTemp[position],);
          });*/
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
