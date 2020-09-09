import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/style/titan_sytle.dart';

class ClickOvalIconButton extends StatefulWidget {
  String text;
  double height;
  double width;
  double fontSize;
  Function onTap;
  bool isLoading = false;
  Widget child;
  double radius;

  ClickOvalIconButton(
    this.text,
    this.onTap, {
    this.height = 36,
    this.width = 180,
    this.radius,
    this.fontSize = 13,
    this.child,
  });

  @override
  State<StatefulWidget> createState() {
    return _ClickOvalIconButtonState();
  }
}

class _ClickOvalIconButtonState extends State<ClickOvalIconButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(
          widget.radius != null ? widget.radius : widget.height / 2,
        )),
        gradient: getGradient(),
      ),
      child: FlatButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(
              widget.radius != null ? widget.radius : 2.0,
            )),
          ),
          padding: const EdgeInsets.all(0.0),
          child: Row(
            children: <Widget>[
              Spacer(
                flex: 2,
              ),
              Text(
                widget.text,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  color:
                      widget.isLoading ? DefaultColors.color999 : Colors.white,
                ),
              ),
              widget.child != null
                  ? Row(
                      children: <Widget>[
                        SizedBox(
                          width: 4.0,
                        ),
                        widget.child
                      ],
                    )
                  : SizedBox(),
              Spacer(
                flex: 1,
              ),
            ],
          ),
          onPressed: widget.isLoading
              ? null
              : () async {
                  setState(() {
                    widget.isLoading = true;
                  });
                  await widget.onTap();
                  setState(() {
                    widget.isLoading = false;
                  });
                }),
    );
  }

  LinearGradient getGradient() {
    if (widget.isLoading) {
      return LinearGradient(
        colors: <Color>[Color(0xffDEDEDE), Color(0xffDEDEDE)],
      );
    } else {
      return LinearGradient(
        colors: <Color>[Theme.of(context).primaryColor, Theme.of(context).primaryColor],
      );
    }
  }
}
