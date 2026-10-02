import 'package:darts/utils/colors.dart';
import 'package:darts/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

extension MotionContext on BuildContext {
  /// The user asked the OS to reduce or remove animations.
  bool get reduceMotion => MediaQuery.disableAnimationsOf(this);
}

/// Base for every tappable surface: gives it a button role and accessible
/// name, a pressed state, and a minimum touch target.
///
/// Pass [semanticLabel] for icon-only controls. When the child already shows
/// its text, leave it null and the visible text is announced.
class Pressable extends StatefulWidget {
  const Pressable({
    required this.child,
    required this.onTap,
    this.semanticLabel,
    this.selected,
    this.minSize = 44,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool? selected;

  /// Minimum width and height of the hit area (44pt iOS / ~48dp Android).
  final double minSize;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (widget.onTap == null || _pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final duration = context.reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 90);

    return Semantics(
      button: true,
      enabled: widget.onTap != null,
      selected: widget.selected,
      label: widget.semanticLabel,
      excludeSemantics: widget.semanticLabel != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: widget.minSize,
            minHeight: widget.minSize,
          ),
          child: AnimatedScale(
            scale: _pressed ? 0.96 : 1,
            duration: duration,
            curve: Curves.easeOut,
            child: AnimatedOpacity(
              opacity: _pressed ? 0.8 : 1,
              duration: duration,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Filled mint button for the one primary action on a screen.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.height = 52,
    super.key,
  });

  final String label;

  /// Null renders the disabled state.
  final VoidCallback? onTap;
  final dynamic icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final fg = enabled ? BColors().onPrimary : BColors().textSecondary;

    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: enabled ? BColors().primaryGradient : null,
          color: enabled ? null : BColors().lighter,
          border: enabled ? null : Border.all(color: BColors().border),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: BColors().primary.withAlpha(80),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            if (icon != null)
              HugeIcon(icon: icon, color: fg, strokeWidth: 2.5, size: 20),
            Flexible(
              child: BText(
                label,
                color: fg,
                fontWeight: .w900,
                size: .l,
                letterSpacing: 1,
                maxLine: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Outlined neutral button, the quieter partner of [PrimaryButton].
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    required this.label,
    required this.onTap,
    this.color,
    this.height = 48,
    super.key,
  });

  final String label;
  final VoidCallback? onTap;

  /// Tints the label and border, e.g. [BColors.danger] for destructive.
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color?.withAlpha(25) ?? BColors().lighter,
          border: Border.all(color: color?.withAlpha(90) ?? BColors().border),
        ),
        child: Center(
          child: BText(
            label,
            fontWeight: .w700,
            color: color ?? BColors().textPrimary,
            maxLine: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

/// Icon-only square button. [label] is required: it's what screen readers say.
class IconTile extends StatelessWidget {
  const IconTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.size = 44,
    this.color,
    super.key,
  });

  final dynamic icon;
  final String label;
  final VoidCallback? onTap;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      minSize: size,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: BColors().lighter,
          border: Border.all(color: BColors().border),
        ),
        child: Center(
          child: HugeIcon(
            icon: icon,
            color: color ?? BColors().textPrimary,
            size: 20,
          ),
        ),
      ),
    );
  }
}

/// Bare icon with a full-size hit area, for inline row actions.
class IconAction extends StatelessWidget {
  const IconAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    super.key,
  });

  final dynamic icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: Center(
        child: HugeIcon(
          icon: icon,
          color: color ?? BColors().textSecondary,
          size: 20,
        ),
      ),
    );
  }
}
