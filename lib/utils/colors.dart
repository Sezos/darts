import 'package:flutter/material.dart';

class BColors {
  Color get lighter => Color(0xFF162E26);
  Color get background => Color(0xFF10221C);
  Color get primary => Color(0xFF13ECA4);
  Color get border => Color.fromRGBO(95, 95, 95, 1);
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String? hexString) {
    if (hexString == null) return Colors.transparent;
    RegExp hexColorRegex = RegExp(
      r'^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$',
    );
    if (hexString.startsWith("rgba")) {
      List rgbaList = hexString.substring(5, hexString.length - 1).split(",");
      return Color.fromRGBO(
        int.parse(rgbaList[0]),
        int.parse(rgbaList[1]),
        int.parse(rgbaList[2]),
        double.parse(rgbaList[3]),
      );
    } else if (hexString.startsWith("rgb")) {
      List rgbList = hexString
          .substring(4, hexString.length - 1)
          .split(",")
          .map((c) => int.parse(c))
          .toList();
      return Color.fromRGBO(rgbList[0], rgbList[1], rgbList[2], 1.0);
    } else if (hexColorRegex.hasMatch(hexString)) {
      if (hexString.length == 4) {
        hexString = hexString + hexString.substring(1, 4);
      }
      if (hexString.length == 7) {
        int colorValue = int.parse(hexString.substring(1), radix: 16);
        return Color(colorValue).withAlpha(255);
      } else {
        int colorValue = int.parse(hexString.substring(1, 7), radix: 16);
        double opacityValue =
            int.parse(hexString.substring(7), radix: 16).toDouble() / 255;
        return Color(colorValue).withAlpha((opacityValue * 255).toInt());
      }
    }
    return Colors.transparent;
  }
}
