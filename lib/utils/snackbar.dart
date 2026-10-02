import 'package:darts/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

enum SnackType { info, success, error }

/// Brief, non-blocking feedback at the top of the screen.
void showSnackMsg(
  String message,
  BuildContext context, {
  SnackType type = SnackType.info,
}) {
  final accent = switch (type) {
    SnackType.info => BColors().textPrimary,
    SnackType.success => BColors().primary,
    SnackType.error => BColors().danger,
  };
  final icon = switch (type) {
    SnackType.info => HugeIcons.strokeRoundedInformationCircle,
    SnackType.success => HugeIcons.strokeRoundedCheckmarkCircle01,
    SnackType.error => HugeIcons.strokeRoundedAlertCircle,
  };

  showTopSnackBar(
    Overlay.of(context),
    CustomSnackBar.info(
      message: message,
      maxLines: 3,
      backgroundColor: BColors().elevated,
      boxShadow: const [],
      icon: HugeIcon(icon: icon, color: accent.withAlpha(30), size: 96),
      textStyle: GoogleFonts.manrope(
        color: accent,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    ),
    displayDuration: const Duration(milliseconds: 1800),
    animationDuration: const Duration(milliseconds: 400),
  );
}
