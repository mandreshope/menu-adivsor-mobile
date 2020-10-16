import 'package:flutter/material.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:provider/provider.dart';

class CommandHistoryPage extends StatefulWidget {
  @override
  _CommandHistoryPageState createState() => _CommandHistoryPageState();
}

class _CommandHistoryPageState extends State<CommandHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('command_history'),
        ),
      ),
      body: Consumer<AuthContext>(
        builder: (_, authContext, __) =>
            authContext.currentUser.commands.length == 0
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
                : SingleChildScrollView(
                    child: Column(
                      children: authContext.currentUser.commands
                          .map(
                            (e) => Card(),
                          )
                          .toList(),
                    ),
                  ),
      ),
    );
  }
}
