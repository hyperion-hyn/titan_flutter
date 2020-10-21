import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:characters/characters.dart';

Widget walletHeaderWidget(String shortName,
    {double size = 40, double fontSize = 15, bool isShowShape = true, String address = "#000000"}) {
  if (shortName.isNotEmpty) {
    shortName = shortName.characters.first;
  }
  String hexColor = address;
  if (address.length > 6) {
    hexColor = "#" + address.substring(address.length - 6);
  }
  HexColor color = HexColor(hexColor);
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: isShowShape
          ? [
              BoxShadow(
                color: Colors.grey[300],
                blurRadius: 8.0,
              ),
            ]
          : null,
    ),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          shortName.toUpperCase(),
          style: TextStyle(fontSize: fontSize, color: HexColor("#FFFFFF"), fontWeight: FontWeight.w500, shadows: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 1.0,
            ),
          ]),
        ),
      ),
    ),
  );
}
