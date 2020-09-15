import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/style/titan_sytle.dart';

class ClickLoadingButton extends StatefulWidget {
  final String text;
  final double height;
  final double width;
  final double fontSize;
  final Color fontColor;
  final Function onTap;
  final Color btnColor;
  final double radius;
  bool isLoading = false;

  ClickLoadingButton(this.text, this.onTap,
      {this.height = 36, this.width = 180, this.fontSize = 13, this.fontColor, this.btnColor, this.radius});

  @override
  State<StatefulWidget> createState() {
    return _ClickLoadingButtonState();
  }
}

class _ClickLoadingButtonState extends State<ClickLoadingButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(widget.radius != null ? widget.radius : widget.height / 2)),
        color: widget.btnColor != null ? widget.btnColor : Theme.of(context).primaryColor,
      ),
      child: FlatButton(
//          shape: RoundedRectangleBorder(
//            borderRadius: BorderRadius.all(Radius.circular(widget.radius != null ? widget.radius : widget.height / 2)),
//          ),
          padding: const EdgeInsets.all(0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: widget.width - 20,
                child: Text(widget.text,
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: widget.fontSize,
                      color: widget.fontColor != null ? widget.fontColor : Colors.white,
                    )),
              ),
              Visibility(
                  visible: widget.isLoading,
                  child: SizedBox(
                    width: 2,
                  )),
              Visibility(
                visible: widget.isLoading,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: SizedBox(
                    height: 12,
                    width: 12,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(widget.fontColor != null ? widget.fontColor : Colors.white),
                      strokeWidth: 1.5,
                    ),
                  ),
                ),
              )
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
}