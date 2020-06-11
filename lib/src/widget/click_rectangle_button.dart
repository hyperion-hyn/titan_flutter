import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/style/titan_sytle.dart';

class ClickRectangleButton extends StatefulWidget {
  String text;
  double height;
  double fontSize;
  Function onTap;
  bool isLoading = false;
  bool isLightTheme = false;

  ClickRectangleButton(
    this.text,
    this.onTap, {
    this.height = 50,
    this.fontSize = 17,
    this.isLightTheme = false,
  });

  @override
  State<StatefulWidget> createState() {
    return _ClickRectangleButtonState();
  }
}

class _ClickRectangleButtonState extends State<ClickRectangleButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 4.0,
          ),
        ],
      ),
      constraints: BoxConstraints.expand(height: widget.height),
      child: RaisedButton(
          disabledColor: HexColor("#dedede"),
          color: widget.isLightTheme
              ? Colors.white
              : Theme.of(context).primaryColor,
          child: Text(
            widget.text,
            style: widget.isLightTheme
                ? TextStyle(
                    fontSize: widget.fontSize,
                    color: widget.isLoading
                        ? DefaultColors.color999
                        : Colors.black,
                  )
                : TextStyle(
                    fontSize: widget.fontSize,
                    color: widget.isLoading
                        ? DefaultColors.color999
                        : Colors.white,
                  ),
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
}
