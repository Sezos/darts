import 'dart:io';
import 'dart:ui';

import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/material.dart';

/// Whether Apple's Liquid Glass is available: iOS 26 or later, never under
/// `flutter test`. Tests can force either answer with [debugOverride].
abstract final class GlassCapability {
  static bool? debugOverride;

  static final _major = RegExp(r'(\d+)\.\d');

  /// `'Version 26.0.1 (Build 23A341)'` → 26; unparseable → null.
  static int? majorVersionOf(String version) {
    final m = _major.firstMatch(version);
    return m == null ? null : int.tryParse(m.group(1)!);
  }

  static bool get supported {
    if (debugOverride case final forced?) return forced;
    if (Platform.environment.containsKey('FLUTTER_TEST')) return false;
    if (!Platform.isIOS) return false;
    final major = majorVersionOf(Platform.operatingSystemVersion);
    return major != null && major >= 26;
  }
}

/// Navigator observers the glass package needs so native glass never bleeds
/// through sheets and dialogs. Registered once on the router.
List<NavigatorObserver> glassRouteObservers() => [CNTabBarRouteObserver()];

/// The one place glass is drawn. On iOS 26+ it's Liquid Glass; everywhere
/// else a frosted fallback: [fallbackDecoration] over a backdrop blur.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    required this.cornerRadius,
    required this.fallbackDecoration,
    required this.child,
    super.key,
  });

  final double cornerRadius;
  final BoxDecoration fallbackDecoration;
  final Widget child;

  static const double blurSigma = 18;

  @override
  Widget build(BuildContext context) {
    if (GlassCapability.supported) {
      return LiquidGlassContainer(
        config: LiquidGlassConfig(
          effect: CNGlassEffect.regular,
          shape: CNGlassEffectShape.rect,
          cornerRadius: cornerRadius,
        ),
        child: child,
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(cornerRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(decoration: fallbackDecoration, child: child),
      ),
    );
  }
}
