import 'package:darts/core/game/skill_rating.dart';
import 'package:darts/l10n/l10n.dart';
import 'package:darts/utils/colors.dart';
import 'package:darts/utils/interaction.dart';
import 'package:darts/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// Colour and icon for each tier, climbing from dull to gold.
extension TierStyle on Tier {
  Color get color => switch (this) {
    Tier.rookie => const Color(0xFF8A9A93),
    Tier.pubThrower => const Color(0xFFC07A4A),
    Tier.ocheRegular => const Color(0xFF3FC1C9),
    Tier.trebleHunter => const Color(0xFF00E896),
    Tier.checkoutPro => const Color(0xFF4D9DFF),
    Tier.tonMachine => const Color(0xFFA66BFF),
    Tier.club180 => const Color(0xFFFF6B35),
    Tier.nineDarter => const Color(0xFFF5C542),
  };

  dynamic get icon => switch (this) {
    Tier.rookie => HugeIcons.strokeRoundedDart,
    Tier.pubThrower => HugeIcons.strokeRoundedTarget02,
    Tier.ocheRegular => HugeIcons.strokeRoundedTarget03,
    Tier.trebleHunter => HugeIcons.strokeRoundedZap,
    Tier.checkoutPro => HugeIcons.strokeRoundedMedal01,
    Tier.tonMachine => HugeIcons.strokeRoundedRocket01,
    Tier.club180 => HugeIcons.strokeRoundedFire,
    Tier.nineDarter => HugeIcons.strokeRoundedCrown,
  };

  String label(AppLocalizations l10n) => switch (this) {
    Tier.rookie => l10n.tierRookie,
    Tier.pubThrower => l10n.tierPubThrower,
    Tier.ocheRegular => l10n.tierOcheRegular,
    Tier.trebleHunter => l10n.tierTrebleHunter,
    Tier.checkoutPro => l10n.tierCheckoutPro,
    Tier.tonMachine => l10n.tierTonMachine,
    Tier.club180 => l10n.tierClub180,
    Tier.nineDarter => l10n.tierNineDarter,
  };
}

extension RankLabel on Rank {
  /// "Treble Hunter II".
  String label(AppLocalizations l10n) =>
      '${tier.label(l10n)} ${'I' * division}';

  /// The rank one division up, or null at Nine-Darter III.
  Rank? get next => step >= 23
      ? null
      : Rank(Tier.values[(step + 1) ~/ 3], (step + 1) % 3 + 1, 0);
}

extension RatingText on SkillRating {
  /// "45.2 avg" or "2.31 MPR"; null while in placement.
  String? valueLabel(AppLocalizations l10n) {
    if (value == null) return null;
    return mode == RatingMode.x01
        ? l10n.ratingAvg(value!.toStringAsFixed(1))
        : l10n.ratingMpr(value!.toStringAsFixed(2));
  }

  /// "+1.8" or "−0.6"; null when there is no change to show.
  String? get changeLabel {
    final c = change;
    if (c == null) return null;
    final digits = mode == RatingMode.x01 ? 1 : 2;
    if (c.abs() < (mode == RatingMode.x01 ? 0.05 : 0.005)) return '±0';
    return '${c > 0 ? '+' : '−'}${c.abs().toStringAsFixed(digits)}';
  }
}

/// A hexagonal badge in the tier's colour with its icon and division pips.
/// Players still in placement get a grey badge with a question mark.
class RankBadge extends StatelessWidget {
  const RankBadge(this.rank, {this.size = 44, super.key});
  final Rank? rank;
  final double size;

