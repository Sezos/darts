import 'package:darts/core/providers/game/game.provider.dart';
import 'package:darts/core/providers/user/user.provider.dart';
import 'package:darts/utils/colors.dart';
import 'package:darts/utils/dialogs.dart';
import 'package:darts/utils/interaction.dart';
import 'package:darts/utils/format.dart';
import 'package:darts/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(historyProvider);
    final user = ref.watch(userProvider);
    // Newest first; only finished games (they have a winner).
    final finished = matches.reversed.where((m) => m.winner != null).toList();

    Future<bool> confirmDelete() => showConfirmDialog(
      context,
      title: "Тоглолтыг устгах уу?",
      message: "Энэ тоглолт түүх болон статистикаас бүрмөсөн устна.",
      confirmLabel: "Устгах",
      destructive: true,
    );

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
      body: finished.isEmpty
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
                          child: Pressable(
                            semanticLabel: "${e.value}: статистик",
                            onTap: () => context.push(
                              '/stats',
                              extra: {
                                'userId': e.key,
                                'userName': e.value,
                              },
                            ),
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
                                        e.value.isNotEmpty
                                            ? e.value[0].toUpperCase()
                                            : '?',
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
                    itemCount: finished.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final match = finished[index];
                      final winnerUser = match.winner!;
                      final isWin = winnerUser.id == user.id;
                      final isParticipant = match.users.any(
                        (e) => e.id == user.id,
                      );
                      final winner = winnerUser.name;

                      return Dismissible(
                        // Keyed by the game, not its position, so deleting
                        // one card never animates another.
                        key: ObjectKey(match),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: BColors().danger.withAlpha(40),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: BColors().danger.withAlpha(60),
                            ),
                          ),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedDelete01,
                            color: BColors().danger,
                            size: 22,
                          ),
                        ),
                        confirmDismiss: (_) => confirmDelete(),
                        onDismissed: (_) {
                          ref.read(historyProvider.notifier).deleteGame(match);
                        },
                        // Swipe isn't reachable by screen readers; expose
                        // delete as a custom action too.
                        child: Semantics(
                          customSemanticsActions: {
                            const CustomSemanticsAction(
                              label: "Устгах",
                            ): () async {
                              if (await confirmDelete()) {
                                ref
                                    .read(historyProvider.notifier)
                                    .deleteGame(match);
                              }
                            },
                          },
                          child: _HistoryCard(
                            match: match,
                            isWin: isWin,
                            isParticipant: isParticipant,
                            winner: winner,
                          ),
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
    final resultColor = isWin ? BColors().primary : BColors().danger;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BColors().lighter,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isParticipant
              ? (isWin
                    ? BColors().primaryBorder
                    : BColors().danger.withAlpha(50))
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
                  ? (isWin
                        ? BColors().primaryDim
                        : BColors().danger.withAlpha(20))
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
