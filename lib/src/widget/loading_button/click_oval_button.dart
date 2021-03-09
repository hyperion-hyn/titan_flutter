import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/components/setting/model.dart';
import 'package:titan/src/config/consts.dart';
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
  String loadingText = S.of(Keys.rootKey.currentContext).submitting_request;
  FontWeight fontWeight = FontWeight.w500;
  bool isDisable;
  Widget prefixIcon;
  Color borderColor;

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
    String loadingTextStr,
    this.fontWeight,
    this.isDisable = false,
    this.prefixIcon,
    this.borderColor,
  }) {
    if (loadingTextStr != null) {
      this.loadingText = loadingTextStr;
    }
  }

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
        borderRadius: BorderRadius.all(
            Radius.circular(widget.radius != null ? widget.radius : widget.height / 2)),
        gradient: getGradient(),
        border: Border.all(color: widget.borderColor ?? Colors.transparent, width: 0.5),
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
        color = widget?.fontColor ?? Theme.of(context).textTheme.apply().bodyText1.color;
      }
    }
    return FlatButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
              Radius.circular(widget.radius != null ? widget.radius : widget.height / 2)),
        ),
        padding: const EdgeInsets.all(0.0),
        child: Center(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (widget.prefixIcon != null) widget.prefixIcon,
              Text(
                title,
                style: TextStyle(
                  fontWeight: widget.fontWeight,
                  fontSize: widget.fontSize,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
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
          colors: SupportedTheme.defaultBtnColors(context),
        );
      }
    }
  }
}
