import 'dart:ui';

import 'package:flag/flag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu_advisor/src/animations/FadeAnimation.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/components/inputs.dart';
import 'package:menu_advisor/src/components/logo.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/constants/constant.dart';
import 'package:menu_advisor/src/pages/forgot_password.dart';
import 'package:menu_advisor/src/pages/home.dart';
import 'package:menu_advisor/src/pages/order.dart';
import 'package:menu_advisor/src/pages/signup.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textFormFieldTranslator.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';
import 'package:menu_advisor/src/utils/extensions.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool loading = false;
  bool isPasswordRemember = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage("assets/images/login-background.png"),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top banner
                FadeAnimation(
                  0.4,
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(100),
                        bottomRight: Radius.circular(100),
                      ),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        MenuAdvisorLogo(
                          size: 70,
                        ),
                        MenuAdvisorTextLogo(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          color: CRIMSON,
                          fontSize: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                // end top banner

                // Form
                FadeAnimation(
                  0.8,
                  Container(
                    padding: EdgeInsets.all(30),
                    width: MediaQuery.of(context).size.width - 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white70,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: TextTranslator(
                            AppLocalizations.of(context).translate("welcome"),
                            style: TextStyle(
                              fontFamily: 'Golden Ranger',
                              color: CRIMSON,
                              fontSize: 45,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextTranslator(
                          "Langage",
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        Consumer<SettingContext>(builder: (context, settingContext, _) {
                          return DropdownButton<String>(
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
                              for (int i = 0; i < settingContext.supportedLanguages.length; i++)
                                DropdownMenuItem<String>(
                                  value: settingContext.supportedLanguages[i],
                                  child: ListTile(
                                    leading: Flag.fromString(
                                      settingContext.supportedLanguages[i].toString().codeCountry,
                                      height: 25,
                                      width: 25,
                                    ),
                                    title: TextTranslator(
                                      settingContext.languages[i],
                                    ),
                                  ),
                                ),
                            ],
                          );
                        }),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormFieldTranslator(
                          focusNode: _emailFocus,
                          controller: _emailController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: "Votre numéro de téléphone",
                            prefixText: phonePrefix,
                          ),
                          onFieldSubmitted: (_) {
                            _emailFocus.unfocus();
                            FocusScope.of(context).requestFocus(_passwordFocus);
                          },
                        ),
                        SizedBox(height: 20),
                        PasswordField(
                          focusNode: _passwordFocus,
                          controller: _passwordController,
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          labelText: AppLocalizations.of(context).translate("password_placeholder"),
                          onFieldSubmitted: (_) => _submitForm(),
                        ),
                        // SizedBox(height: 25),
                        Row(
                          children: [
                            Checkbox(
                                value: isPasswordRemember,
                                activeColor: CRIMSON,
                                onChanged: (value) {
                                  setState(() {
                                    isPasswordRemember = value;
                                  });
                                }),
                            TextTranslator(
                              AppLocalizations.of(context).translate("remember_password"),
                            )
                          ],
                        ),

                        SizedBox(height: 20),
                        ElevatedButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                              EdgeInsets.all(15),
                            ),
                            backgroundColor: MaterialStateProperty.all(
                              CRIMSON,
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          onPressed: _submitForm,
                          child: loading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: FittedBox(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : TextTranslator(
                                  AppLocalizations.of(context).translate("login_button"),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                        ),
                        SizedBox(height: 10),
                        TextButton(
                          child: TextTranslator(
                            AppLocalizations.of(context).translate("forgotten_password"),
                            style: TextStyle(
                              color: CRIMSON,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          onPressed: () {
                            RouteUtil.goTo(
                              context: context,
                              child: ForgotPasswordPage(),
                              routeName: forgotPasswordRoute,
                            );
                          },
                        ),
                        TextButton(
                          child: TextTranslator(
                            AppLocalizations.of(context).translate("skip_for_now"),
                          ),
                          onPressed: () {
                            RouteUtil.goTo(
                              context: context,
                              child: HomePage(),
                              routeName: homeRoute,
                              method: RoutingMethod.atTop,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // End form

                // Create account button part
                FadeAnimation(
                  0.8,
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 22,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        stops: [
                          0,
                          .6,
                        ],
                        colors: [
                          Colors.white.withOpacity(0),
                          Colors.white60,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: InkWell(
                        onTap: () {
                          RouteUtil.goTo(
                            context: context,
                            child: SignupPage(),
                            routeName: signupRoute,
                          );
                        },
                        child: TextTranslator(
                          AppLocalizations.of(context).translate("create_account"),
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: CRIMSON,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // -------------------------
              ],
            ),
          ),
        ),
      ),
    );
  }

  _submitForm() async {
    print("$logTrace");
    final String email = phonePrefix + _emailController.value.text, password = _passwordController.value.text;

    if (email.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translate("blank_email_or_password"),
        backgroundColor: CRIMSON,
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      loading = true;
    });

    AuthContext authContext = Provider.of<AuthContext>(
      context,
      listen: false,
    );
    CartContext cartContext = Provider.of<CartContext>(
      context,
      listen: false,
    );
    try {
      final result = await authContext.login(email.trim(), password, isPasswordRemember: isPasswordRemember);
      if (result) {
        if (cartContext.itemCount > 0)
          RouteUtil.goTo(
            context: context,
            child: OrderPage(),
            routeName: orderRoute,
            method: RoutingMethod.replaceLast,
          );
        else
          RouteUtil.goTo(
            context: context,
            child: HomePage(),
            routeName: homeRoute,
            method: RoutingMethod.atTop,
          );
      }
    } catch (error) {
      print("$logTrace login error $error");
      if (error.contains("Incorrect phone number or password")) {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context).translate("invalid_email_or_password"),
          backgroundColor: CRIMSON,
          textColor: Colors.white,
        );
      } else {
        Fluttertoast.showToast(
          msg: await (error as String).translator(Provider.of<SettingContext>(context, listen: false).languageCode),
          backgroundColor: CRIMSON,
          textColor: Colors.white,
        );
      }
    } finally {
      setState(() {
        loading = false;
      });
    }
  }
}
