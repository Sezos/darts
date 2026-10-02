import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum TextSize { m, s, l, midl, xl, xs, x2l, x3l, x4l, x5l, x6l, x2s, x3s }

double textSizeToDouble(TextSize size) {
  switch (size) {
    // 11pt is the legibility floor (HIG); x3s and x2s both resolve to it.
    case TextSize.x3s:
      return 11;
    case TextSize.x2s:
      return 11;
    case TextSize.xs:
      return 12;
    case TextSize.s:
      return 13;

    case TextSize.l:
      return 17;
    case TextSize.midl:
      return 18.5;
    case TextSize.xl:
      return 20;
    case TextSize.x2l:
      return 23;
    case TextSize.x3l:
      return 26;
    case TextSize.x4l:
      return 29;
    case TextSize.x5l:
      return 32;
    case TextSize.x6l:
      return 35;
    default:
      return 15;
  }
}

class BText extends StatelessWidget {
  final String title;
  final Color? color;
  final TextSize size;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int maxLine;
  final TextOverflow? overflow;
  final TextDecoration? decoration;
  final Color? decorationColor;
  final double? decorationThickness;
  final double? letterSpacing;

  const BText(
    this.title, {
    this.color,
    this.size = TextSize.m,
    this.fontWeight,
    this.textAlign,
    this.maxLine = 0,
    this.overflow,
    this.decoration,
    this.decorationColor,
    this.decorationThickness,
    this.letterSpacing = 0.75,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.manrope(
        fontSize: textSizeToDouble(size),
        color: color,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationThickness: decorationThickness,
        letterSpacing: letterSpacing,
        fontWeight: fontWeight == FontWeight.bold
            ? FontWeight.w500
            : fontWeight,
      ),
      overflow: overflow,
      maxLines: maxLine == 0 ? null : maxLine,
      textAlign: textAlign,
    );
  }
}

class BComment extends StatelessWidget {
  final String title;
  final Color? color;
  final TextSize size;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int maxLine;
  final TextOverflow? overflow;
  final TextDecoration? decoration;
  final Color? decorationColor;
  final double? decorationThickness;

  const BComment(
    this.title, {
    this.color = Colors.grey,
    this.size = TextSize.m,
    this.fontWeight,
    this.textAlign,
    this.maxLine = 0,
    this.overflow,
    this.decoration,
    this.decorationColor,
    this.decorationThickness,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.manrope(
        fontSize: textSizeToDouble(size),
        color: color,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationThickness: decorationThickness,
        fontWeight: fontWeight == FontWeight.bold
            ? FontWeight.w500
            : fontWeight,
      ),
      overflow: overflow,
      maxLines: maxLine == 0 ? null : maxLine,
      textAlign: textAlign,
    );
  }
}
