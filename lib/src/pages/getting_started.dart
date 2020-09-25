import 'package:flutter/material.dart';
import 'package:menu_advisor/src/components/logo.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/pages/home.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/utils/routing.dart';

class GettingStartedPage extends StatefulWidget {
  @override
  _GettingStartedPageState createState() => _GettingStartedPageState();
}

class _GettingStartedPageState extends State<GettingStartedPage> {
  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
    viewportFraction: 1,
  );
  double currentPage = 0.0;
  int totalPage = 3;

  @override
  void initState() {
    super.initState();

    pageController.addListener(() {
      setState(() {
        currentPage = pageController.page;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              allowImplicitScrolling: true,
              controller: pageController,
              itemCount: totalPage,
              itemBuilder: (context, index) {
                return Stack(
                  fit: StackFit.expand,
                  children: [],
                );
              },
            ),

            // Top part
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                  left: 20.0,
                  right: 40.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FlatButton(
                      child: Text(
                        "Passer".toUpperCase(),
                        style: TextStyle(
                          color: CRIMSON,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
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
                    MenuAdvisorTextLogo(
                      fontSize: 40,
                      color: CRIMSON,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
