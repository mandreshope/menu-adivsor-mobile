import 'package:flutter/material.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;

  const ConfirmationDialog({
    Key key,
    @required this.title,
    @required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
      ),
      content: Text(
        content,
      ),
      actions: [
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text(
            AppLocalizations.of(context).translate('cancel'),
          ),
        ),
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: Text(
            AppLocalizations.of(context).translate("confirm"),
          ),
        ),
      ],
    );
  }
}
