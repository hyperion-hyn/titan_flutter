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

  static TextStyle textC333S14 = textStyle(color: HexColor("#333333"));
  static TextStyle textC777S14 = textStyle(color: HexColor("#777777"));
  static TextStyle textCaaaS14 = textStyle(color: HexColor("#aaaaaa"));
}