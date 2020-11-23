import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu_advisor/src/animations/FadeAnimation.dart';
import 'package:menu_advisor/src/components/inputs.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/constants/validators.dart';
import 'package:menu_advisor/src/providers/AuthContext.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  bool loading = false;

  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  FocusNode oldPasswordFocus = FocusNode();
  FocusNode newPasswordFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();

  GlobalKey<FormState> formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextTranslator(
          AppLocalizations.of(context).translate('change_password'),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage("assets/images/login-background.png"),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: // Form
            Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              FadeAnimation(
                0.8,
                Container(
                  padding: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width - 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white70,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PasswordField(
                        controller: oldPasswordController,
                        focusNode: oldPasswordFocus,
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        labelText: AppLocalizations.of(context)
                            .translate("enter_old_password_placeholder"),
                        onFieldSubmitted: (_) {
                          oldPasswordFocus.unfocus();
                          FocusScope.of(context).requestFocus(newPasswordFocus);
                        },
                        validator: Validators.required(context),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      PasswordField(
                        controller: newPasswordController,
                        focusNode: newPasswordFocus,
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        labelText: AppLocalizations.of(context)
                            .translate("enter_new_password_placeholder"),
                        onFieldSubmitted: (_) {
                          newPasswordFocus.unfocus();
                          FocusScope.of(context)
                              .requestFocus(confirmPasswordFocus);
                        },
                        validator: Validators.required(context),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      PasswordField(
                        controller: confirmPasswordController,
                        focusNode: confirmPasswordFocus,
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        labelText: AppLocalizations.of(context)
                            .translate("confirm_password_placeholder"),
                        onFieldSubmitted: (_) => _submitForm(),
                        validator: (String value) {
                          if (value.isEmpty)
                            return AppLocalizations.of(context)
                                .translate('field_must_not_be_blank');

                          if (value != newPasswordController.value.text)
                            return AppLocalizations.of(context)
                                .translate('password_does_not_match');

                          return null;
                        },
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
            ],
          ),
        ),
        // End form
      ),
    );
  }

  _submitForm() async {
    FormState formState = formKey.currentState;

    if (!formState.validate()) return;

    String oldPassword = oldPasswordController.value.text,
        newPassword = newPasswordController.value.text;

    AuthContext authContext = Provider.of<AuthContext>(
      context,
      listen: false,
    );

    setState(() {
      loading = true;
    });

    try {
      await authContext.updatePassword(
        oldPassword,
        newPassword,
      );
      setState(() {
        loading = true;
      });
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translate('success'),
      );
      RouteUtil.goBack(context: context);
    } catch (error) {
      setState(() {
        loading = false;
      });
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translate('invalid_password'),
      );
    }
  }
}
