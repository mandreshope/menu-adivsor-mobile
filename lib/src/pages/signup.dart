import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu_advisor/src/components/logo.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/pages/confirm_email.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:provider/provider.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FocusNode _phoneNumberFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage("assets/images/login-background.png"),
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    // Top banner
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
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                    // End top banner

                    SizedBox(
                      height: 60,
                    ),

                    // Form
                    Container(
                      width: MediaQuery.of(context).size.width - 60,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white70,
                      ),
                      child: Theme(
                        data: ThemeData(
                          inputDecorationTheme: InputDecorationTheme(
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              AppLocalizations.of(context)
                                  .translate("add_phone_number"),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            TextFormField(
                              controller: _phoneNumberController,
                              focusNode: _phoneNumberFocus,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.phone,
                              onFieldSubmitted: (_) {
                                _phoneNumberFocus.unfocus();
                                FocusScope.of(context)
                                    .requestFocus(_emailFocus);
                              },
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 10),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              AppLocalizations.of(context)
                                  .translate("mail_address_placeholder"),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            TextFormField(
                              controller: _emailController,
                              focusNode: _emailFocus,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.emailAddress,
                              onFieldSubmitted: (_) {
                                _emailFocus.unfocus();
                                FocusScope.of(context)
                                    .requestFocus(_passwordFocus);
                              },
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 10),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              AppLocalizations.of(context)
                                  .translate("password_placeholder"),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            TextFormField(
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              obscureText: true,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.text,
                              onFieldSubmitted: (_) {
                                _passwordFocus.unfocus();
                                FocusScope.of(context)
                                    .requestFocus(_confirmPasswordFocus);
                              },
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 10),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              AppLocalizations.of(context)
                                  .translate("confirm_password_placeholder"),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            TextFormField(
                              controller: _confirmPasswordController,
                              focusNode: _confirmPasswordFocus,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
                              onFieldSubmitted: (_) {
                                _confirmPasswordFocus.unfocus();
                                _submitForm();
                              },
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 10),
                              ),
                            ),
                            SizedBox(height: 30),
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
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Text(
                                      AppLocalizations.of(context)
                                          .translate("next"),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // End form
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    String email = _emailController.value.text,
        phoneNumber = _phoneNumberController.value.text,
        password = _passwordController.value.text,
        confirmPassword = _confirmPasswordController.value.text;

    if (password != confirmPassword) {
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)
              .translate("password_does_not_match"));
    } else {
      setState(() {
        loading = true;
      });
      AuthContext authContext =
          Provider.of<AuthContext>(context, listen: false);
      authContext
          .signup(
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      )
          .then((value) {
        print('Danze: ' + value.runtimeType.toString());
        setState(() {
          loading = false;
        });
        RouteUtil.goTo(
          context: context,
          child: ConfirmEmailPage(),
          routeName: confirmEmailRoute,
        );
      }).catchError((error) {
        print('Danze: ' + error.runtimeType.toString());
        setState(() {
          loading = false;
        });
        if ((error['details'] as Map<String, String>).containsKey("email"))
          Fluttertoast.showToast(
              msg: AppLocalizations.of(context)
                  .translate("email_already_in_use"));
        else if ((error['details'] as Map<String, String>)
            .containsKey("phoneNumber"))
          Fluttertoast.showToast(
              msg: AppLocalizations.of(context)
                  .translate("phone_number_already_in_use"));
      });
    }
  }
}
