import 'package:flutter/material.dart';
import 'package:titan/src/components/setting/model.dart';

class CustomClickOvalButton extends StatefulWidget {
  Widget child;
  double height;
  double width;
  double fontSize;
  Function onTap;
  bool isLoading = false;

  CustomClickOvalButton(
    this.child,
    this.onTap, {
    this.height = 36,
    this.width = 180,
    this.fontSize = 13,
  });

  @override
  State<StatefulWidget> createState() {
    return _CustomClickOvalButtonState();
  }
}

class _CustomClickOvalButtonState extends State<CustomClickOvalButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(widget.height / 2)),
        gradient: getGradient(),
      ),
      child: FlatButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(22.0)),
          ),
          padding: const EdgeInsets.all(0.0),
          child: widget.child,
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
        colors: SupportedTheme.defaultBtnColors(context),
      );
    }
  }
}
