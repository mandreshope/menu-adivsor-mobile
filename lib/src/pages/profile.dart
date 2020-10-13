import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:menu_advisor/src/components/utilities.dart';
import 'package:menu_advisor/src/pages/login.dart';
import 'package:menu_advisor/src/pages/payment_card_list.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final List<String> _supportedLanguages = [
    'system',
    'fr',
    'en',
  ];
  final List<String> _languages = [
    'system_setting',
    'Français',
    'English',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingContext>(
      builder: (_, settingContext, __) {
        String languageCode = settingContext.languageCode;
        bool isSystemSetting = settingContext.isSystemSetting;

        return ScaffoldWithBottomMenu(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context).translate('profile_and_settings'),
            ),
            actions: [
              IconButton(
                tooltip: AppLocalizations.of(context).translate('signout'),
                onPressed: () async {
                  await Provider.of<AuthContext>(context, listen: false)
                      .logout();

                  Provider.of<SettingContext>(context, listen: false)
                      .resetLanguage();

                  RouteUtil.goTo(
                    context: context,
                    child: LoginPage(),
                    routeName: homeRoute,
                    method: RoutingMethod.atTop,
                  );
                },
                icon: FaIcon(
                  FontAwesomeIcons.signOutAlt,
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
                height: 250,
                child: Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: Consumer<AuthContext>(
                      builder: (_, authContext, __) =>
                          authContext.currentUser?.photoURL == null ?? true
                              ? Icon(
                                  Icons.person,
                                  color: Colors.black,
                                  size: 50,
                                )
                              : Image.asset(
                                  authContext.currentUser.photoURL,
                                ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        AppLocalizations.of(context).translate("my_settings"),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        AppLocalizations.of(context).translate("language"),
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      DropdownButton<String>(
                        elevation: 16,
                        isExpanded: true,
                        value: isSystemSetting ? 'system' : languageCode,
                        onChanged: (String languageCode) {
                          SettingContext settingContext =
                              Provider.of<SettingContext>(context,
                                  listen: false);

                          settingContext.languageCode = languageCode;
                        },
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                        items: [
                          for (int i = 0; i < _supportedLanguages.length; i++)
                            DropdownMenuItem<String>(
                              value: _supportedLanguages[i],
                              child: Text(
                                i == 0
                                    ? AppLocalizations.of(context)
                                        .translate(_languages[i])
                                    : _languages[i],
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        AppLocalizations.of(context)
                            .translate("my_payment_cards"),
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      RaisedButton(
                        onPressed: () {
                          RouteUtil.goTo(
                            context: context,
                            child: PaymentCardListPage(),
                            routeName: paymentCardListRoute,
                          );
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                        child: Text(
                          AppLocalizations.of(context)
                              .translate('manage_cards'),
                          style: GoogleFonts.raleway(
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
