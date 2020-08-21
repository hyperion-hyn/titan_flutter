import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/style/titan_sytle.dart';

class ClickOvalButton extends StatefulWidget {
  String text;
  double height;
  double width;
  double fontSize;
  Function onTap;
  bool isLoading = false;
  Color btnColor;
  Color textColor;
  double radius;

  ClickOvalButton(this.text, this.onTap,
      {this.height = 36, this.width = 180, this.fontSize = 13, this.btnColor, this.textColor, this.radius});

  @override
  State<StatefulWidget> createState() {
    return _ClickOvalButtonState();
  }
}

class _ClickOvalButtonState extends State<ClickOvalButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(widget.radius != null ? widget.radius : widget.height / 2)),
        gradient: getGradient(),
      ),
      child: FlatButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(22.0)),
          ),
          padding: const EdgeInsets.all(0.0),
          child: Text(widget.text,
              style: TextStyle(
                fontSize: widget.fontSize,
                color: widget.isLoading
                    ? DefaultColors.color999
                    : widget.textColor != null ? widget.textColor : Colors.white,
              )),
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
      if (widget.btnColor != null) {
        return LinearGradient(
          colors: <Color>[widget.btnColor, widget.btnColor],
        );
      } else {
        return LinearGradient(
          colors: <Color>[Color(0xff15B2D2), Color(0xff1097B4)],
        );
      }
    }
  }
}
