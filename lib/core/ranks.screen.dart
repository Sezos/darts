import 'package:darts/core/game/skill_rating.dart';
import 'package:darts/core/providers/game/game.provider.dart';
import 'package:darts/core/providers/players/players.provider.dart';
import 'package:darts/core/providers/user/user.provider.dart';
import 'package:darts/core/rank_widgets.dart';
import 'package:darts/core/tabs.dart';
import 'package:darts/l10n/l10n.dart';
import 'package:darts/utils/colors.dart';
import 'package:darts/utils/interaction.dart';
import 'package:darts/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Leaderboard of everyone who has played on this phone, per mode.
class RanksScreen extends ConsumerStatefulWidget {
  const RanksScreen({super.key});

  @override
  ConsumerState<RanksScreen> createState() => _RanksScreenState();
}

typedef _Entry = ({int id, String name, SkillRating rating});

class _RanksScreenState extends ConsumerState<RanksScreen> {
  var mode = RatingMode.x01;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final history = ref.watch(historyProvider);
    final me = ref.watch(userProvider).id;

    // Everyone in the history, under their current name if still saved.
    final saved = {for (final p in ref.watch(playersProvider)) p.id: p.name};
    final names = <int, String>{
      for (final g in history)
        for (final u in g.users) u.id: saved[u.id] ?? u.name,
    };
    final entries = <_Entry>[
      for (final e in names.entries)
        (id: e.key, name: e.value, rating: skillRating(history, e.key, mode)),
    ].where((e) => e.rating.games > 0);
    final ranked = entries.where((e) => !e.rating.isPlacement).toList()
      ..sort((a, b) => b.rating.value!.compareTo(a.rating.value!));
    final placement = entries.where((e) => e.rating.isPlacement).toList()
      ..sort((a, b) => b.rating.games.compareTo(a.rating.games));

    return Scaffold(
      backgroundColor: BColors().background,
      appBar: AppBar(
        backgroundColor: BColors().background,
        surfaceTintColor: Colors.transparent,
        title: BText(l10n.ranks, fontWeight: .w800, size: .l),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: BColors().border),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: AppTabs.listPadding(context),
              children: [
                SegmentedPicker(
                  options: {
                    RatingMode.x01: 'x01',
                    RatingMode.cricket: 'Cricket',
                  },
                  selected: mode,
                  onSelect: (m) => setState(() => mode = m),
                ),
                const SizedBox(height: 10),
                BComment(
                  mode == RatingMode.x01
                      ? l10n.ranksX01Hint
                      : l10n.ranksCricketHint,
                  color: BColors().textSecondary,
                  size: .s,
                ),
                const SizedBox(height: 16),
                if (ranked.isEmpty && placement.isEmpty)
                  _Empty()
                else ...[
                  for (final (i, e) in ranked.indexed)
                    _row(context, i + 1, e, me),
                  if (placement.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                      child: BText(
                        l10n.unranked.toUpperCase(),
                        fontWeight: .w800,
                        size: .xs,
                        color: BColors().textSecondary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    for (final e in placement) _row(context, null, e, me),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _row(BuildContext context, int? position, _Entry e, int me) =>
    LeaderboardRow(
      position: position,
      name: e.name,
      rating: e.rating,
      highlight: e.id == me,
      onTap: () => context.push(
        '/stats',
        extra: {'userId': e.id, 'userName': e.name},
      ),
    );

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        spacing: 10,
        children: [
          const RankBadge(null, size: 56),
          BText(context.l10n.ranksEmpty, fontWeight: .w700, size: .l),
          BComment(
            context.l10n.ranksEmptyHint(placementGames),
            color: BColors().textSecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
