import 'package:flutter/material.dart';

class BColors {
  // Backgrounds
  Color get background => const Color(0xFF080F0C);
  Color get surface => const Color(0xFF0D1F17);
  Color get lighter => const Color(0xFF112318);
  Color get elevated => const Color(0xFF1A3628);

  // Primary accent — neon mint
  Color get primary => const Color(0xFF00E896);
  Color get primaryDim => const Color(0xFF00E896).withAlpha(25);
  Color get primaryGlow => const Color(0xFF00E896).withAlpha(70);
  Color get primaryBorder => const Color(0xFF00E896).withAlpha(55);

  // Secondary accents
  Color get gold => const Color(0xFFF5A623);
  Color get orange => const Color(0xFFFF6B35);

  // Text
  Color get textPrimary => const Color(0xFFECFDF7);
  Color get textSecondary => const Color(0xFF7AA896);

  // Borders
  Color get border => const Color(0xFF1D3D2D);
  Color get borderSubtle => const Color(0xFF152B20);
}

extension HexColor on Color {
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
