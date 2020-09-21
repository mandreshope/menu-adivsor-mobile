import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:menu_advisor/src/components/logo.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/pages/home.dart';
import 'package:menu_advisor/src/pages/signup.dart';
import 'package:menu_advisor/src/providers/RouteContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:provider/provider.dart';
import 'package:supercharged/supercharged.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage("assets/images/login-background.png"),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 30,
                  horizontal: 30,
                ),
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
                      child: Text(
                        "Bienvenu",
                        style: TextStyle(
                          fontFamily: 'Golden Ranger',
                          color: CRIMSON,
                          fontSize: 50,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    TextFormField(
                      focusNode: _emailFocus,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: "Votre adresse mail",
                      ),
                      onFieldSubmitted: (_) {
                        _emailFocus.unfocus();
                        FocusScope.of(context).requestFocus(_passwordFocus);
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      focusNode: _passwordFocus,
                      controller: _passwordController,
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: "Mot de passe",
                      ),
                      onFieldSubmitted: (_) => _submitForm(),
                    ),
                    SizedBox(height: 40),
                    RaisedButton(
                      padding: EdgeInsets.all(15),
                      color: CRIMSON,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onPressed: _submitForm,
                      child: loading
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: FittedBox(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                          )
                          : Text(
                              "Connexion",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                    ),
                    SizedBox(height: 10),
                    FlatButton(
                      child: Text("Passer pour le moment"),
                      onPressed: () {
                        print("Passer...");
                        RouteUtil.goTo(
                          context: context,
                          child: HomePage(),
                          routeName: homeRoute,
                          method: RouteMethod.atTop,
                        );
                      },
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 30,
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
                    child: Text(
                      "Créer un compte",
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
            ],
          ),
        ),
      ),
    );
  }

  _submitForm() {
    print('Loging in...');
    setState(() {
      loading = true;
    });
  }
}
