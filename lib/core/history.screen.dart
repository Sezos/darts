import 'package:darts/core/providers/game/game.provider.dart';
import 'package:darts/core/providers/user/user.provider.dart';
import 'package:darts/utils/colors.dart';
import 'package:darts/utils/format.dart';
import 'package:darts/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(historyProvider);
    final user = ref.watch(userProvider);

    // Collect unique players across all games for the stats header
    final allPlayers = <int, String>{};
    for (final g in matches) {
      for (final u in g.users) {
        allPlayers[u.id] = u.name;
      }
    }

    return Scaffold(
      backgroundColor: BColors().background,
      appBar: AppBar(
        backgroundColor: BColors().background,
        surfaceTintColor: Colors.transparent,
        title: BText("Түүх", fontWeight: .w800, size: .l),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: BColors().border),
        ),
      ),
      body: matches.isEmpty
          ? _EmptyState()
          : Column(
              children: [
                // Player chips for quick stats access
                if (allPlayers.isNotEmpty)
                  SizedBox(
                    height: 52,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      children: allPlayers.entries.map((e) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => context.push('/stats', extra: {
                              'userId': e.key,
                              'userName': e.value,
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: BColors().lighter,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: BColors().border),
                              ),
                              child: Row(
                                spacing: 6,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: e.key == user.id
                                          ? BColors().primaryDim
                                          : BColors().elevated,
                                    ),
                                    child: Center(
                                      child: BText(
                                        e.value[0].toUpperCase(),
                                        size: .x2s,
                                        fontWeight: .w800,
                                        color: e.key == user.id
                                            ? BColors().primary
                                            : BColors().textSecondary,
                                      ),
                                    ),
                                  ),
                                  BText(
                                    e.value,
                                    size: .s,
                                    fontWeight: .w700,
                                    color: e.key == user.id
                                        ? BColors().primary
                                        : BColors().textPrimary,
                                  ),
                                  HugeIcon(
                                    icon: HugeIcons.strokeRoundedChart,
                                    size: 12,
                                    color: BColors().textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: matches.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      // Show newest first
                      final realIndex = matches.length - 1 - index;
                      final match = matches[realIndex];
                      if (match.rounds.isEmpty) return const SizedBox.shrink();
                      final isWin = match.rounds.last.user.id == user.id;
                      final isParticipant =
                          match.users.any((e) => e.id == user.id);
                      final winner = match.rounds.last.user.name;

                      return Dismissible(
                        key: Key('game_$realIndex'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(40),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.red.withAlpha(60)),
                          ),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedDelete01,
                            color: Colors.red,
                            size: 22,
                          ),
                        ),
                        confirmDismiss: (_) async {
                          bool confirm = false;
                          await showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: BColors().surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: BColors().border),
                              ),
                              title: BText(
                                "Устгах уу?",
                                fontWeight: .w800,
                              ),
                              content: BComment(
                                "Тоглолтыг бүрмөсөн устгана",
                                color: BColors().textSecondary,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => ctx.pop(),
                                  child: BText(
                                    "Болих",
                                    color: BColors().textSecondary,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    confirm = true;
                                    ctx.pop();
                                  },
                                  child: BText(
                                    "Устгах",
                                    color: Colors.red,
                                    fontWeight: .w700,
                                  ),
                                ),
                              ],
                            ),
                          );
                          return confirm;
                        },
                        onDismissed: (_) {
                          ref
                              .read(historyProvider.notifier)
                              .deleteGame(realIndex);
                        },
                        child: _HistoryCard(
                          match: match,
                          isWin: isWin,
                          isParticipant: isParticipant,
                          winner: winner,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.match,
    required this.isWin,
    required this.isParticipant,
    required this.winner,
  });
  final Game match;
  final bool isWin;
  final bool isParticipant;
  final String winner;

  @override
  Widget build(BuildContext context) {
    final resultColor = isWin ? BColors().primary : Colors.red;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BColors().lighter,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isParticipant
              ? (isWin ? BColors().primaryBorder : Colors.red.withAlpha(50))
              : BColors().border,
        ),
      ),
      child: Row(
        spacing: 14,
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isParticipant
                  ? (isWin ? BColors().primaryDim : Colors.red.withAlpha(20))
                  : BColors().elevated,
            ),
            child: Center(
              child: HugeIcon(
                icon: isParticipant
                    ? (isWin
                        ? HugeIcons.strokeRoundedAward01
                        : HugeIcons.strokeRoundedSad01)
                    : HugeIcons.strokeRoundedDart,
                color: isParticipant ? resultColor : BColors().textSecondary,
                size: 20,
              ),
            ),
          ),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                BText(
                  match.users.map((e) => e.name).join(" vs "),
                  fontWeight: .w800,
                  maxLine: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  spacing: 6,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedCalendar01,
                      color: BColors().textSecondary,
                      size: 12,
                    ),
                    BComment(
                      formatDate(match.date),
                      color: BColors().textSecondary,
                      size: .s,
                    ),
                  ],
                ),
                if (isParticipant)
                  BComment(
                    isWin ? "Ялсан" : "Ялагдсан — $winner яллаа",
                    color: resultColor,
                    size: .s,
                  )
                else
                  BComment(
                    "Ялагч: $winner",
                    color: BColors().textSecondary,
                    size: .s,
                  ),
              ],
            ),
          ),

          // Game type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: BColors().primaryDim,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: BColors().primaryBorder),
            ),
            child: BText(
              match.startFrom.toString(),
              color: BColors().primary,
              fontWeight: .w800,
              size: .s,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 12,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: BColors().lighter,
              border: Border.all(color: BColors().border),
            ),
            child: Center(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedClock04,
                color: BColors().textSecondary,
                size: 30,
              ),
            ),
          ),
          BText("Тоглолт байхгүй", fontWeight: .w700, size: .l),
          BComment(
            "Тоглолт дууссаны дараа энд харагдана",
            color: BColors().textSecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
