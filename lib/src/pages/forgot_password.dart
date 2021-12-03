import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:menu_advisor/src/animations/FadeAnimation.dart';
import 'package:menu_advisor/src/components/inputs.dart';
import 'package:menu_advisor/src/components/logo.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/constants/constant.dart';
import 'package:menu_advisor/src/pages/new_password.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final FocusNode _emailFocus = FocusNode();
  final TextEditingController _emailController = TextEditingController();

  bool loading = false;
  GlobalKey<FormState> _formKey = GlobalKey();

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
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.max,
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

                SizedBox(
                  height: 40,
                ),

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
                        TextTranslator(
                          AppLocalizations.of(context)
                              .translate("forgot_password"),
                          style: TextStyle(
                            color: CRIMSON,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        PhoneField(
                          focusNode: _emailFocus,
                          initialValue: phoneInitialCountryCode,
                          onInputChanged: (PhoneNumber number) {
                            print(number.phoneNumber);
                            _emailController.text = number.phoneNumber;
                          },
                          onInputValidated: (bool value) {
                            print(value);
                          },
                          onSaved: (PhoneNumber number) {
                            _emailFocus.unfocus();
                            _submitForm();
                          },
                          labelText: "Votre numéro de téléphone",
                        ),
                        SizedBox(height: 15),
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
        ),
      ),
    );
  }

  _submitForm() async {
    FormState formState = _formKey.currentState;
    if (formState.validate()) {
      final String email = _emailController.value.text;

      setState(() {
        loading = true;
      });

      AuthContext authContext = Provider.of<AuthContext>(
        context,
        listen: false,
      );

      try {
        final String token = await authContext.resetPassword(email);
        setState(() {
          loading = false;
        });
        RouteUtil.goTo(
          context: context,
          child: NewPasswordPage(
            token: token,
            email: email,
          ),
          routeName: newPasswordRoute,
        );
      } catch (error) {
        print(error);
        Fluttertoast.showToast(
          msg: error,
          backgroundColor: CRIMSON,
          textColor: Colors.white,
        );
        // Fluttertoast.showToast(
        //   msg: AppLocalizations.of(context).translate("invalid_email"),
        //   backgroundColor: CRIMSON,
        //   textColor: Colors.white,
        // );
      } finally {
        setState(() {
          loading = false;
        });
      }
    }
  }
}
