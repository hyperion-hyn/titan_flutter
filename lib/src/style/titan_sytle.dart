import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';

class TextStyles {
  static TextStyle textStyle(
      {double fontSize: 14, Color color: Colors.white, FontWeight fontWeight}) {
    return TextStyle(
        fontSize: fontSize,
        color: color,
        decoration: TextDecoration.none,
        fontWeight: fontWeight);
  }

  static TextStyle textC333S10 =
      textStyle(fontSize: 10, color: DefaultColors.color333);
  static TextStyle textC333S11 =
      textStyle(fontSize: 11, color: DefaultColors.color333);
  static TextStyle textC333S12 =
      textStyle(fontSize: 12, color: DefaultColors.color333);
  static TextStyle textC333S13 =
      textStyle(fontSize: 13, color: DefaultColors.color333);
  static TextStyle textC333S14 = textStyle(color: DefaultColors.color333);
  static TextStyle textC333S14bold =
      textStyle(color: DefaultColors.color333, fontWeight: FontWeight.bold);
  static TextStyle textC333S16 =
      textStyle(fontSize: 16, color: DefaultColors.color333);
  static TextStyle textC333S16bold = textStyle(
      fontSize: 16, color: DefaultColors.color333, fontWeight: FontWeight.bold);
  static TextStyle textC333S18 =
      textStyle(fontSize: 18, color: DefaultColors.color333);
  static TextStyle textC777S12 =
      textStyle(fontSize: 12, color: DefaultColors.color777);
  static TextStyle textC777S14 = textStyle(color: DefaultColors.color777);
  static TextStyle textC777S16 =
      textStyle(fontSize: 16, color: DefaultColors.color777);
  static TextStyle textC999S10 =
      textStyle(fontSize: 10, color: DefaultColors.color999);
  static TextStyle textC999S11 =
      textStyle(fontSize: 11, color: DefaultColors.color999);
  static TextStyle textC999S12 =
      textStyle(fontSize: 12, color: DefaultColors.color999);
  static TextStyle textC999S13 =
      textStyle(fontSize: 13, color: DefaultColors.color999);
  static TextStyle textC999S14 = textStyle(color: DefaultColors.color999);
  static TextStyle textC999S14medium =
      textStyle(color: DefaultColors.color999, fontWeight: FontWeight.w500);
  static TextStyle textCaaaS14 = textStyle(color: DefaultColors.coloraaa);
  static TextStyle textCfffS46 =
      textStyle(fontSize: 46, color: DefaultColors.colorfff);
  static TextStyle textCfffS24 =
      textStyle(fontSize: 24, color: DefaultColors.colorfff);
  static TextStyle textCfffS17 =
      textStyle(fontSize: 17, color: DefaultColors.colorfff);
  static TextStyle textCfffS14 = textStyle(color: DefaultColors.colorfff);
  static TextStyle textCfffS12 =
      textStyle(fontSize: 12, color: DefaultColors.colorfff);
  static TextStyle textCccfffS12 =
      textStyle(fontSize: 12, color: DefaultColors.colorccfff);
  static TextStyle textC000S16 =
      textStyle(fontSize: 16, color: DefaultColors.color000);
  static TextStyle textC000S14 = textStyle(color: DefaultColors.color000);
  static TextStyle textC9b9b9bS12 =
      textStyle(fontSize: 12, color: DefaultColors.color9b9b9b); //灰色
  static TextStyle textC9b9b9bS10 =
      textStyle(fontSize: 10, color: DefaultColors.color9b9b9b); //灰色
  static TextStyle textC9b9b9bS14 =
      textStyle(color: DefaultColors.color9b9b9b); //灰色
  static TextStyle textC00ec00S12 =
      textStyle(fontSize: 12, color: DefaultColors.color00ec00); //绿色 上涨
  static TextStyle textCff2d2dS12 =
      textStyle(fontSize: 12, color: DefaultColors.colorff2d2d); //红色 下跌
  static TextStyle textC26ac29S14 =
      textStyle(color: DefaultColors.color26ac29); //绿色
  static TextStyle textC26ac29S12 =
      textStyle(fontSize: 12, color: DefaultColors.color26ac29); //绿色
  static TextStyle textCf29a6eS12 =
      textStyle(fontSize: 12, color: DefaultColors.colorf29a6e); //黄色
  static TextStyle textCf29a6eS14 =
      textStyle(color: DefaultColors.colorf29a6e); //黄色

  static TextStyle textC906b00S13 =
      textStyle(fontSize: 13, color: DefaultColors.color906b00); //土黄色
  static TextStyle textCcc000000S16 =
      textStyle(fontSize: 16, color: DefaultColors.colorcc000000); //黑80%
  static TextStyle textCcc000000S14 =
      textStyle(color: DefaultColors.colorcc000000); //黑80%
  static TextStyle textC99000000S10 =
      textStyle(fontSize: 10, color: DefaultColors.color99000000); //黑60%
  static TextStyle textC99000000S13 =
      textStyle(fontSize: 13, color: DefaultColors.color99000000); //黑60%
  static TextStyle textCff4c3bS18 = textStyle(
      fontSize: 18,
      color: DefaultColors.colorff4c3b,
      fontWeight: FontWeight.bold); //红
  static TextStyle textCff4c3bS20 = textStyle(
      fontSize: 20,
      color: DefaultColors.colorff4c3b,
      fontWeight: FontWeight.bold); //红
  static TextStyle textC7c5b00S12 =
      textStyle(fontSize: 12, color: DefaultColors.color7c5b00); //深土黄
}

class DefaultColors {
  static Color primary = HexColor('#FFE7BB00');
  static Color color00000 = HexColor("#00000000");
  static Color color333 = HexColor("#333333");
  static Color color777 = HexColor("#777777");
  static Color color999 = HexColor("#999999");
  static Color colord0d0d0 = HexColor("#d0d0d0");
  static Color colord7d7d7 = HexColor("#d7d7d7");
  static Color colordedede = HexColor("#dedede");
  static Color colorf2f2f2 = HexColor("#f2f2f2");
  static Color coloraaa = HexColor("#aaaaaa");
  static Color colorfff = HexColor("#ffffff");
  static Color colorccfff = HexColor("#ccffffff");
  static Color color000 = HexColor("#000000");
  static Color colorf5f5f5 = HexColor("#f5f5f5");
  static Color colorf6f6f6 = HexColor("#f6f6f6");
  static Color colorf4f4f4 = HexColor("#f4f4f4");
  static Color color9b9b9b = HexColor("#9b9b9b");
  static Color color00ec00 = HexColor("#00ec00");
  static Color colorff2d2d = HexColor("#ff2d2d");
  static Color color26ac29 = HexColor("#26ac29");
  static Color colorf29a6e = HexColor("#f29a6e");
  static Color color0f95b0 = HexColor("#0f95b0"); //main color
  static Color colorcc000000 = HexColor("#cc000000");
  static Color color99000000 = HexColor("#99000000");
  static Color color66000000 = HexColor("#66000000");
  static Color colorffdb58 = HexColor("#ffdb58");
  static Color color906b00 = HexColor("#906b00");
  static Color colorff4c3b = HexColor("#ff4c3b");
  static Color color7c5b00 = HexColor("#7c5b00");
  static Color color2277869e = HexColor("#2277869e");
  static Color color141fb9c7 = HexColor("#141fb9c7");
  static Color color53ae86 = HexColor("#53ae86");
  static Color colorcc5858 = HexColor("#cc5858");
  static Color colorf8f8f8 = HexColor("#f8f8f8");
  static Color colorf23524 = HexColor("#f23524");
}
