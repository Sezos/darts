import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './colors.dart';

class BCard extends ConsumerStatefulWidget {
  const BCard({
    super.key,
    required this.child,
    this.isFullWidth = false,
    this.color,
    this.height,
    this.width,
    this.onTap,
    this.radius = 12,
    this.leftTopRadius,
    this.rightTopRadius,
    this.rightBottomRadius,
    this.leftBottomRadius,
    this.hoverColor,
    this.borderColor,
    this.borderWidth,
    this.padding = const EdgeInsets.all(8),
    this.scaleAmount = 0.97,
  });

  final Widget child;
  final Color? color, borderColor, hoverColor;
  final double? height,
      width,
      borderWidth,
      leftTopRadius,
      rightTopRadius,
      rightBottomRadius,
      leftBottomRadius;
  final bool isFullWidth;
  final double radius;
  final double scaleAmount; // how small it shrinks on press
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  ConsumerState<BCard> createState() => _BCardState();
}

class _BCardState extends ConsumerState<BCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(widget.leftTopRadius ?? widget.radius),
      topRight: Radius.circular(widget.rightTopRadius ?? widget.radius),
      bottomRight: Radius.circular(widget.rightBottomRadius ?? widget.radius),
      bottomLeft: Radius.circular(widget.leftBottomRadius ?? widget.radius),
    );

    return Listener(
      onPointerDown: (_) => setState(() => _isPressed = true),
      onPointerUp: (_) => setState(() => _isPressed = false),
      onPointerCancel: (_) => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed && widget.onTap != null ? widget.scaleAmount : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Material(
          color: Colors.transparent,
          borderRadius: borderRadius,
          child: Ink(
            decoration: BoxDecoration(
              color: widget.color ?? BColors().lighter,
              borderRadius: borderRadius,
              border: Border.all(
                color: widget.borderColor ?? BColors().border,
                width: widget.borderWidth ?? 1,
              ),
            ),
            child: InkWell(
              borderRadius: borderRadius,
              splashColor: widget.hoverColor?.withAlpha(64),
              highlightColor: widget.hoverColor?.withAlpha(51),
              onTap: widget.onTap,
              child: SizedBox(
                height: widget.height,
                width: widget.isFullWidth ? double.infinity : widget.width,
                child: Padding(
                  padding: widget.padding ?? EdgeInsets.zero,
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension BCardHaptic on BCard {
  BCard withHaptic() {
    return BCard(
      isFullWidth: isFullWidth,
      color: color,
      height: height,
      width: width,
      onTap: () {
        if (onTap == null) {
          return;
        }
        HapticFeedback.mediumImpact();
        onTap!();
      },
      radius: radius,
      leftTopRadius: leftTopRadius,
      rightTopRadius: rightTopRadius,
      rightBottomRadius: rightBottomRadius,
      leftBottomRadius: leftBottomRadius,
      hoverColor: hoverColor,
      borderColor: borderColor,
      borderWidth: borderWidth,
      padding: padding,
      scaleAmount: scaleAmount,
      child: child,
    );
  }
}
