import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/style/titan_sytle.dart';

class ClickOvalButton extends StatefulWidget {
  String text;
  double height;
  double width;
  double fontSize;
  Function onTap;
  bool isLoading;
  List<Color> btnColor;
  Color fontColor;
  double radius;
  String loadingText;
  FontWeight fontWeight = FontWeight.w500;

  ClickOvalButton(
    this.text,
    this.onTap, {
    this.height = 36,
    this.width = 180,
    this.fontSize = 13,
    this.fontColor,
    this.btnColor,
    this.radius,
    this.isLoading = false,
    this.loadingText = '提交请求中...',
    this.fontWeight,
  });

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
      child: widget.isLoading
          ? Stack(
              children: [
                _flatBtnWidget(),
                _loadingWidget(
                  visible: widget.isLoading,
                ),
              ],
            )
          : _flatBtnWidget(),
    );
  }

  Widget _flatBtnWidget() {
    return FlatButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(widget.radius != null ? widget.radius : widget.height / 2)),
        ),
        padding: const EdgeInsets.all(0.0),
        child: Center(
          child: Text(
            widget.isLoading ? widget.loadingText ?? widget.text : widget.text,
            style: TextStyle(
              fontWeight: widget.fontWeight,
              fontSize: widget.fontSize,
              color: widget.isLoading
                  ? DefaultColors.color999
                  : widget.fontColor != null
                      ? widget.fontColor
                      : Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        onPressed: (widget.onTap == null || widget.isLoading)
            ? null
            : () async {
                if (mounted) {
                  setState(() {
                    widget.isLoading = true;
                  });
                }
                await widget.onTap();
                if (mounted) {
                  setState(() {
                    widget.isLoading = false;
                  });
                }
              });
  }

  Widget _loadingWidget({
    bool visible = false,
  }) {
    return Visibility(
      visible: visible,
      child: Positioned(
        width: 20,
        height: 20,
        top: (widget.height - 20) * 0.5,
        right: (widget.width - 20) * 0.25,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            DefaultColors.color999,
          ),
        ),
      ),
    );
  }

  LinearGradient getGradient() {
    if (widget.isLoading) {
      return LinearGradient(
        colors: <Color>[Color(0xffDEDEDE), Color(0xffDEDEDE)],
      );
    } else {
      if (widget.btnColor != null) {
        if (widget.btnColor.length == 1) {
          widget.btnColor.add(widget.btnColor[0]);
        }
        return LinearGradient(
          colors: widget.btnColor,
        );
      } else {
        return LinearGradient(
          colors: <Color>[Color(0xff15B2D2), Color(0xff1097B4)],
        );
      }
    }
  }
}