  @override
  Widget build(BuildContext context) {
    final r = rank;
    final color = r?.tier.color ?? BColors().textSecondary;
    final top = r != null && r.tier.index >= Tier.club180.index;
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size * 1.12,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size,
              height: size,
              decoration: ShapeDecoration(
                shape: StarBorder.polygon(
                  sides: 6,
                  rotation: 30,
                  pointRounding: 0.25,
                  side: BorderSide(color: color, width: size * 0.05),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withAlpha(90), color.withAlpha(25)],
                ),
                shadows: top
                    ? [BoxShadow(color: color.withAlpha(110), blurRadius: 14)]
                    : null,
              ),
              child: Center(
                child: r == null
                    ? BText(
                        '?',
                        color: color,
                        fontWeight: .w900,
                        size: size >= 40 ? .l : .s,
                      )
                    : HugeIcon(
                        icon: r.tier.icon,
                        color: color,
                        size: size * 0.46,
                        strokeWidth: 2,
                      ),
              ),
            ),
            if (r != null)
              Positioned(
                bottom: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: size * 0.05,
                  children: [
                    for (var i = 1; i <= 3; i++)
                      Container(
                        width: size * 0.13,
                        height: size * 0.13,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i <= r.division ? color : BColors().background,
                          border: Border.all(color: color, width: 1.2),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// "+1.8" in mint, "−0.6" in red, nothing when there's no change.
class RatingChange extends StatelessWidget {
  const RatingChange(this.rating, {super.key});
  final SkillRating rating;

  @override
  Widget build(BuildContext context) {
    final label = rating.changeLabel;
    if (label == null) return const SizedBox.shrink();
    final c = rating.change!;
    final color = label == '±0'
        ? BColors().textSecondary
        : c > 0
        ? BColors().primary
        : BColors().danger;
    return BText(label, color: color, fontWeight: .w800, size: .xs);
  }
}

/// A player's rank in one mode: badge, rank name, rating and the way to the
/// next division. Players in placement see how many games they still need.
class RankCard extends StatelessWidget {
  const RankCard(this.rating, {required this.title, super.key});
  final SkillRating rating;
  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rank = rating.rank;
    final color = rank?.tier.color ?? BColors().textSecondary;
    final next = rank?.next;
    return Semantics(
      container: true,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: BColors().lighter,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(rank == null ? 40 : 90)),
        ),
        child: Row(
          spacing: 14,
          children: [
            RankBadge(rank, size: 52),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  BText(
                    title.toUpperCase(),
                    color: BColors().textSecondary,
                    size: .xs,
                    fontWeight: .w800,
                    letterSpacing: 1.2,
                  ),
                  BText(
                    rank?.label(l10n) ??
                        l10n.placementProgress(rating.games, placementGames),
                    fontWeight: .w900,
                    size: .l,
                    color: rank == null ? BColors().textPrimary : color,
                  ),
                  if (rank == null)
                    BComment(
                      l10n.placementHint(placementGames - rating.games),
                      color: BColors().textSecondary,
                      size: .s,
                    )
                  else ...[
                    Row(
                      spacing: 8,
                      children: [
                        BComment(
                          rating.valueLabel(l10n)!,
                          color: BColors().textPrimary,
                          size: .s,
                        ),
                        RatingChange(rating),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: rank.progress,
                        minHeight: 5,
                        color: color,
                        backgroundColor: BColors().background,
                      ),
                    ),
                    BComment(
                      next == null
                          ? l10n.topRank
                          : l10n.nextRank(next.label(l10n)),
                      color: BColors().textSecondary,
                      size: .xs,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One line of a leaderboard: place, badge, name, rank and rating.
class LeaderboardRow extends StatelessWidget {
  const LeaderboardRow({
    required this.position,
    required this.name,
    required this.rating,
    required this.onTap,
    this.highlight = false,
    super.key,
  });

  /// 1-based place on the board; null for players still in placement.
  final int? position;
  final String name;
  final SkillRating rating;
  final VoidCallback onTap;

  /// Outline the row in mint, for the owner's own line.
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rank = rating.rank;
    final rankText =
        rank?.label(l10n) ??
        l10n.placementProgress(rating.games, placementGames);
    final value = rating.valueLabel(l10n);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Pressable(
        semanticLabel: [
          if (position != null) '$position',
          name,
          rankText,
          ?value,
        ].join(', '),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: BColors().lighter,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: highlight ? BColors().primaryBorder : BColors().border,
            ),
          ),
          child: Row(
            spacing: 12,
            children: [
              SizedBox(
                width: 22,
                child: BText(
                  position == null ? '–' : '$position',
                  fontWeight: .w900,
                  color: position == 1
                      ? BColors().gold
                      : BColors().textSecondary,
                  textAlign: .center,
                ),
              ),
              RankBadge(rank, size: 38),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    BText(
                      name,
                      fontWeight: .w800,
                      maxLine: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    BComment(
                      rankText,
                      color: rank?.tier.color ?? BColors().textSecondary,
                      size: .s,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 2,
                children: [
                  if (value != null) BText(value, fontWeight: .w800, size: .s),
                  RatingChange(rating),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
