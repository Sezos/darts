import 'package:darts/utils/colors.dart';
import 'package:darts/utils/interaction.dart';
import 'package:darts/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';

/// The app's one confirmation dialog. Resolves true only when the user picks
/// [confirmLabel]; dismissing or cancelling resolves false.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = "Болих",
  bool destructive = false,
}) async {
  final result = await showMoonModal<bool>(
    context: context,
    builder: (ctx) => MoonModal(
      backgroundColor: BColors().surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Semantics(
              header: true,
              child: BText(title, fontWeight: .w800, size: .l),
            ),
            BComment(message, color: BColors().textSecondary),
            const SizedBox(height: 8),
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: cancelLabel,
                    onTap: () => Navigator.of(ctx).pop(false),
                  ),
                ),
                Expanded(
                  child: destructive
                      ? SecondaryButton(
                          label: confirmLabel,
                          color: BColors().danger,
                          onTap: () => Navigator.of(ctx).pop(true),
                        )
                      : PrimaryButton(
                          label: confirmLabel,
                          height: 48,
                          onTap: () => Navigator.of(ctx).pop(true),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}
