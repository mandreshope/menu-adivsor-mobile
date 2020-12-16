import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/utils/textFormFieldTranslator.dart';

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
