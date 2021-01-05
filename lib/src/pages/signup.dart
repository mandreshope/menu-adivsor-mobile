import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu_advisor/src/components/inputs.dart';
import 'package:menu_advisor/src/components/logo.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/pages/confirm_sms.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';
import 'package:menu_advisor/src/utils/extensions.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
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
                            TextTranslator(
                              "Nom",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            TextFormField(
                              controller: _firstNameController,
                              focusNode: _firstNameFocus,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.name,
                              onFieldSubmitted: (_) {
                                _firstNameFocus.unfocus();
                                FocusScope.of(context).requestFocus(_lastNameFocus);
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                              ),
                            ),
                            SizedBox(height: 10),
                            TextTranslator(
                              "Prénom",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            TextFormField(
                              controller: _lastNameController,
                              focusNode: _lastNameFocus,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.name,
                              onFieldSubmitted: (_) {
                                _lastNameFocus.unfocus();
                                FocusScope.of(context).requestFocus(_phoneNumberFocus);
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                              ),
                            ),
                            SizedBox(height: 10),
                            TextTranslator(
                              AppLocalizations.of(context).translate("add_phone_number"),
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
                              maxLength: 9,
                              onFieldSubmitted: (_) {
                                _phoneNumberFocus.unfocus();
                                FocusScope.of(context).requestFocus(_emailFocus);
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                prefixText: "+33",
                                counter: Offstage(),
                              ),
                            ),
                            SizedBox(height: 10),
                            TextTranslator(
                              AppLocalizations.of(context).translate("mail_address_placeholder"),
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
                                if (_.isValidateEmail()) {
                                  _emailFocus.unfocus();
                                  FocusScope.of(context).requestFocus(_passwordFocus);
                                } else {
                                  _emailFocus.requestFocus();
                                  Fluttertoast.showToast(
                                    msg: AppLocalizations.of(context).translate("invalid_email"),
                                    backgroundColor: CRIMSON,
                                    textColor: Colors.white,
                                  );
                                }
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                              ),
                            ),
                            SizedBox(height: 10),
                            TextTranslator(
                              AppLocalizations.of(context).translate("password_placeholder"),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            PasswordField(
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              obscureText: true,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.text,
                              onFieldSubmitted: (_) {
                                _passwordFocus.unfocus();
                                FocusScope.of(context).requestFocus(_confirmPasswordFocus);
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                              ),
                              labelText: "",
                            ),
                            SizedBox(height: 10),
                            TextTranslator(
                              AppLocalizations.of(context).translate("confirm_password_placeholder"),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            PasswordField(
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
                                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                              ),
                              labelText: "",
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
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                  : TextTranslator(
                                      AppLocalizations.of(context).translate("next"),
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

  _submitForm() async {
    String email = _emailController.value.text,
        phoneNumber = "+261" + _phoneNumberController.value.text,
        password = _passwordController.value.text,
        confirmPassword = _confirmPasswordController.value.text,
        firstName = _firstNameController.value.text,
        lastName = _lastNameController.value.text;

    if (email.length == 0 || firstName.length == 0 || lastName.length == 0 || phoneNumber.length == 0 || password.length == 0 || confirmPassword.length == 0)
      return Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translate('empty_field'),
      );

    if (!email.isValidateEmail()) {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translate("invalid_email"),
        backgroundColor: CRIMSON,
        textColor: Colors.white,
      );
      return;
    }

    if (password != confirmPassword) {
      Fluttertoast.showToast(msg: AppLocalizations.of(context).translate("password_does_not_match"));
    } else {
      setState(() {
        loading = true;
      });
      AuthContext authContext = Provider.of<AuthContext>(context, listen: false);
      try {
        var registrationToken = await authContext.signup(
          email: email,
          phoneNumber: phoneNumber,
          password: password,
          lastName: lastName,
          firstName: firstName
        );
        // authContext.verifyPhoneNumber(phoneNumber,
        //   codeSent: (value){
        //     setState(() {
        //               loading = false;
        //             });
        //             RouteUtil.goTo(
        //               context: context,
        //               child: ConfirmSms(
        //                 verificationId: value,
        //                 isFromSignup: true,
        //                 phoneNumber: phoneNumber,
        //               ),
        //               routeName: confirmEmailRoute,
        //             );
        //       },
        //       verificationFailed: (value){
        //         Fluttertoast.showToast(msg: value);
        //       }
        // );
        
      } catch (error) {
        setState(() {
          loading = false;
        });
        if (error is Map && error.containsKey('details') && (error['details'] as Map<String, dynamic>).containsKey("email"))
          Fluttertoast.showToast(
            msg: AppLocalizations.of(context).translate("email_already_in_use"),
          );
        else if (error is Map && error.containsKey('details') && (error['details'] as Map<String, dynamic>).containsKey("phoneNumber"))
          Fluttertoast.showToast(
            msg: "numéro de téléphone déjà utilisé",
          );
        else
          Fluttertoast.showToast(
            msg: AppLocalizations.of(context).translate("connection_error"),
          );
      }
    }
  }
}
