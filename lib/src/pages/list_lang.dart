import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';

class ListLang extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SettingContext _settingContext = Provider.of<SettingContext>(context,listen: true);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: TextTranslator("Langues".toUpperCase(),),
        ),
      body: ListView.separated(
          itemCount: _settingContext.supportedLanguages.length,
          separatorBuilder: (_,position){
            return Divider();
          },
          itemBuilder: (_,position){
            String code = _settingContext.supportedLanguages[position];
            return ListTile(
                leading: Flag(_codeCountry(code),height: 50,width: 50,),
                title: TextTranslator(_settingContext.languages[position],),
                trailing: Icon(Icons.keyboard_arrow_right),
              onTap: (){
                _settingContext.languageCodeRestaurant = code;
                RouteUtil.goBack(context: context);
              },
              );
          }
      ),
    );
  }

  String _codeCountry(String code){
    switch(code){
      case "en":
        return 'us';
        case 'ja':
          return 'jp';
      case 'zh':
        return 'cn';
        case 'ko':
          return 'kr';
    }
    return code;
  }

}
