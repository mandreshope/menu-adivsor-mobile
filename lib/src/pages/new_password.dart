import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu_advisor/src/components/inputs.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/constants/validators.dart';
import 'package:menu_advisor/src/pages/login.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textFormFieldTranslator.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';

class NewPasswordPage extends StatefulWidget {
  final String token;
  final String email;

  const NewPasswordPage({
    Key key,
    this.token,
    this.email,
  }) : super(key: key);

  @override
  _NewPasswordPageState createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _codeFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  GlobalKey<FormState> _formKey = GlobalKey();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage("assets/images/login-background.png"),
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                          AppLocalizations.of(context)
                              .translate("enter_code_sms")
                              .replaceFirst('*', widget.email),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        TextFormFieldTranslator(
                          controller: _codeController,
                          focusNode: _codeFocus,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          onFieldSubmitted: (_) {
                            _codeFocus.unfocus();
                            FocusScope.of(context).requestFocus(_passwordFocus);
                          },
                          decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                          ),
                          validator: Validators.required(context),
                        ),
                        SizedBox(height: 5),
                        TextTranslator(
                          AppLocalizations.of(context)
                              .translate("new_password"),
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
                            FocusScope.of(context)
                                .requestFocus(_confirmPasswordFocus);
                          },
                          decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                          ),
                          validator: Validators.required(context),
                          labelText: "",
                        ),
                        SizedBox(height: 10),
                        TextTranslator(
                          AppLocalizations.of(context)
                              .translate("confirm_password_placeholder"),
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
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                          ),
                          validator: Validators.required(context),
                          labelText: "",
                        ),
                        SizedBox(height: 30),
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
                                      .translate("confirm"),
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
      int code = int.parse(_codeController.value.text);
      String newPassword = _passwordController.value.text;
      String confirmNewPassword = _confirmPasswordController.value.text;

      // if (_codeController.value.text.length != 4) {
      //   setState(() {
      //     loading = false;
      //   });
      //   return Fluttertoast.showToast(
      //     msg: AppLocalizations.of(context).translate('invalid_code'),
      //   );
      // }

      if (newPassword != confirmNewPassword) {
        setState(() {
          loading = false;
        });
        return Fluttertoast.showToast(
          msg:
              AppLocalizations.of(context).translate('password_does_not_match'),
        );
      }

      AuthContext authContext =
          Provider.of<AuthContext>(context, listen: false);

      try {
        setState(() {
          loading = true;
        });
        var result = await authContext.confirmResetPassword(
          code: code,
          token: widget.token,
          password: newPassword,
        );
        setState(() {
          loading = false;
        });
        if (result != null) {
          Fluttertoast.showToast(
            msg: AppLocalizations.of(context).translate('success'),
          );
          RouteUtil.goTo(
            context: context,
            child: LoginPage(),
            routeName: loginRoute,
            method: RoutingMethod.atTop,
          );
        } else {
          Fluttertoast.showToast(
            msg: AppLocalizations.of(context).translate('invalid_code'),
          );
        }
      } catch (error) {
        setState(() {
          loading = false;
        });
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context).translate('connection_error'),
        );
      }
    }
  }
}
