import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/pages/home.dart';
import 'package:menu_advisor/src/pages/login.dart';
import 'package:menu_advisor/src/pages/map.dart';
import 'package:menu_advisor/src/pages/order.dart';
import 'package:menu_advisor/src/pages/profile.dart';
import 'package:menu_advisor/src/pages/qr_code_scan.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:provider/provider.dart';

class SectionTitle extends StatelessWidget {
  final String text;

  const SectionTitle(
    this.text, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headline5,
      ),
    );
  }
}

class ScaffoldWithBottomMenu extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget appBar;

  const ScaffoldWithBottomMenu({
    Key key,
    @required this.body,
    this.appBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: BACKGROUND_COLOR,
      body: body,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: 65,
        height: 65,
        child: FittedBox(
          child: FloatingActionButton(
            backgroundColor: CRIMSON,
            onPressed: () {
              RouteUtil.goTo(
                context: context,
                child: QRCodeScanPage(),
                routeName: qrRoute,
              );
            },
            tooltip: ModalRoute.of(context).settings.name,
            child: FaIcon(
              FontAwesomeIcons.qrcode,
            ),
            elevation: 2.0,
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        elevation: 4.0,
        color: CRIMSON,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.home,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (ModalRoute.of(context).settings.name == homeRoute) return;

                    RouteUtil.goTo(
                      routeName: homeRoute,
                      context: context,
                      child: HomePage(),
                      method: RoutingMethod.atTop,
                    );
                  },
                ),
              ),
              Expanded(
                child: IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.locationArrow,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    RouteUtil.goTo(
                      routeName: mapRoute,
                      context: context,
                      child: MapPage(),
                    );
                  },
                ),
              ),
              Spacer(),
              Expanded(
                child: Consumer<CartContext>(
                  builder: (_, cartContext, __) => IconButton(
                    icon: FaIcon(
                      FontAwesomeIcons.shoppingBag,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      /* showModalBottomSheet(
                        context: context,
                        builder: (_) => BagModal(),
                        backgroundColor: Colors.transparent,
                      );*/
                      if (cartContext.itemCount == 0)
                        Fluttertoast.showToast(
                          msg: AppLocalizations.of(context).translate('empty_cart'),
                        );
                      else
                        RouteUtil.goTo(
                          context: context,
                          child: OrderPage(),
                          routeName: orderRoute,
                        );
                    },
                  ),
                ),
              ),
              Expanded(
                child: IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.user,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    if (ModalRoute.of(context).settings.name == profileRoute) return;

                    AuthContext authContext = Provider.of<AuthContext>(context, listen: false);

                    SettingContext settingContext = Provider.of<SettingContext>(context, listen: false);
                    await settingContext.initialized;

                    if (authContext.currentUser != null)
                      RouteUtil.goTo(
                        routeName: profileRoute,
                        context: context,
                        child: ProfilePage(),
                      );
                    else
                      RouteUtil.goTo(
                        context: context,
                        child: LoginPage(),
                        routeName: loginRoute,
                      );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
