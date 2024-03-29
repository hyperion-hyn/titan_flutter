import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:characters/characters.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/pages/wallet/model/wallet_send_dialog_util.dart';

Widget walletHeaderWidget(
  String shortName, {
  double size = 40,
  double fontSize = 15,
  bool isShowShape = true,
  String address = "#000000",
  bool isCircle = true,
  bool isShowImage = false,
  String imageSource = '',
}) {

  if (shortName?.isNotEmpty ?? false) {
    shortName = shortName.characters.first;
  } else {
    return Image.asset(
      'res/drawable/ic_robot_head.png',
      width: 32,
      height: 32,
    );
  }
  String hexColor = address;
  if (address.length > 6 && !address.contains('@')) {
    hexColor = "#" + address.substring(address.length - 6);
  } else {
    hexColor = "#BFBFBF";
  }
  HexColor color = HexColor(hexColor);
  var decoration = BoxDecoration(
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
  );

  if (!isCircle) {
    decoration = BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(6),
      boxShadow: isShowShape
          ? [
              BoxShadow(
                color: Colors.grey[300],
                blurRadius: 8.0,
              ),
            ]
          : null,
    );
  }
  return Container(
    width: size,
    height: size,
    decoration: decoration,
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

Widget walletHeaderIconWidget(
    String shortName, {
      double size = 40,
      double fontSize = 15,
      bool isShowShape = true,
      String address = "#000000",
      bool isCircle = true,
      bool isShowImage = false,
      String imageSource = '',
    }) {

  if (imageSource.isNotEmpty) {
    return ClipOval(
      child: FadeInImage.assetNetwork(
        image: imageSource,
        placeholder: 'res/drawable/ic_robot_head.png',
        width: 60,
        height: 60,
        fit: BoxFit.cover,
      ),
    );
  }

  if (shortName.isNotEmpty) {
    shortName = shortName.characters.first;
  } else {
    return Image.asset(
      'res/drawable/ic_robot_head.png',
      width: 32,
      height: 32,
    );
  }

  String hexColor = address;
  if (address.length > 6 && !address.contains('@')) {
    hexColor = "#" + address.substring(address.length - 6);
  } else {
    hexColor = "#BFBFBF";
  }
  HexColor color = HexColor(hexColor);
  var decoration = BoxDecoration(
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
  );

  if (!isCircle) {
    decoration = BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(6),
      boxShadow: isShowShape
          ? [
        BoxShadow(
          color: Colors.grey[300],
          blurRadius: 8.0,
        ),
      ]
          : null,
    );
  }
  return Container(
    width: size,
    height: size,
    decoration: decoration,
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

