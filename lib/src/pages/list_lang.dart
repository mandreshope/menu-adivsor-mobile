import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/pages/restaurant.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';
import 'package:menu_advisor/src/utils/extensions.dart';

class ListLang extends StatelessWidget {
  final List langFromQRcode;
  final String restaurant;
  final bool withPrice;
  ListLang({
    Key key,
    this.langFromQRcode,
    this.restaurant,
    this.withPrice = true,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    SettingContext _settingContext = Provider.of<SettingContext>(context, listen: true);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: TextTranslator(
          "Langues".toUpperCase(),
        ),
      ),
      body: ListView.separated(
          itemCount: langFromQRcode?.length ?? _settingContext.supportedLanguages.length,
          separatorBuilder: (_, position) {
            return Divider();
          },
          itemBuilder: (_, position) {
            String code;
            if (langFromQRcode != null) {
              code = langFromQRcode[position];
            } else {
              code = _settingContext.supportedLanguages[position];
            }

            return ListTile(
              leading: Flag.fromString(
                code.codeCountry,
                height: 50,
                width: 50,
              ),
              title: TextTranslator(
                _settingContext.languages[position],
              ),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                if (langFromQRcode != null) {
                  showDialogProgress(context);
                  _settingContext.setlanguageCodeRestaurant(code).then((value) {
                    dismissDialogProgress(context);
                    RouteUtil.goTo(
                      context: context,
                      child: RestaurantPage(
                        restaurant: restaurant,
                        withPrice: withPrice,
                        fromQrcode: true,
                      ),
                      routeName: restaurantRoute,
                      method: RoutingMethod.replaceLast,
                    );
                  });
                  return;
                }
                showDialogProgress(context);
                _settingContext.setlanguageCodeRestaurant(code).then((value) {
                  dismissDialogProgress(context);
                  RouteUtil.goBack(context: context);
                });
              },
            );
          }),
    );
  }
}
