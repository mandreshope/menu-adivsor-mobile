import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/components/buttons.dart';

class ButtonItemCountWidget extends StatefulWidget {
  ButtonItemCountWidget(
      {@required this.onAdded,
      @required this.onRemoved,
      @required this.itemCount})
      : super();
  Function onAdded;
  Function onRemoved;
  int itemCount;

  @override
  _ButtonItemCountWidgetState createState() => _ButtonItemCountWidgetState();
}

class _ButtonItemCountWidgetState extends State<ButtonItemCountWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Row(
        children: [
          CircleButton(
            backgroundColor: Colors.transparent,
            border: Border.all(
              width: 1,
              color: Colors.grey,
            ),
            child: FaIcon(
              FontAwesomeIcons.minus,
              color: Colors.black,
            ),
            onPressed: widget.itemCount > 1
                ? () {
                    setState(() {
                      widget.onRemoved(--widget.itemCount);
                    });
                  }
                : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              widget.itemCount.toString(),
            ),
          ),
          CircleButton(
            backgroundColor: Colors.transparent,
            border: Border.all(
              width: 1,
              color: Colors.grey,
            ),
            child: FaIcon(
              FontAwesomeIcons.plus,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                widget.onAdded(++widget.itemCount);
              });
            },
          ),
        ],
      ),
    );
  }
}
