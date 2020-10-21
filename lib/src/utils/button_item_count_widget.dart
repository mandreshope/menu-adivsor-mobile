import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu_advisor/src/components/buttons.dart';
import 'package:menu_advisor/src/constants/colors.dart';

class ButtonItemCountWidget extends StatefulWidget {
  ButtonItemCountWidget(
      {@required this.onAdded,
      @required this.onRemoved,
      @required this.itemCount,
      this.isFromDelevery = false,
      @required this.isContains = false})
      : super();
  Function onAdded;
  Function onRemoved;
  int itemCount;
  bool isFromDelevery;
  bool isContains;

  @override
  _ButtonItemCountWidgetState createState() => _ButtonItemCountWidgetState();
}

class _ButtonItemCountWidgetState extends State<ButtonItemCountWidget> {
  @override
  Widget build(BuildContext context) {
    if (!widget.isContains)
    return CircleButton(
        backgroundColor: TEAL,
        onPressed: () {
          // setState(() {
                  widget.onAdded(++widget.itemCount);
                // });
        },
        child: FaIcon(
          FontAwesomeIcons.plus,
          color: Colors.white,
          size: 12,
        ));
    return Container(
      decoration: BoxDecoration(
          color: CRIMSON,
          borderRadius: BorderRadius.all(
            Radius.circular(3),
          )),
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: widget.isFromDelevery ? 0 : 0),
        child: Row(
          children: [
            RoundedButton(
              backgroundColor: CRIMSON,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              radius: 0.0,
              child: FaIcon(
                FontAwesomeIcons.minus,
                color: Colors.white,
                size: 12,
              ),
              onPressed: 
                   () {
                    // if (widget.itemCount > 1)
                      // setState(() {
                        widget.onRemoved(--widget.itemCount);
                      // });
                    },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Container(
                decoration: BoxDecoration(
                  //shape: BoxShape.circle,
                  color: Colors.white,
                ),
                padding: EdgeInsets.symmetric(vertical: 6),
                width: 35,
                child: Center(
                  child: Text(
                    '${widget.itemCount}',
                    style: TextStyle(
                      color: CRIMSON,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            RoundedButton(
              backgroundColor: CRIMSON,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              radius: 0.0,
              child: FaIcon(
                FontAwesomeIcons.plus,
                color: Colors.white,
                size: widget.isFromDelevery ? 12 : 12,
              ),
              onPressed: () {
                // setState(() {
                  widget.onAdded(++widget.itemCount);
                // });
              },
            ),
          ],
        ),
      ),
    );
  }
}
