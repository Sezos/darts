import 'package:darts/core/providers/game/game.provider.dart';
import 'package:darts/utils/ads.dart';
import 'package:darts/utils/analytics.dart';
import 'package:darts/utils/colors.dart';
import 'package:darts/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
class Homescreen extends ConsumerStatefulWidget {
  const Homescreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomescreenState();
}

class _HomescreenState extends ConsumerState<Homescreen> {
  @override
  void initState() {
    super.initState();
    Analytics.screen('home');
  }

  @override
  Widget build(BuildContext context) {
    final matches = ref.watch(historyProvider);
    final avg = ref.read(historyProvider.notifier).getAverage();
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: BColors().background,
      body: Stack(
        children: [
          // Background image + dark gradient overlay
          Positioned.fill(
            child: Image.asset(
              "assets/images/bg.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    BColors().background.withAlpha(200),
                    BColors().background.withAlpha(230),
                    BColors().background,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Radial glow behind hero image
          Positioned(
            top: size.height * 0.12,
            left: size.width / 2 - 120,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    BColors().primaryGlow,
                    BColors().primary.withAlpha(0),
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BText(
                            "ДАРЦНЫ ОНОО",
                            fontWeight: .w900,
                            size: .xl,
                            letterSpacing: 2.5,
                          ),
                          BComment(
                            "Тоглолтын бүртгэл",
                            color: BColors().textSecondary,
                            size: .s,
                          ),
                        ],
                      ),
                      const Spacer(),
                      _GlassIconButton(
                        icon: HugeIcons.strokeRoundedSettings01,
                        onTap: () => context.push("/settings"),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Hero image
                SizedBox(
                  width: (size.width * 0.5).clamp(140.0, 260.0),
                  child: Image.asset("assets/images/homescreen.png"),
                ),

                const Spacer(),

                // Stats cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    spacing: 12,
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: "Тоглосон",
                          value: matches.length.toString(),
                          icon: HugeIcons.strokeRoundedTarget01,
                        ),
                      ),
                      Expanded(
                        child: _StatCard(
                          label: "Дундаж оноо",
                          value: avg,
                          icon: HugeIcons.strokeRoundedChart,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // CTA buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    spacing: 12,
                    children: [
                      Expanded(
                        child: _GlowButton(
                          label: "Эхлэх",
                          icon: HugeIcons.strokeRoundedPlay,
                          onTap: () => context.push("/players"),
                        ),
                      ),
                      _GlassIconButton(
                        icon: HugeIcons.strokeRoundedClock04,
                        size: 52,
                        onTap: () => context.push("/history"),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Non-intrusive banner — only shows once loaded
                const HomeBannerAd(),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reusable sub-widgets ────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final dynamic icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: BColors().lighter,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BColors().border),
        boxShadow: [
          BoxShadow(
            color: BColors().primaryGlow.withAlpha(40),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        spacing: 12,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: BColors().primaryDim,
            ),
            child: Center(
              child: HugeIcon(
                icon: icon,
                color: BColors().primary,
                size: 18,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BText(
                value,
                fontWeight: .w900,
                size: .x2l,
                color: BColors().textPrimary,
              ),
              BComment(
                label,
                color: BColors().textSecondary,
                size: .s,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlowButton extends StatelessWidget {
  const _GlowButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final dynamic icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [
              BColors().primary,
              const Color(0xFF00C278),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: BColors().primary.withAlpha(90),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            HugeIcon(
              icon: icon,
              color: BColors().background,
              strokeWidth: 2.5,
              size: 20,
            ),
            BText(
              label,
              color: BColors().background,
              fontWeight: .w900,
              size: .l,
              letterSpacing: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.onTap,
    this.size = 44,
  });
  final dynamic icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
            color: BColors().textPrimary,
            size: 20,
          ),
        ),
      ),
    );
  }
}
