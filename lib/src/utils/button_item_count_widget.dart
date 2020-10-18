import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/components/buttons.dart';
import 'package:menu_advisor/src/constants/colors.dart';

class ButtonItemCountWidget extends StatefulWidget {
  ButtonItemCountWidget(
      {@required this.onAdded,
      @required this.onRemoved,
      @required this.itemCount,this.isFromDelevery = false})
      : super();
  Function onAdded;
  Function onRemoved;
  int itemCount;
  bool isFromDelevery;

  @override
  _ButtonItemCountWidgetState createState() => _ButtonItemCountWidgetState();
}

class _ButtonItemCountWidgetState extends State<ButtonItemCountWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.isFromDelevery ? 15:5),
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
              size: widget.isFromDelevery ? 12 : 25,
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
            child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  '${widget.itemCount}',
                  style: TextStyle(
                    color: CRIMSON,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
              size: widget.isFromDelevery ? 12 : 25,
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
