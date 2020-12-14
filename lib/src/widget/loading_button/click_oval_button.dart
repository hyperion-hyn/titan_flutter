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
  bool isDisable;

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
    this.isDisable = false,
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
      child: (widget.isLoading && !widget.isDisable)
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
    var title = '';
    Color color;
    if (widget.isDisable) {
      title = widget.text;
      color = DefaultColors.color999;
    } else {
      if (widget.isLoading) {
        title = widget.loadingText ?? widget.text;
        color = DefaultColors.color999;
      } else {
        title = widget.text;
        color = widget?.fontColor ?? Colors.white;
      }
    }
    return FlatButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(widget.radius != null ? widget.radius : widget.height / 2)),
        ),
        padding: const EdgeInsets.all(0.0),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: widget.fontWeight,
              fontSize: widget.fontSize,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        onPressed: (widget.onTap == null || widget.isLoading || widget.isDisable)
            ? null
            : () async {
                if (mounted) {
                  setState(() {
                    widget.isDisable = true;
                  });
                }
                await widget.onTap();
                if (mounted) {
                  setState(() {
                    widget.isDisable = false;
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
    if (widget.isLoading || widget.isDisable) {
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
