import 'package:darts/core/providers/game/game.provider.dart';
import 'package:darts/core/providers/user/user.provider.dart';
import 'package:darts/utils/card.dart';
import 'package:darts/utils/colors.dart';
import 'package:darts/utils/constants.dart';
import 'package:darts/utils/format.dart';
import 'package:darts/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:moon_design/moon_design.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    var matches = ref.watch(
      historyProvider,
    );
    var user = ref.watch(userProvider);
    return Scaffold(
      appBar: AppBar(
        title: BSubtitle(
          "Тоглолтын түүх",
          fontWeight: .w800,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              BSubtitle("Тоглолтууд"),
              smallColumnSpacer,
              Expanded(
                child: ListView.builder(
                  itemCount: matches.length,

                  itemBuilder: (context, index) {
                    final match = matches[index];
                    bool isWin = match.rounds.last.user.id == user.id;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: BCard(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      HugeIcon(
                                        icon: HugeIcons.strokeRoundedCalendar01,
                                      ),
                                      BText(formatDate(match.date)),
                                    ],
                                  ),
                                ),
                                MoonChip.text(
                                  label: BText(
                                    match.startFrom.toString(),
                                    fontWeight: .w800,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                MoonAvatar(
                                  borderRadius: .circular(200),
                                  avatarSize: .xl,
                                  backgroundColor: BColors().primary.withAlpha(
                                    100,
                                  ),
                                  content: HugeIcon(
                                    icon: HugeIcons.strokeRoundedDart,
                                    color: BColors().primary,
                                  ),
                                ),
                                mediumRowSpacer,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: .start,
                                    children: [
                                      BSubtitle(
                                        match.users
                                            .map((e) => e.name)
                                            .join(" vs "),
                                        maxLine: 2,
                                        fontWeight: .w900,
                                      ),
                                      if (match.users.any(
                                        (e) => e.id == user.id,
                                      ))
                                        Row(
                                          children: [
                                            Icon(
                                              isWin
                                                  ? Icons.check_outlined
                                                  : Icons.cancel_outlined,
                                              color: isWin
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                            smallRowSpacer,
                                            BComment(
                                              isWin ? "Ялсан" : "Ялагдсан",
                                              color: isWin
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ],
                                        )
                                      else
                                        BComment(
                                          "Ялагч: ${match.rounds.last.user.name}",
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
