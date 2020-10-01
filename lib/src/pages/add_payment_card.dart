import 'package:flutter/material.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';

class AddPaymentCardPage extends StatefulWidget {
  @override
  _AddPaymentCardPageState createState() => _AddPaymentCardPageState();
}

class _AddPaymentCardPageState extends State<AddPaymentCardPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => ConfirmationDialog(
            title: AppLocalizations.of(context)
                .translate('abandon_change_dialog_title'),
            content: AppLocalizations.of(context)
                .translate('abandon_change_dialog_content'),
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context).translate('card_details'),
          ),
        ),
      ),
    );
  }
}
