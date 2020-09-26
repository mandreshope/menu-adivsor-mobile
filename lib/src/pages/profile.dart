import 'package:flutter/material.dart';
import 'package:menu_advisor/src/components/utilities.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';

class ProfilePage extends StatelessWidget {
  final String language = "Français";
  final List<String> _supportedLanguages = [
    'fr',
    'en',
  ];
  final List<String> _languages = [
    'Français',
    'English',
  ];

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithBottomMenu(
      appBar: AppBar(
        title: Text("Profil et paramètres"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            height: 250,
            child: Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: Colors.black,
                  size: 50,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppLocalizations.of(context).translate("my_settings"),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    AppLocalizations.of(context).translate("language"),
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  DropdownButton<String>(
                      elevation: 16,
                      onChanged: (String languageCode) {

                      },
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                      items: [
                        for (int i = 0; i < _supportedLanguages.length; i++)
                          DropdownMenuItem<String>(
                            value: _supportedLanguages[i],
                            child: Text(
                              _languages[i],
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                      ]),
                  SizedBox(height: 30),
                  Text(
                    AppLocalizations.of(context).translate("my_payment_cards"),
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
