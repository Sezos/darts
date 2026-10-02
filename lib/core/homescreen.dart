import 'package:darts/core/providers/game/game.provider.dart';
import 'package:darts/core/providers/game/ongoing_game.provider.dart';
import 'package:darts/core/providers/user/user.provider.dart';
import 'package:darts/utils/ads.dart';
import 'package:darts/utils/analytics.dart';
import 'package:darts/utils/colors.dart';
import 'package:darts/utils/dialogs.dart';
import 'package:darts/utils/interaction.dart';
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
    final avg = averagePpr(matches, ref.watch(userProvider).id);
    final ongoing = ref.watch(ongoingGameProvider);
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
              excludeFromSemantics: true,
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
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
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
                          IconTile(
                            icon: HugeIcons.strokeRoundedSettings01,
                            label: "Тохиргоо",
                            onTap: () => context.push("/settings"),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Hero image
                    SizedBox(
                      width: (size.width * 0.5).clamp(140.0, 260.0),
                      child: Image.asset(
                        "assets/images/homescreen.png",
                        excludeFromSemantics: true,
                      ),
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

                    if (ongoing != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _ContinueCard(
                          game: ongoing.game,
                          onResume: () => context.push("/game", extra: ongoing),
                          onDiscard: () async {
                            final discard = await showConfirmDialog(
                              context,
                              title: "Тоглолтыг хаях уу?",
                              message: "Дуусаагүй тоглолтын оноо устана.",
                              confirmLabel: "Хаях",
                              destructive: true,
                            );
                            if (discard) {
                              ref.read(ongoingGameProvider.notifier).clear();
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // CTA buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        spacing: 12,
                        children: [
                          Expanded(
                            child: PrimaryButton(
                              label: ongoing != null ? "Шинэ тоглолт" : "Эхлэх",
                              icon: HugeIcons.strokeRoundedPlay,
                              onTap: () => context.push("/players"),
                            ),
                          ),
                          IconTile(
                            icon: HugeIcons.strokeRoundedClock04,
                            label: "Түүх",
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

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.game,
    required this.onResume,
    required this.onDiscard,
  });
  final Game game;
  final VoidCallback onResume;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final players = game.users.map((u) => u.name).join(" vs ");

    return Container(
      decoration: BoxDecoration(
        color: BColors().primaryDim,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BColors().primaryBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Pressable(
              onTap: onResume,
              semanticLabel:
                  "Тоглолт үргэлжлүүлэх, ${game.startFrom}, $players",
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
                child: Row(
                  spacing: 12,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: BColors().primary,
                      ),
                      child: Center(
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedPlay,
                          color: BColors().onPrimary,
                          size: 18,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          BText(
                            "Тоглолт үргэлжлүүлэх",
                            fontWeight: .w800,
                            color: BColors().primary,
                          ),
                          BComment(
                            "${game.startFrom} · $players",
                            color: BColors().textSecondary,
                            size: .s,
                            maxLine: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconAction(
            icon: HugeIcons.strokeRoundedCancel01,
            label: "Тоглолтыг хаях",
            onTap: onDiscard,
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
