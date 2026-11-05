import 'package:darts/l10n/l10n.dart';
import 'package:darts/utils/colors.dart';
import 'package:darts/utils/glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

/// The main screens under a floating glass tab bar. Each tab keeps its own
/// stack; game setup, games and player stats open full-screen above it.
class AppTabs extends StatelessWidget {
  const AppTabs(this.shell, {super.key});
  final StatefulNavigationShell shell;

  /// Padding for a tab's scrolling list: 16 all round, plus room at the end
  /// to scroll clear of the bar. The tabs run under it, and their bottom
  /// MediaQuery padding is the bar's height.
  static EdgeInsets listPadding(BuildContext context) => EdgeInsets.fromLTRB(
    16,
    16,
    16,
    16 + MediaQuery.paddingOf(context).bottom,
  );

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Back on another tab returns to Play before it leaves the app.
      canPop: shell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) shell.goBranch(0);
      },
      child: Scaffold(
        backgroundColor: BColors().background,
        extendBody: true,
        body: shell,
        bottomNavigationBar: _GlassTabBar(
          current: shell.currentIndex,
          // Tapping the open tab again goes back to its first screen.
          onSelect: (i) {
            if (i != shell.currentIndex) HapticFeedback.selectionClick();
            shell.goBranch(i, initialLocation: i == shell.currentIndex);
          },
        ),
      ),
    );
  }
}

/// A radius-26 glass bar floating 14 from the sides, above the home
/// indicator. Colour, weight and a soft mint capsule mark the open tab.
class _GlassTabBar extends StatelessWidget {
  const _GlassTabBar({required this.current, required this.onSelect});
  final int current;
  final ValueChanged<int> onSelect;

  static const double height = 64;
  static const double radius = 26;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Same order as the branches in router.dart.
    final tabs = [
      (HugeIcons.strokeRoundedTarget01, l10n.play),
      (HugeIcons.strokeRoundedRanking, l10n.ranks),
      (HugeIcons.strokeRoundedUserGroup, l10n.friends),
      (HugeIcons.strokeRoundedClock04, l10n.history),
      (HugeIcons.strokeRoundedSettings01, l10n.settings),
    ];

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: SizedBox(
          height: height,
          child: GlassSurface(
            cornerRadius: radius,
            fallbackDecoration: BoxDecoration(
              color: BColors().surface.withAlpha(185),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: Colors.white.withAlpha(22)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(110),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Row(
                children: [
                  for (final (i, (icon, label)) in tabs.indexed)
                    Expanded(
                      child: _TabItem(
                        icon: icon,
                        label: label,
                        active: i == current,
                        onTap: () => onSelect(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final dynamic icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? BColors().primary : BColors().textSecondary;
    return Semantics(
      button: true,
      selected: active,
      inMutuallyExclusiveGroup: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: active ? BColors().primaryDim : Colors.transparent,
            borderRadius: BorderRadius.circular(_GlassTabBar.radius - 6),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 3,
            children: [
              HugeIcon(icon: icon, color: color, size: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
