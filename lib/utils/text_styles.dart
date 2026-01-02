import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import './format.dart';

enum TextSize { m, s, l, midl, xl, xs, x2l, x3l, x4l, x5l, x6l, x2s, x3s }

double textSizeToDouble(TextSize size) {
  switch (size) {
    case TextSize.x3s:
      return 6;
    case TextSize.x2s:
      return 8;
    case TextSize.xs:
      return 10;
    case TextSize.s:
      return 12;

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
      return 14;
  }
}

class BText extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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

class BWalletText extends ConsumerWidget {
  final dynamic amount;
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

  const BWalletText(
    this.amount, {
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
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          formatMoney(amount, ""),
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
        ),
        SizedBox(width: 2),
        Image.asset(
          "assets/icons/wallet.png",
          width: textSizeToDouble(size) + 5,
          height: textSizeToDouble(size) + 5,
        ),
      ],
    );
  }
}

class BTitle extends ConsumerWidget {
  final String title;
  final Color? color;
  final TextSize size;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int maxLine;
  final TextOverflow? overflow;

  const BTitle(
    this.title, {
    this.color,
    this.size = TextSize.x3l,
    this.fontWeight = FontWeight.w900,
    this.textAlign,
    this.maxLine = 0,
    this.overflow,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text(
      title,
      style: GoogleFonts.manrope(
        fontSize: textSizeToDouble(size),
        color: color,
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

class BSubtitle extends ConsumerWidget {
  final String title;
  final Color? color;
  final TextSize size;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int maxLine;
  final TextOverflow? overflow;

  const BSubtitle(
    this.title, {
    this.color,
    this.size = TextSize.l,
    this.fontWeight = FontWeight.bold,
    this.textAlign,
    this.maxLine = 0,
    this.overflow,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text(
      title,
      style: GoogleFonts.manrope(
        fontSize: textSizeToDouble(size),
        color: color,
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

extension StringCasingExtension on String {
  String get toCapitalized =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
}
