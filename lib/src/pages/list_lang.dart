import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:provider/provider.dart';

class ListLang extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    SettingContext _settingContext = Provider.of<SettingContext>(context,listen: false);

    return Scaffold(
        appBar: AppBar(),
      body: ListView.builder(
          itemCount: _settingContext.languageCodes.length,
          itemBuilder: (_,position){
            String code = _settingContext.languageCodes[position];
            return ListTile(
                leading: Flag(code),
                title: Text("lang.name"),
              );
          }
      ),
    );
  }
}
