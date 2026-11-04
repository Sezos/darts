import 'package:darts/core/game/cricket_engine.dart';
import 'package:darts/core/providers/game/game.provider.dart';
import 'package:darts/l10n/l10n.dart';
import 'package:darts/utils/colors.dart';
import 'package:darts/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key, required this.userId, required this.userName});
  final int userId;
  final String userName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allGames = ref.watch(historyProvider);
    final myGames = allGames
        .where((g) => g.users.any((u) => u.id == userId) && g.winner != null)
        .toList();

    if (myGames.isEmpty) {
      return Scaffold(
        backgroundColor: BColors().background,
        appBar: _appBar(userName),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 12,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: BColors().lighter,
                  border: Border.all(color: BColors().border),
                ),
                child: Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedChart,
                    color: BColors().textSecondary,
                    size: 28,
                  ),
                ),
              ),
              BText(context.l10n.statsEmpty, fontWeight: .w700),
              BComment(
                context.l10n.emptyAfterGame,
                color: BColors().textSecondary,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Calculate stats
    final wins = myGames.where((g) => g.winner!.id == userId).length;
    final losses = myGames.length - wins;
    final winRate = (wins / myGames.length * 100).toStringAsFixed(0);

    // Points-based stats only make sense for x01.
    final x01Games = myGames.where((g) => g.mode == GameMode.x01).toList();
    final myRounds = x01Games.expand(
      (g) => g.rounds.where((r) => r.user.id == userId),
    );
    final roundScores = myRounds.map((r) => r.total).toList();
    final avgPPR = roundScores.isEmpty
        ? '-'
        : (roundScores.reduce((a, b) => a + b) / roundScores.length)
              .toStringAsFixed(1);
    final bestRound = roundScores.isEmpty
        ? '-'
        : roundScores.reduce((a, b) => a > b ? a : b).toString();
    final totalDarts = myRounds.fold(0, (n, r) => n + r.dartsThrown);

    // Cricket: marks that counted in each of the player's rounds.
    final cricketGames = myGames.where((g) => g.isCricket).toList();
    final roundMarks = [
      for (final g in cricketGames)
        for (final (id, marks) in CricketEngine.countedMarksPerRound(g))
          if (id == userId) marks,
    ];
    final avgMpr = roundMarks.isEmpty
        ? '-'
        : (roundMarks.reduce((a, b) => a + b) / roundMarks.length)
              .toStringAsFixed(2);
    final bestMarks = roundMarks.isEmpty
        ? '-'
        : roundMarks.reduce((a, b) => a > b ? a : b).toString();

    // Opponent breakdown
    final opponentMap = <String, _OpponentRecord>{};
    for (final g in myGames) {
      final won = g.winner!.id == userId;
      for (final u in g.users) {
        if (u.id == userId) continue;
        final rec = opponentMap[u.name] ?? _OpponentRecord(u.name);
        opponentMap[u.name] = won
            ? rec.copyWith(wins: rec.wins + 1)
            : rec.copyWith(losses: rec.losses + 1);
      }
    }

    return Scaffold(
      backgroundColor: BColors().background,
      appBar: _appBar(userName),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            // Profile header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [BColors().lighter, BColors().surface],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: BColors().primaryBorder),
                boxShadow: [
                  BoxShadow(
                    color: BColors().primaryGlow.withAlpha(40),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Row(
                spacing: 16,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [BColors().primary, BColors().primaryShade],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: BColors().primary.withAlpha(80),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Center(
                      child: BText(
                        userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                        color: BColors().background,
                        fontWeight: .w900,
                        size: .x2l,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      BText(userName, fontWeight: .w900, size: .l),
                      BComment(
                        context.l10n.gamesCount(myGames.length),
                        color: BColors().textSecondary,
                        size: .s,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Win/loss row
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: _BigStatCard(
                    value: wins.toString(),
                    label: context.l10n.wins,
                    icon: HugeIcons.strokeRoundedAward01,
                    color: BColors().primary,
                  ),
                ),
                Expanded(
                  child: _BigStatCard(
                    value: losses.toString(),
                    label: context.l10n.losses,
                    icon: HugeIcons.strokeRoundedSad01,
                    color: BColors().danger,
                  ),
                ),
                Expanded(
                  child: _BigStatCard(
                    value: "$winRate%",
                    label: context.l10n.winRate,
                    icon: HugeIcons.strokeRoundedChart,
                    color: BColors().gold,
                  ),
                ),
              ],
            ),

            // Performance stats, per mode
            if (x01Games.isNotEmpty) ...[
              _SectionHeader(label: context.l10n.x01Performance),
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: _StatTile(label: context.l10n.avgPpr, value: avgPPR),
                  ),
                  Expanded(
                    child: _StatTile(
                      label: context.l10n.bestRound,
                      value: bestRound,
                    ),
                  ),
                  Expanded(
                    child: _StatTile(
                      label: context.l10n.totalDarts,
                      value: totalDarts.toString(),
                    ),
                  ),
                ],
              ),
            ],
            if (cricketGames.isNotEmpty) ...[
              _SectionHeader(label: context.l10n.cricketPerformance),
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: _StatTile(label: context.l10n.avgMpr, value: avgMpr),
                  ),
                  Expanded(
                    child: _StatTile(
                      label: context.l10n.bestRound,
                      value: bestMarks,
                    ),
                  ),
                  Expanded(
                    child: _StatTile(
                      label: context.l10n.games,
                      value: cricketGames.length.toString(),
                    ),
                  ),
                ],
              ),
            ],

            // Opponent breakdown
            if (opponentMap.isNotEmpty) ...[
              _SectionHeader(label: context.l10n.opponents),
              ...opponentMap.values.map(
                (rec) => _OpponentTile(record: rec),
              ),
            ],
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(String name) {
    return AppBar(
      backgroundColor: BColors().background,
      surfaceTintColor: Colors.transparent,
      title: BText(name, fontWeight: .w800, size: .l),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: BColors().border),
      ),
    );
  }
}

