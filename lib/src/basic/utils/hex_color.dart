import 'dart:ui';

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {

    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }

    var value = int.tryParse(hexColor, radix: 16);
    if (value == null) {
      value = 0;
    }
    return value;
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
