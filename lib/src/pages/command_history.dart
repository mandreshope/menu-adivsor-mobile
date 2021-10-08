import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:menu_advisor/src/components/cards.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models/models.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/HistoryContext.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
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

  List<Command> commands = [];

  List<Command> commandDelivery = [];
  List<Command> commandOnSite = [];
  List<Command> commandOnTakeaway = [];

  Map<String, List<Command>> commandByType = Map();
  Map<String, List<Command>> commandByTypeDate = Map();
  Map<String, bool> commandByTypeValue = Map();
  // List<bool> commandByTypeValue = [];

  bool loading = true;

  Api api = Api.instance;

  String commandType = 'delivery';
  HistoryContext _historyContext;

  DateTime dateTri;

  @override
  void initState() {
    super.initState();

    _historyContext = Provider.of<HistoryContext>(context, listen: false);

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
  }

  loadData(String commandType) async {
    setState(() {
      loading = true;
    });

    AuthContext authContext = Provider.of<AuthContext>(
      context,
      listen: false,
    );
    try {
      this.commands = await authContext.getCommandOfUser(limit: 500, commandType: commandType);
    } catch (e) {
      print(e);
      this.commands = [];
    }

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
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
    );
  }

  Widget _renderViewItem(String title) {
    var commandTemp = commands.where((element) => element.commandType == title).toList();
    print(commandTemp);

    commandByType = commandTemp.groupBy((c) => c.createdAt.month.toString().padLeft(2, "0").month + " " + c.createdAt.year.toString());

    commandByTypeValue.clear();
    commandByType.forEach((key, value) {
      commandByTypeValue[key] = dateTri == null ? false : true;
      if (value.first.createdAt.month == DateTime.now().month) commandByTypeValue[key] = true;
      commandByTypeDate = value.groupBy((c) => c.createdAt.day.toString().padLeft(2, "0") + "/" + c.createdAt.month.toString().padLeft(2, "0"));
    });
    _historyContext.commandByTypeValue = commandByTypeValue;

    return commandByType.length == 0
        ? Padding(
            padding: const EdgeInsets.only(top: 25),
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
            child: Consumer<HistoryContext>(builder: (context, snapshot, w) {
              return Column(
                children: [
                  ...commandByType.entries.map((e) {
                    return ExpandableNotifier(
                      child: Container(
                        color: Colors.white,
                        child: ScrollOnExpand(
                          scrollOnExpand: true,
                          scrollOnCollapse: false,
                          child: ExpandablePanel(
                            theme: const ExpandableThemeData(
                              headerAlignment: ExpandablePanelHeaderAlignment.center,
                              tapBodyToCollapse: true,
                              hasIcon: true,
                            ),
                            header: Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              padding: const EdgeInsets.all(8.0),
                              child: TextTranslator(
                                e.key,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            collapsed: Container(),
                            expanded: Container(
                              color: Colors.white,
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(0),
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: commandByType[e.key].length,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (_, position) {
                                      return CommandHistoryItem(
                                        command: commandByType[e.key][position],
                                      );
                                    }),
                              ),
                            ),
                            builder: (_, collapsed, expanded) {
                              return Expandable(
                                collapsed: collapsed,
                                expanded: expanded,
                                theme: const ExpandableThemeData(crossFadePoint: 0),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  }).toList()
                ],
              );
            }),
          );
  }
}
