import 'package:flutter/material.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/pages/home.dart';
import 'package:menu_advisor/src/pages/login.dart';
import 'package:menu_advisor/src/pages/map.dart';
import 'package:menu_advisor/src/pages/profile.dart';
import 'package:menu_advisor/src/pages/qr_code_scan.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/RouteContext.dart';
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
    final Map<String, Widget> menuButtons = {
      homeRoute: IconButton(
        icon: FaIcon(
          FontAwesomeIcons.home,
          color: Colors.white,
        ),
        onPressed: () {
          RouteUtil.goTo(
            routeName: homeRoute,
            context: context,
            child: HomePage(),
            method: RoutingMethod.atTop,
          );
        },
      ),
      profileRoute: IconButton(
        icon: FaIcon(
          FontAwesomeIcons.user,
          color: Colors.white,
        ),
        onPressed: () {
          AuthContext authContext =
              Provider.of<AuthContext>(context, listen: false);
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
      qrRoute: IconButton(
        icon: FaIcon(
          FontAwesomeIcons.qrcode,
          color: Colors.white,
        ),
        onPressed: () {
          RouteUtil.goTo(
            context: context,
            child: QRCodeScanPage(),
            routeName: qrRoute,
          );
        },
      ),
    };

    return Scaffold(
      appBar: appBar,
      backgroundColor: BACKGROUND_COLOR,
      body: body,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: 65,
        height: 65,
        child: Consumer<RouteContext>(
          builder: (_, routeContext, __) {
            String currentRoute = routeContext.currentRoute;
            IconData iconData;

            switch (currentRoute) {
              case homeRoute:
                iconData = FontAwesomeIcons.home;
                break;

              case profileRoute:
                iconData = FontAwesomeIcons.user;
                break;

              case qrRoute:
                iconData = FontAwesomeIcons.qrcode;
                break;

              default:
                iconData = FontAwesomeIcons.home;
                break;
            }

            return FittedBox(
              child: FloatingActionButton(
                backgroundColor: CRIMSON,
                onPressed: () {},
                tooltip: routeContext.currentRoute,
                child: FaIcon(
                  iconData,
                ),
                elevation: 2.0,
              ),
            );
          },
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
                child: Consumer<RouteContext>(
                  builder: (_, routeContext, __) {
                    if (routeContext.currentRoute == homeRoute)
                      return menuButtons[qrRoute];
                    return menuButtons[homeRoute];
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
                child: IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.shoppingBag,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => BagModal(),
                      backgroundColor: Colors.transparent,
                    );
                  },
                ),
              ),
              Expanded(
                child: Consumer<RouteContext>(
                  builder: (_, routeContext, __) {
                    if (routeContext.currentRoute == profileRoute)
                      return menuButtons[searchRoute];
                    return menuButtons[profileRoute];
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

class BagModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Text(
                AppLocalizations.of(context).translate("in_bag"),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
              ),
            ),
            FlatButton(
              onPressed: () {},
              padding: const EdgeInsets.all(
                20.0,
              ),
              color: Colors.teal,
              child: Text(
                AppLocalizations.of(context).translate("order"),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ]),
    );
  }
}