class _OpponentRecord {
  final String name;
  final int wins;
  final int losses;
  const _OpponentRecord(this.name, {this.wins = 0, this.losses = 0});
  _OpponentRecord copyWith({int? wins, int? losses}) => _OpponentRecord(
    name,
    wins: wins ?? this.wins,
    losses: losses ?? this.losses,
  );
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return BText(
      label.toUpperCase(),
      fontWeight: .w800,
      size: .xs,
      color: BColors().textSecondary,
      letterSpacing: 1.5,
    );
  }
}

class _BigStatCard extends StatelessWidget {
  const _BigStatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
  final String value;
  final String label;
  final dynamic icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        spacing: 6,
        children: [
          HugeIcon(icon: icon, color: color, size: 20),
          BText(value, fontWeight: .w900, size: .x2l, color: color),
          BComment(label, color: BColors().textSecondary, size: .xs),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: BColors().lighter,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BColors().border),
      ),
      child: Column(
        spacing: 4,
        children: [
          BText(value, fontWeight: .w900, size: .xl),
          BComment(
            label,
            color: BColors().textSecondary,
            size: .x2s,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OpponentTile extends StatelessWidget {
  const _OpponentTile({required this.record});
  final _OpponentRecord record;

  @override
  Widget build(BuildContext context) {
    final total = record.wins + record.losses;
    final winPct = total == 0 ? 0.0 : record.wins / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: BColors().lighter,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: BColors().border),
        ),
        child: Row(
          spacing: 12,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BColors().elevated,
                border: Border.all(color: BColors().border),
              ),
              child: Center(
                child: BText(
                  record.name.isNotEmpty ? record.name[0].toUpperCase() : '?',
                  fontWeight: .w800,
                  size: .s,
                  color: BColors().textSecondary,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  BText(record.name, fontWeight: .w700),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: winPct,
                      backgroundColor: BColors().danger.withAlpha(40),
                      valueColor: AlwaysStoppedAnimation(BColors().primary),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                BText(
                  "${record.wins} – ${record.losses}",
                  fontWeight: .w800,
                  size: .s,
                ),
                BComment(
                  "${(winPct * 100).toStringAsFixed(0)}%",
                  color: BColors().textSecondary,
                  size: .xs,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
