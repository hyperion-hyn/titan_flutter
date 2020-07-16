import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';

import 'custom_keyboard_button.dart';
import 'pay_password.dart';

/// 自定义密码 键盘

class MyKeyboard extends StatefulWidget {
  final callback;

  MyKeyboard(this.callback);

  @override
  State<StatefulWidget> createState() {
    return new MyKeyboardStat();
  }
}

class MyKeyboardStat extends State<MyKeyboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// 定义 确定 按钮 接口  暴露给调用方
  ///回调函数执行体
  var backMethod;

  void onCommitChange() {
    widget.callback(new KeyEvent("commit"));
  }

  void onOneChange(BuildContext cont) {
    widget.callback(new KeyEvent("1"));
  }

  void onTwoChange(BuildContext cont) {
    widget.callback(new KeyEvent("2"));
  }

  void onThreeChange(BuildContext cont) {
    widget.callback(new KeyEvent("3"));
  }

  void onFourChange(BuildContext cont) {
    widget.callback(new KeyEvent("4"));
  }

  void onFiveChange(BuildContext cont) {
    widget.callback(new KeyEvent("5"));
  }

  void onSixChange(BuildContext cont) {
    widget.callback(new KeyEvent("6"));
  }

  void onSevenChange(BuildContext cont) {
    widget.callback(new KeyEvent("7"));
  }

  void onEightChange(BuildContext cont) {
    widget.callback(new KeyEvent("8"));
  }

  void onNineChange(BuildContext cont) {
    widget.callback(new KeyEvent("9"));
  }

  void onZeroChange(BuildContext cont) {
    widget.callback(new KeyEvent("0"));
  }

  /// 点击删除
  void onDeleteChange() {
    widget.callback(new KeyEvent("del"));
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      key: _scaffoldKey,
      width: double.infinity,
      height: 229.0,
      color: HexColor("#ededed"),
      child: new Column(
        children: <Widget>[
          ///  键盘主体
          new Column(
            children: <Widget>[
              ///  第一行
              new Row(
                children: <Widget>[
                  CustomKbBtn(text: '1', callback: (val) => onOneChange(context)),
                  CustomKbBtn(text: '2', callback: (val) => onTwoChange(context)),
                  CustomKbBtn(text: '3', callback: (val) => onThreeChange(context)),
                ],
              ),

              ///  第二行
              new Row(
                children: <Widget>[
                  CustomKbBtn(text: '4', callback: (val) => onFourChange(context)),
                  CustomKbBtn(text: '5', callback: (val) => onFiveChange(context)),
                  CustomKbBtn(text: '6', callback: (val) => onSixChange(context)),
                ],
              ),

              ///  第三行
              new Row(
                children: <Widget>[
                  CustomKbBtn(text: '7', callback: (val) => onSevenChange(context)),
                  CustomKbBtn(text: '8', callback: (val) => onEightChange(context)),
                  CustomKbBtn(text: '9', callback: (val) => onNineChange(context)),
                ],
              ),

              ///  第四行
              new Row(
                children: <Widget>[
                  Spacer(),
//                  CustomKbBtn(text: '确定', callback: (val) => onCommitChange()),
                  CustomKbBtn(text: '0', callback: (val) => onZeroChange(context)),
                  CustomKbBtn(text: S.of(context).delete, isDelBtn: true, callback: (val) => onDeleteChange()),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
