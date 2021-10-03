import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/components/utilities.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/pages/cgc.dart';
import 'package:menu_advisor/src/pages/change_password.dart';
import 'package:menu_advisor/src/pages/favorites.dart';
import 'package:menu_advisor/src/pages/login.dart';
import 'package:menu_advisor/src/pages/payment_card_list.dart';
import 'package:menu_advisor/src/pages/profile_edit.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/providers/CommandContext.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';
import 'package:menu_advisor/src/utils/extensions.dart';

import '../models/models.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<String> _supportedLanguages = [
    'system',
    'fr',
    'ko',
  ];
  List<String> _languages = [
    'system_setting',
    'Français',
    'English',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingContext>(
      builder: (_, settingContext, __) {
        // String languageCode = settingContext.languageCode;
        // bool isSystemSetting = settingContext.isSystemSetting;
        _languages = settingContext.languages;
        _supportedLanguages = settingContext.supportedLanguages;

        return ScaffoldWithBottomMenu(
          appBar: AppBar(
            title: TextTranslator(
              AppLocalizations.of(context).translate('profile_and_settings'),
            ),
            actions: [
              IconButton(
                tooltip: AppLocalizations.of(context).translate('signout'),
                onPressed: () async {
                  await Provider.of<AuthContext>(
                    context,
                    listen: false,
                  ).logout();

                  Provider.of<CommandContext>(
                    context,
                    listen: false,
                  ).clear();

                  Provider.of<CartContext>(
                    context,
                    listen: false,
                  ).clear();

                  Provider.of<SettingContext>(context, listen: false).resetLanguage();

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
          body: Container(
            height: double.infinity,
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 110,
                    color: Colors.grey.withAlpha(50),
                    child: Consumer<AuthContext>(
                      builder: (_, authContext, __) => authContext.currentUser != null
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    /*CircleAvatar(
                                      radius: 60,
                                      backgroundColor: Colors.white,
                                      child: authContext.currentUser?.photoURL == null ?? true
                                          ? Icon(
                                              Icons.person,
                                              color: Colors.black,
                                              size: 50,
                                            )
                                          : Image.asset(
                                              authContext.currentUser.photoURL,
                                            ),
                                    ),*/
                                    SizedBox(
                                      height: 10,
                                    ),
                                    TextTranslator(
                                      authContext.currentUser.phoneNumber,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    TextTranslator(
                                      authContext.currentUser.name.first.length != 0 ? authContext.currentUser.name.first : AppLocalizations.of(context).translate('no_firstname'),
                                    ),
                                    TextTranslator(
                                      authContext.currentUser.name.last.length != 0 ? authContext.currentUser.name.last : AppLocalizations.of(context).translate('no_lastname'),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.location_on_sharp,
                                        ),
                                        TextTranslator(
                                          authContext.currentUser.address ?? AppLocalizations.of(context).translate('no_address'),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                /*Positioned(
                                  right: 10,
                                  bottom: 10,
                                  child: FloatingActionButton(
                                    heroTag: 'edit',
                                    mini: true,
                                    onPressed: () {
                                      RouteUtil.goTo(
                                        context: context,
                                        child: ProfileEditPage(),
                                        routeName: profileEditRoute,
                                      );
                                    },
                                    child: Icon(
                                      Icons.edit_outlined,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 10,
                                  bottom: 10,
                                  child: FloatingActionButton(
                                    heroTag: 'message',
                                    mini: true,
                                    onPressed: () {
                                      showDialog<String>(context: context,
                                                  child: MessageDialog(message: "",)).then((value) async {
                                                      print(value);
                                                      //widget.food.message = value;
                                                  
                                                    if (value.isNotEmpty){
                                                        User user =  Provider.of<AuthContext>(
                                                          context,
                                                          listen: false,
                                                        ).currentUser;
                                                      Message message = Message(email: user.email,message: value,name: "${user.name.first} ${user.name.last}", phoneNumber: user.phoneNumber,read: false,
                                                      target: null);
                                                      showDialog(
                                                        barrierDismissible: false,
                                                        context: context,child: Center(
                                                        child: CircularProgressIndicator(
                                                                            valueColor: AlwaysStoppedAnimation<Color>(
                                                                              CRIMSON,
                                                                            ),
                                                                          ),
                                                      ));
                                                      bool result = await Api.instance.sendMessage(message);
                                                      RouteUtil.goBack(context: context);
                                                        
                                                        if (result){
                                                            Fluttertoast.showToast(
                                                                msg: "Message envoyé",
                                                              );
                                                        }else{
                                                            Fluttertoast.showToast(
                                                                msg: "Message non envoyé",
                                                              );
                                                        }
                                                        
                                                      }else{
                                                        
                                                      }
                                                    }   
                                                  );
                                    },
                                    child: Icon(
                                      Icons.comment,
                                    ),
                                  ),
                                ),*/
                              ],
                            )
                          : Container(),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        /* TextTranslator(
                          AppLocalizations.of(context).translate("my_settings"),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),*/
//_profilSettings(),
                        TextTranslator(
                          "Langage",
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        DropdownButton<String>(
                          elevation: 16,
                          isExpanded: true,
                          value: /*isSystemSetting ? 'system' :*/ settingContext.languageCode,
                          onChanged: (String languageCode) {
                            SettingContext settingContext = Provider.of<SettingContext>(
                              context,
                              listen: false,
                            );
                            showDialogProgress(context);
                            settingContext.setlanguageCode(languageCode).then((value) {
                              dismissDialogProgress(context);
                            });
                          },
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                          items: [
                            for (int i = 0; i < _supportedLanguages.length; i++)
                              DropdownMenuItem<String>(
                                value: _supportedLanguages[i],
                                child: ListTile(
                                  leading: Flag.fromString(
                                    _supportedLanguages[i].codeCountry,
                                    height: 25,
                                    width: 25,
                                  ),
                                  title: TextTranslator(
                                    _languages[i],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        /*SizedBox(
                          height: 30,
                        ),
                        TextTranslator(
                          AppLocalizations.of(context).translate("password"),
                          style: Theme.of(context).textTheme.headline6,
                        ),*/
                        SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                          ),
                          onPressed: () {
                            RouteUtil.goTo(
                              context: context,
                              child: ChangePasswordPage(),
                              routeName: changePasswordRoute,
                            );
                          },
                          child: TextTranslator(
                            AppLocalizations.of(context).translate('change_password'),
                            style: GoogleFonts.raleway(
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        /*SizedBox(
                          height: 30,
                        ),
                        TextTranslator(
                          AppLocalizations.of(context)
                              .translate("my_payment_cards"),
                          style: Theme.of(context).textTheme.headline6,
                        ),*/
                        SizedBox(
                          height: 5,
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                          ),
                          onPressed: () {
                            RouteUtil.goTo(
                              context: context,
                              child: PaymentCardListPage(),
                              routeName: paymentCardListRoute,
                            );
                          },
                          child: TextTranslator(
                            AppLocalizations.of(context).translate('manage_cards'),
                            style: GoogleFonts.raleway(
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        /*SizedBox(
                          height: 30,
                        ),
                        TextTranslator(
                          AppLocalizations.of(context).translate("favorites"),
                          style: Theme.of(context).textTheme.headline6,
                        ),*/
                        SizedBox(
                          height: 5,
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                          ),
                          onPressed: () {
                            RouteUtil.goTo(
                              context: context,
                              child: FavoritesPage(),
                              routeName: favoritesRoute,
                            );
                          },
                          child: TextTranslator(
                            AppLocalizations.of(context).translate('view_favorites'),
                            style: GoogleFonts.raleway(
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        /*SizedBox(
                          height: 30,
                        ),
                        TextTranslator(
                          AppLocalizations.of(context)
                              .translate("command_history"),
                          style: Theme.of(context).textTheme.headline6,
                        ),*/
                        SizedBox(
                          height: 5,
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                          ),
                          onPressed: () {
                            RouteUtil.goTo(
                              context: context,
                              child: CGV(
                                title: "CGV",
                              ),
                              routeName: "",
                            );
                          },
                          child: TextTranslator(
                            "CGV",
                            style: GoogleFonts.raleway(
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                          ),
                          onPressed: () {
                            RouteUtil.goTo(
                              context: context,
                              child: CGV(
                                title: "Aide",
                              ),
                              routeName: "",
                            );
                          },
                          child: TextTranslator(
                            "Aide",
                            style: GoogleFonts.raleway(
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                          ),
                          onPressed: () {
                            RouteUtil.goTo(
                              context: context,
                              child: CGV(
                                title: "A propos",
                              ),
                              routeName: "",
                            );
                          },
                          child: TextTranslator(
                            "A propos",
                            style: GoogleFonts.raleway(
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                          ),
                          onPressed: () {
                            RouteUtil.goTo(
                              context: context,
                              child: ProfileEditPage(),
                              routeName: profileEditRoute,
                            );
                          },
                          child: TextTranslator(
                            "Votre adresse",
                            style: GoogleFonts.raleway(
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                          ),
                          onPressed: () {
                            showDialog<String>(
                                context: context,
                                builder: (_) => MessageDialog(
                                      message: "",
                                    )).then((value) async {
                              print(value);
                              //widget.food.message = value;

                              if (value.isNotEmpty) {
                                User user = Provider.of<AuthContext>(
                                  context,
                                  listen: false,
                                ).currentUser;
                                Message message = Message(email: user.email, message: value, name: "${user.name.first} ${user.name.last}", phoneNumber: user.phoneNumber, read: false, target: null);
                                showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (_) => Center(
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              CRIMSON,
                                            ),
                                          ),
                                        ));
                                bool result = await Api.instance.sendMessage(message);
                                RouteUtil.goBack(context: context);

                                if (result) {
                                  Fluttertoast.showToast(
                                    msg: "Message envoyé",
                                  );
                                } else {
                                  Fluttertoast.showToast(
                                    msg: "Message non envoyé",
                                  );
                                }
                              } else {}
                            });
                          },
                          child: TextTranslator(
                            "Envoyer message vers l'admin",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.raleway(
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
