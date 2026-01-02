//Vertical Spaces
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moon_design/moon_design.dart';

const smallColumnSpacer = SizedBox(height: 8);
const mediumColumnSpacer = SizedBox(height: 16);
const largeColumnSpacer = SizedBox(height: 24);
const xLargeColumnSpacer = SizedBox(height: 64);
const bottomColumnSpacer = SizedBox(height: 100);
const smallRowSpacer = SizedBox(width: 8);
const mediumRowSpacer = SizedBox(width: 16);
const largeRowSpacer = SizedBox(width: 24);

final smallBorderRadius = BorderRadius.circular(8);
final mediumBorderRadius = BorderRadius.circular(16);
final largeBorderRadius = BorderRadius.circular(24);

const smallBorderWidth = BorderSide(width: 1);
const mediumBorderWidth = BorderSide(width: 2);
const largeBorderWidth = BorderSide(width: 3);

const smallPadding = EdgeInsets.all(8);
const mediumPadding = EdgeInsets.all(16);
const largePadding = EdgeInsets.all(24);

// final Color primaryColor =
//addresses

List<BoxShadow> defaultShadow = [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.5),
    offset: Offset.zero,
    blurRadius: 2,
    spreadRadius: 2,
  ),
];

List<BoxShadow> ligherShadow = [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.3),
    offset: Offset.zero,
    blurRadius: 2,
    spreadRadius: 2,
  ),
];

extension BValidator on String {
  bool isValidEmail() {
    return RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    ).hasMatch(this);
  }

  bool isValidPhone() {
    return length == 8 &&
        (startsWith("9") ||
            startsWith("8") ||
            startsWith("6") ||
            startsWith("5"));
  }
}

extension MoonButtonFilledHaptic on MoonFilledButton {
  MoonFilledButton withHaptic() {
    return MoonFilledButton(
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.mediumImpact();
              onTap?.call();
            },
      autofocus: autofocus,
      isFocusable: isFocusable,
      ensureMinimalTouchTargetSize: ensureMinimalTouchTargetSize,
      isFullWidth: isFullWidth,
      showPulseEffect: showPulseEffect,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      decoration: decoration,
      height: height,
      width: width,
      minTouchTargetSize: minTouchTargetSize,
      focusNode: focusNode,
      buttonSize: buttonSize,
      semanticLabel: semanticLabel,
      onLongPress: onLongPress,
      leading: leading,
      label: label,
      trailing: trailing,
    );
  }
}

extension MoonButtonHaptic on MoonButton {
  MoonButton withHaptic() {
    return MoonButton(
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.mediumImpact();
              onTap?.call();
            },
      autofocus: autofocus,
      isFocusable: isFocusable,
      ensureMinimalTouchTargetSize: ensureMinimalTouchTargetSize,
      isFullWidth: isFullWidth,
      showPulseEffect: showPulseEffect,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      decoration: decoration,
      height: height,
      width: width,
      minTouchTargetSize: minTouchTargetSize,
      focusNode: focusNode,
      buttonSize: buttonSize,
      semanticLabel: semanticLabel,
      onLongPress: onLongPress,
      leading: leading,
      label: label,
      trailing: trailing,
    );
  }
}

extension MoonFilledButtonLoading on MoonFilledButton {
  MoonFilledButton withLoader(bool isLoading) {
    return MoonFilledButton(
      onTap: isLoading ? null : onTap?.call,
      autofocus: autofocus,
      isFocusable: isFocusable,
      ensureMinimalTouchTargetSize: ensureMinimalTouchTargetSize,
      isFullWidth: isFullWidth,
      showPulseEffect: showPulseEffect,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      decoration: decoration,
      height: height,
      width: width,
      minTouchTargetSize: minTouchTargetSize,
      focusNode: focusNode,
      buttonSize: buttonSize,
      semanticLabel: semanticLabel,
      onLongPress: onLongPress,
      leading: isLoading ? null : leading,
      label: isLoading
          ? Padding(
              padding: EdgeInsetsGeometry.all(8),
              child: AspectRatio(
                aspectRatio: 1,
                child: MoonCircularLoader(
                  color: Colors.white,
                ),
              ),
            )
          : label,
      trailing: isLoading ? null : trailing,
    );
  }
}

extension MoonOutlinedButtonHaptic on MoonOutlinedButton {
  MoonOutlinedButton withHaptic() {
    return MoonOutlinedButton(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap?.call();
      },
      autofocus: autofocus,
      isFocusable: isFocusable,
      ensureMinimalTouchTargetSize: ensureMinimalTouchTargetSize,
      isFullWidth: isFullWidth,
      showPulseEffect: showPulseEffect,
      borderRadius: borderRadius,
      borderColor: borderColor,
      decoration: decoration,
      height: height,
      width: width,
      minTouchTargetSize: minTouchTargetSize,
      focusNode: focusNode,
      buttonSize: buttonSize,
      semanticLabel: semanticLabel,
      onLongPress: onLongPress,
      label: label,
      leading: leading,
      trailing: trailing,
    );
  }
}

const alphabets = [
  "А",
  "Б",
  "В",
  "Г",
  "Д",
  "Е",
  "Ё",
  "Ж",
  "З",
  "И",
  "Й",
  "К",
  "Л",
  "М",
  "Н",
  "О",
  "Ө",
  "П",
  "Р",
  "С",
  "Т",
  "У",
  "Ү",
  "Ф",
  "Х",
  "Ц",
  "Ч",
  "Ш",
  "Щ",
  "Ъ",
  "Ь",
  "Ы",
  "Э",
  "Ю",
  "Я",
];
