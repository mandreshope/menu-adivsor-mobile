import 'package:flutter/material.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';

class ConfirmEmailPage extends StatefulWidget {
  final String email;
  final String id;

  ConfirmEmailPage({
    Key key,
    @required this.id,
    @required this.email,
  }) : super(key: key);

  @override
  _ConfirmEmailPageState createState() => _ConfirmEmailPageState();
}

class _ConfirmEmailPageState extends State<ConfirmEmailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text(
                  AppLocalizations.of(context)
                      .translate("enter_code")
                      .replaceAll('*', widget.email),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              Text(
                AppLocalizations.of(context).translate("email_not_yours"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CRIMSON,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [],
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.all(20),
                child: RaisedButton(
                  onPressed: _submitForm,
                  child: Text(
                    AppLocalizations.of(context).translate('next'),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
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

  void _submitForm() {}
}
