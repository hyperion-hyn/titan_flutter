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
  static TextStyle textC777S14 = textStyle(color: DefaultColors.color777);
  static TextStyle textC777S16 = textStyle(fontSize: 16, color: DefaultColors.color777);
  static TextStyle textCaaaS14 = textStyle(color: DefaultColors.coloraaa);
  static TextStyle textCfffS14 = textStyle(color: DefaultColors.colorfff);
  static TextStyle textCfffS12 = textStyle(fontSize: 12, color: DefaultColors.colorfff);
  static TextStyle textC000S16 = textStyle(fontSize: 16, color: DefaultColors.color000);
}

class DefaultColors {
  static Color color333 = HexColor("#333333");
  static Color color777 = HexColor("#777777");
  static Color coloraaa = HexColor("#aaaaaa");
  static Color colorfff = HexColor("#ffffff");
  static Color color000 = HexColor("#000000");
}