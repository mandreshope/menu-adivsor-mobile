import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/pages/summary.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';

class ConfirmCommand extends StatefulWidget {
  ConfirmCommand({Key key,this.command}) : super(key: key);
  Command command;
  @override
  _ConfirmCommandState createState() => _ConfirmCommandState();
}

class _ConfirmCommandState extends State<ConfirmCommand> {
  TextEditingController _codeController = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextTranslator("Confirme commande"),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 150,),
            TextTranslator(
              "Code de validation sms",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 75),
              child: TextFormField(
                controller: _codeController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                onFieldSubmitted: (_) {
                  
                },
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            ),
            
                      SizedBox(height: 20),
                      RaisedButton(
                        padding: EdgeInsets.all(15),
                        color: CRIMSON,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onPressed: () async {
                          if (_codeController.value.text.isEmpty){
                           Fluttertoast.showToast(
                                    msg: "Entrer votre code",
                                    backgroundColor: CRIMSON,
                                    textColor: Colors.white,
                                  );
                          }else{
                              setState(() {
                                loading = true;
                              });
                            await Api.instance.confirmCommande(widget.command.id, _codeController.text);
                              setState(() {
                                loading = false;
                              });
                              RouteUtil.goTo(context: context,
                               child: Summary(commande: widget.command), routeName: confirmEmailRoute,);
                          }
                        },
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
                                "Valider",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                      ),
          ],
        ),
      ),
    );
  }
}
