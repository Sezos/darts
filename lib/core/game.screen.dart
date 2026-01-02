import 'package:darts/core/helper/darts.helper.dart';
import 'package:darts/core/providers/game/game.provider.dart';
import 'package:darts/core/providers/user/user.provider.dart';
import 'package:darts/utils/card.dart';
import 'package:darts/utils/colors.dart';
import 'package:darts/utils/constants.dart';
import 'package:darts/utils/format.dart';
import 'package:darts/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:moon_design/moon_design.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen(this.game, {super.key});
  final Game game;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GameScreenState();
}

enum DartType { s, d, t }

extension DartTypeToNumber on DartType {
  int getNumber() => switch (this) {
    .s => 1,
    .d => 2,
    .t => 3,
  };
}

class _FinalScore {
  final String name;
  final int remaining;
  const _FinalScore(this.name, this.remaining);
}

class _GameScreenState extends ConsumerState<GameScreen> {
  Game game = Game(date: DateTime.now(), startFrom: 999);
  int currentUserIndex = 0;
  Round currentRound = Round(user: User(id: -1, name: 'z'));
  DartType dartType = .s;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      // DeviceOrientation.landscapeLeft,
      // DeviceOrientation.landscapeRight,
    ]);

    setState(() {
      game = widget.game;
      currentRound = Round(
        user: widget.game.users.first,
      );
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: BSubtitle(
          "${game.startFrom} - ${formatDate(game.date)}",
          fontWeight: .w900,
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isPortrait ? portrait() : landscape(),
      ),
    );
  }

  Future<void> showMoonGameFinishedDialog({
    required String winnerName,
    List<_FinalScore>? finalScores,
    VoidCallback? onNewGame,
    VoidCallback? onClose,
  }) {
    return showMoonModal<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return MoonModal(
          backgroundColor: BColors().background,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.emoji_events, color: Colors.amber),
                    SizedBox(width: 8),
                    Text(
                      'Тоглолт дууслаа',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '$winnerName Яллаа!',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),

                if (finalScores != null && finalScores.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Оноонууд',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  ...finalScores.map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text('${e.name}: ${e.remaining}'),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: MoonTextButton(
                        label: const Text('Дуусгах'),
                        onTap: () {
                          context.pop();
                          if (onClose != null) onClose();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MoonFilledButton(
                        label: const Text('Шинэ тоглолт'),
                        onTap: () {
                          context.pop();
                          if (onNewGame != null) onNewGame();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void onTapNumber(int number) async {
    HapticFeedback.mediumImpact();

    void nextPlayer() {
      game.rounds.add(currentRound);
      currentUserIndex = ((currentUserIndex + 1) % game.users.length).toInt();
      currentRound = Round(user: game.users[currentUserIndex]);
      setState(() {
        dartType = .s;
      });
    }

    final player = game.users[currentUserIndex];
    int remaining = getUserPoint(player).toInt();

    if (remaining <= 1) {
      currentRound.dart1 ??= 0;
      currentRound.dart2 ??= 0;
      currentRound.dart3 ??= 0;
      nextPlayer();
      return;
    }

    final int mult = dartType.getNumber();
    final int dartScore = number * mult;

    if (currentRound.dart1 == null) {
      currentRound.dart1 = dartScore;
    } else if (currentRound.dart2 == null) {
      currentRound.dart2 = dartScore;
    } else {
      currentRound.dart3 = dartScore;
    }

    remaining = getUserPoint(player).toInt();

    bool isDoubleFinish = false;
    if (remaining == 0) {
      isDoubleFinish = (mult == 2);
    }

    final bool bust =
        (remaining < 0) ||
        (remaining == 1) ||
        (remaining == 0 && !isDoubleFinish);

    if (bust) {
      currentRound
        ..dart1 = 0
        ..dart2 = 0
        ..dart3 = 0;
      nextPlayer();
      return;
    }

    if (remaining == 0 && isDoubleFinish) {
      final winner = game.users[currentUserIndex];

      showMoonGameFinishedDialog(
        winnerName: winner.name,
        finalScores: game.users
            .map((u) => _FinalScore(u.name, getUserPoint(u).toInt()))
            .toList(),
        onNewGame: () {
          nextPlayer();
          ref.read(historyProvider.notifier).addGame(game);
          context.pushReplacement(
            "/game",
            extra: Game(
              startFrom: widget.game.startFrom,
              date: DateTime.now(),
              users: widget.game.users.reversed.toList(),
              rounds: [],
            ),
          );
        },
        onClose: () {
          nextPlayer();
          ref.read(historyProvider.notifier).addGame(game);

          context.go("/");
        },
      );

      return;
    }

    if (currentRound.dart1 != null &&
        currentRound.dart2 != null &&
        currentRound.dart3 != null) {
      nextPlayer();
      return;
    }

    setState(() {
      dartType = .s;
    });
  }

  void onTapBack() {
    HapticFeedback.mediumImpact();
    if (currentRound.dart3 != null) {
      currentRound.dart3 = null;
    } else if (currentRound.dart2 != null) {
      currentRound.dart2 = null;
    } else if (currentRound.dart1 != null) {
      currentRound.dart1 = null;
    } else {
      if (game.rounds.isEmpty) {
        return;
      }
      currentRound = game.rounds.last;
      currentUserIndex = game.users.indexOf(currentRound.user);
      game.rounds.removeLast();
    }
    setState(() {
      dartType = .s;
    });
  }

  void onTapForward() {
    currentRound.dart1 ??= 0;
    currentRound.dart2 ??= 0;
    currentRound.dart3 ??= 0;
    game.rounds.add(currentRound);

    currentUserIndex = ((currentUserIndex + 1) % game.users.length).toInt();
    currentRound = Round(user: game.users[currentUserIndex]);
    setState(() {});
  }

  num getUserPoint(User player) {
    return game.startFrom -
        game.rounds
            .where((e) => e.user == player)
            .map(
              (e) => (e.dart1 ?? 0) + (e.dart2 ?? 0) + (e.dart3 ?? 0),
            )
            .fold(0, (value, e) => value + e) -
        (currentRound.user == player
            ? (currentRound.dart1 ?? 0) +
                  (currentRound.dart2 ?? 0) +
                  (currentRound.dart3 ?? 0)
            : 0);
  }

  Widget portrait() {
    return Column(
      children: [
        SizedBox(
          height: 90,
          child: Row(
            spacing: 16,
            children: [
              ...game.users.map(
                (player) {
                  bool curr = game.users.indexOf(player) == currentUserIndex;
                  var userPoint = getUserPoint(player);
                  final ppr =
                      (game.rounds.where((e) => e.user == player).isEmpty
                              ? 0
                              : game.rounds
                                        .where((e) => e.user == player)
                                        .fold(
                                          0,
                                          (value, e) =>
                                              value +
                                              (e.dart1 ?? 0) +
                                              (e.dart2 ?? 0) +
                                              (e.dart3 ?? 0),
                                        ) /
                                    game.rounds
                                        .where((e) => e.user == player)
                                        .length)
                          .toStringAsFixed(1);

                  return Expanded(
                    child: BCard(
                      color: curr ? BColors().primary : null,
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              children: [
                                BComment(
                                  player.name,
                                  color: curr ? BColors().background : null,
                                  fontWeight: .w800,
                                ),
                                BSubtitle(
                                  userPoint.toString(),
                                  color: curr ? BColors().background : null,
                                  fontWeight: .w800,
                                ),
                                smallColumnSpacer,
                                BComment(
                                  "PPR: $ppr",
                                ),
                              ],
                            ),
                          ),
                          if (game.rounds.isNotEmpty &&
                              game.rounds.last.user == player)
                            Positioned(
                              child: BText(
                                "${((game.rounds.last.dart1 ?? 0) + (game.rounds.last.dart1 ?? 0) + (game.rounds.last.dart1 ?? 0),)}",
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        smallColumnSpacer,
        BCard(
          child: Row(
            children: [
              Expanded(
                child: currentRound.dart1 == null
                    ? HugeIcon(
                        icon: HugeIcons.strokeRoundedDart,
                        color: BColors().primary,
                      )
                    : BText(
                        currentRound.dart1 == 0
                            ? "Алдсан"
                            : currentRound.dart1!.toString(),
                        fontWeight: .w800,
                        textAlign: .center,
                      ),
              ),
              Expanded(
                child: currentRound.dart2 == null
                    ? HugeIcon(
                        icon: HugeIcons.strokeRoundedDart,
                        color: currentRound.dart1 != null
                            ? BColors().primary
                            : null,
                      )
                    : BText(
                        currentRound.dart2 == 0
                            ? "Алдсан"
                            : currentRound.dart2!.toString(),

                        fontWeight: .w800,
                        textAlign: .center,
                      ),
              ),
              Expanded(
                child: currentRound.dart3 == null
                    ? HugeIcon(
                        icon: HugeIcons.strokeRoundedDart,
                        color:
                            currentRound.dart1 != null &&
                                currentRound.dart2 != null
                            ? BColors().primary
                            : null,
                      )
                    : BText(
                        currentRound.dart3 == 0
                            ? "Алдсан"
                            : currentRound.dart3!.toString(),
                        fontWeight: .w800,
                        textAlign: .center,
                      ),
              ),
            ],
          ),
        ),
        if (suggestDartsString(
          getUserPoint(game.users[currentUserIndex]).toInt(),
        ).isNotEmpty) ...[
          smallColumnSpacer,
          Center(
            child: MoonFilledButton(
              showPulseEffect: true,
              onTap: () {},
              leading: HugeIcon(icon: HugeIcons.strokeRoundedBulb),
              label: BText(
                suggestDartsString(
                  getUserPoint(game.users[currentUserIndex]).toInt(),
                ),
              ),
            ),
          ),
        ],
        Spacer(),
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: BCard(
                onTap: () {
                  setState(() {
                    dartType = .s;
                  });
                },
                color: dartType == .s ? BColors().primary : null,
                child: Center(child: BText("Single")),
              ).withHaptic(),
            ),
            Expanded(
              child: BCard(
                onTap: () {
                  setState(() {
                    dartType = dartType == .d ? .s : .d;
                  });
                },
                color: dartType == .d ? BColors().primary : null,
                child: Center(
                  child: BText(
                    "Double",
                    color: Colors.amber,
                  ),
                ),
              ).withHaptic(),
            ),
            Expanded(
              child: BCard(
                onTap: () {
                  setState(() {
                    dartType = dartType == .t ? .s : .t;
                  });
                },
                color: dartType == .t ? BColors().primary : null,
                child: Center(
                  child: BText(
                    "Triple",
                    color: Colors.deepOrange,
                  ),
                ),
              ).withHaptic(),
            ),
          ],
        ),
        smallColumnSpacer,
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: 21,
          itemBuilder: (context, index) {
            var number = index == 20 ? 25 : index + 1;
            bool isDisabled = number == 25 && dartType == .t;
            if (isDisabled) return Container();

            return BCard(
              onTap: () => onTapNumber(number),
              padding: .zero,
              child: Center(child: BText("$number")),
            ).withHaptic();
          },
        ),
        smallColumnSpacer,
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: BCard(
                onTap: onTapBack,
                color: game.rounds.isEmpty && currentRound.dart1 == null
                    ? null
                    : Colors.red,
                child: Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowLeft01,
                    strokeWidth: 5,
                  ),
                ),
              ).withHaptic(),
            ),
            Expanded(
              child: BCard(
                onTap: () => onTapNumber(0),
                child: Center(
                  child: BSubtitle(
                    "Miss",
                  ),
                ),
              ).withHaptic(),
            ),
            Expanded(
              child: BCard(
                onTap: onTapForward,
                color: Colors.deepOrange,
                child: Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowRightDouble,
                  ),
                ),
              ).withHaptic(),
            ),
          ],
        ),
        largeColumnSpacer,
      ],
    );
  }

  Widget landscape() {
    return Container();
  }
}
