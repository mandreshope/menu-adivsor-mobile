import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/utils/extensions.dart';
import 'package:menu_advisor/src/utils/textFormFieldTranslator.dart';
import 'package:provider/provider.dart';

class PhoneField extends StatelessWidget {
  final TextEditingController textEditingController;
  final InputDecoration decoration;
  final FocusNode focusNode;
  final String labelText;
  final String hintText;
  final PhoneNumber initialValue;
  final Function(PhoneNumber) onInputChanged;
  final Function(bool) onInputValidated;
  final Function(PhoneNumber) onSaved;
  PhoneField({
    Key key,
    this.decoration,
    this.focusNode,
    this.hintText,
    this.labelText,
    this.onInputChanged,
    this.onSaved,
    this.initialValue,
    this.onInputValidated,
    this.textEditingController,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<SettingContext>(context, listen: false)
        .languageCodeTranslate;
    return FutureBuilder<String>(
        future: labelText != null
            ? labelText.translator(lang)
            : hintText.translator(lang),
        builder: (context, snapshot) {
          return InternationalPhoneNumberInput(
            textFieldController: textEditingController,
            focusNode: focusNode,
            onInputChanged: onInputChanged,
            onInputValidated: onInputValidated,
            selectorConfig: SelectorConfig(
              selectorType: PhoneInputSelectorType.DIALOG,
            ),
            ignoreBlank: false,
            autoValidateMode: AutovalidateMode.disabled,
            selectorTextStyle: TextStyle(color: Colors.black),
            initialValue: initialValue,
            // textFieldController: _emailController,
            formatInput: false,
            inputDecoration: labelText != null
                ? InputDecoration(
                    labelText: snapshot.data,
                    hintText: hintText,
                  )
                : decoration,
            keyboardType:
                TextInputType.numberWithOptions(signed: true, decimal: true),
            onSaved: onSaved,
          );
        });
  }
}

class PasswordField extends StatefulWidget {
  final FocusNode focusNode;
  final TextEditingController controller;
  final String labelText;
  final InputDecoration decoration;
  final TextInputType keyboardType;
  final void Function(String) onFieldSubmitted;
  final bool obscureText;
  final TextInputAction textInputAction;
  final String Function(String) validator;

  PasswordField({
    Key key,
    this.focusNode,
    this.controller,
    this.labelText,
    this.onFieldSubmitted,
    this.decoration,
    this.keyboardType,
    this.obscureText = false,
    this.textInputAction = TextInputAction.next,
    this.validator,
  }) : super(key: key);

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool obscureText;

  @override
  void initState() {
    super.initState();

    obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormFieldTranslator(
      focusNode: widget.focusNode,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: obscureText,
      textInputAction: widget.textInputAction,
      suffixIcon: IconButton(
        onPressed: () => setState(() {
          obscureText = !obscureText;
        }),
        icon: FaIcon(
          obscureText ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
        ),
      ),
      decoration: InputDecoration(
        labelText: widget.labelText,
      ),
      onFieldSubmitted: widget.onFieldSubmitted,
      validator: widget.validator,
    );
  }
}
