import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';

///  自定义 键盘 按钮

class CustomKbBtn extends StatefulWidget {
  String text;
  bool isDelBtn;

  CustomKbBtn({Key key, this.text, this.isDelBtn = false, this.callback}) : super(key: key);
  final callback;

  @override
  State<StatefulWidget> createState() {
    return ButtonState();
  }
}

class ButtonState extends State<CustomKbBtn> {
  ///回调函数执行体
  var backMethod;

  void back() {
    widget.callback('$backMethod');
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    var _screenWidth = mediaQuery.size.width;

    return Container(
        height: 52.0,
        width: _screenWidth / 3,
        color: widget.isDelBtn ? Colors.transparent : Colors.white,
        child: OutlineButton(
          // 直角
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
          // 边框颜色
          borderSide: BorderSide(color: Color(0xffededed)),
          child: widget.isDelBtn ? Image.asset("res/drawable/ic_password_back_del.png",width: 22,) : Text(
            widget.text,
            style: TextStyle(color: Color(0xff333333), fontSize: 20.0),
          ),
          onPressed: back,
        ));
  }
}
