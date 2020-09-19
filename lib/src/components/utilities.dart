import 'package:flutter/material.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/pages/home.dart';
import 'package:menu_advisor/src/pages/profile.dart';
import 'package:menu_advisor/src/pages/qr_code_scan.dart';
import 'package:menu_advisor/src/providers/RouteContext.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:page_transition/page_transition.dart';
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

  const ScaffoldWithBottomMenu({
    Key key,
    @required this.body,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      body: body,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: 65,
        height: 65,
        child: Consumer<RouteContext>(
          builder: (_, routeContext, __) {
            return FittedBox(
              child: FloatingActionButton(
                backgroundColor: CRIMSON,
                onPressed: () {},
                tooltip: routeContext.currentRoute,
                child: Icon(
                  Icons.home,
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
                child: IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.home,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    RouteUtil.goTo(
                      context: context,
                      child: HomePage(),
                    );
                  },
                ),
              ),
              Expanded(
                child: IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.qrcode,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    RouteUtil.goTo(
                      context: context,
                      child: QRCodeScanPage(),
                      transitionType: PageTransitionType.rightToLeftWithFade,
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
                  onPressed: () {},
                ),
              ),
              Expanded(
                child: IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.user,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    RouteUtil.goTo(
                      context: context,
                      child: ProfilePage(),
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
