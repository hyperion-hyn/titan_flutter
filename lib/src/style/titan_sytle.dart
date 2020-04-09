import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';

class TextStyles {
  static TextStyle textStyle({double fontSize: 14,
    Color color: Colors.white,
    FontWeight fontWeight}) {
    return TextStyle(
        fontSize: fontSize,
        color: color,
        decoration: TextDecoration.none,
        fontWeight: fontWeight);
  }

  static TextStyle textC333S14 = textStyle(color: DefaultColors.color333);
  static TextStyle textC333S14bold = textStyle(color: DefaultColors.color333,fontWeight: FontWeight.bold);
  static TextStyle textC333S12 = textStyle(fontSize: 12, color: DefaultColors.color333);
  static TextStyle textC777S14 = textStyle(color: DefaultColors.color777);
  static TextStyle textC777S16 = textStyle(fontSize: 16, color: DefaultColors.color777);
  static TextStyle textCaaaS14 = textStyle(color: DefaultColors.coloraaa);
  static TextStyle textCfffS14 = textStyle(color: DefaultColors.colorfff);
  static TextStyle textCfffS12 = textStyle(fontSize: 12, color: DefaultColors.colorfff);
  static TextStyle textC000S16 = textStyle(fontSize: 16, color: DefaultColors.color000);
  static TextStyle textC9b9b9bS12 = textStyle(fontSize: 12, color: DefaultColors.color9b9b9b);//灰色
  static TextStyle textC9b9b9bS14 = textStyle(color: DefaultColors.color9b9b9b);//灰色
  static TextStyle textC00ec00S12 = textStyle(fontSize: 12, color: DefaultColors.color00ec00);//绿色 上涨
  static TextStyle textCff2d2dS12 = textStyle(fontSize: 12, color: DefaultColors.colorff2d2d);//红色 下跌
  static TextStyle textC26ac29S14 = textStyle(color: DefaultColors.color26ac29);//绿色
  static TextStyle textC26ac29S12 = textStyle(fontSize: 12, color: DefaultColors.color26ac29);//绿色
  static TextStyle textCf29a6eS12 = textStyle(fontSize: 12, color: DefaultColors.colorf29a6e);//黄色
  static TextStyle textCf29a6eS14 = textStyle(color: DefaultColors.colorf29a6e);//黄色
}

class DefaultColors {
  static Color color333 = HexColor("#333333");
  static Color color777 = HexColor("#777777");
  static Color coloraaa = HexColor("#aaaaaa");
  static Color colorfff = HexColor("#ffffff");
  static Color color000 = HexColor("#000000");
  static Color colorf5f5f5 = HexColor("#f5f5f5");
  static Color color9b9b9b = HexColor("#9b9b9b");
  static Color color00ec00 = HexColor("#00ec00");
  static Color colorff2d2d = HexColor("#ff2d2d");
  static Color color26ac29 = HexColor("#26ac29");
  static Color colorf29a6e = HexColor("#f29a6e");
  static Color color0F95B0 = HexColor("#0F95B0");//main color
}