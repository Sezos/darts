import 'dart:math';

import 'package:darts/core/providers/game/game.provider.dart';
import 'package:darts/core/providers/players/players.provider.dart';
import 'package:darts/core/providers/user/user.provider.dart';
import 'package:darts/utils/card.dart';
import 'package:darts/utils/colors.dart';
import 'package:darts/utils/constants.dart';
import 'package:darts/utils/snackbar.dart';
import 'package:darts/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:moon_design/moon_design.dart';

class PlayersScreen extends ConsumerStatefulWidget {
  const PlayersScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends ConsumerState<PlayersScreen> {
  int startCount = 301;
  List<User> playersToPlay = [];
  bool isRandom = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      setState(() {
        playersToPlay.add(ref.read(userProvider));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var players = ref.watch(playersProvider);

    return Scaffold(
      appBar: AppBar(
        title: BSubtitle(
          "Тоглогч сонгох",
          fontWeight: .w800,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 8,
          crossAxisAlignment: .start,
          children: [
            BText(
              "Тоглоомын төрөл",
              fontWeight: .w900,
            ),
            BCard(
              child: Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: MoonButton(
                      showBorder: true,
                      label: BText("101"),
                      backgroundColor: startCount == 101
                          ? BColors().primary
                          : null,
                      onTap: () {
                        setState(() {
                          startCount = 101;
                        });
                      },
                    ).withHaptic(),
                  ),
                  Expanded(
                    child: MoonButton(
                      label: BText("301"),
                      showBorder: true,
                      backgroundColor: startCount == 301
                          ? BColors().primary
                          : null,
                      onTap: () {
                        setState(() {
                          startCount = 301;
                        });
                      },
                    ).withHaptic(),
                  ),
                  Expanded(
                    child: MoonButton(
                      label: BText("501"),
                      showBorder: true,
                      backgroundColor: startCount == 501
                          ? BColors().primary
                          : null,
                      onTap: () {
                        setState(() {
                          startCount = 501;
                        });
                      },
                    ).withHaptic(),
                  ),
                  Expanded(
                    child: MoonButton(
                      label: BText("701"),
                      showBorder: true,
                      backgroundColor: startCount == 701
                          ? BColors().primary
                          : null,
                      onTap: () {
                        setState(() {
                          startCount = 701;
                        });
                      },
                    ).withHaptic(),
                  ),
                ],
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: BText(
                    "Тоглогчид",
                    fontWeight: .w900,
                  ),
                ),
                BComment("Random эсэх"),
                smallRowSpacer,
                MoonSwitch(
                  value: isRandom,
                  onChanged: (value) {
                    setState(() {
                      isRandom = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(
              height: 100,
              child: ReorderableListView(
                buildDefaultDragHandles: false,
                scrollDirection: Axis.horizontal,
                children: playersToPlay
                    .map(
                      (e) => _buildCard(
                        e,
                        playersToPlay.indexOf(e),
                        key: Key(e.id.toString()),
                      ),
                    )
                    .toList(),
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = playersToPlay.removeAt(oldIndex);
                    playersToPlay.insert(newIndex, item);
                  });
                },
              ),
            ),
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                BText(
                  "Бүх тоглогчид",
                  fontWeight: .w900,
                ),
                MoonTextButton(
                  label: BText("Тоглогч нэмэх"),
                  onTap: () {
                    showMoonModalBottomSheet(
                      context: context,
                      backgroundColor: BColors().background,
                      builder: (context) {
                        final nameController = TextEditingController();

                        return Material(
                          color: Colors.transparent,
                          child: Padding(
                            padding: EdgeInsets.all(16.0).copyWith(
                              bottom:
                                  16.0 +
                                  MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 12,
                              children: [
                                TextField(
                                  controller: nameController,
                                  decoration: InputDecoration(
                                    hintText: "Нэр",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                MoonFilledButton(
                                  label: BText("Хадгалах"),
                                  isFullWidth: true,
                                  onTap: () {
                                    if (nameController.text.isNotEmpty) {
                                      ref
                                          .read(playersProvider.notifier)
                                          .addPlayer(
                                            User(
                                              id: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              name: nameController.text,
                                            ),
                                          );
                                      context.pop();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  var player = players[index];
                  bool contains = playersToPlay.any((e) => e.id == player.id);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      spacing: 4,
                      children: [
                        Expanded(
                          child: BCard(
                            color: contains ? BColors().primary : null,
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              setState(() {
                                if (contains) {
                                  playersToPlay.removeWhere(
                                    (e) => e.id == player.id,
                                  );
                                } else {
                                  if (playersToPlay.length >= 5) {
                                    showSnackMsg(
                                      "Ихдээ 5 тоглогч байна",
                                      context,
                                    );
                                    return;
                                  }
                                  playersToPlay.add(player);
                                }
                              });
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  child: BText(
                                    player.name,
                                    color: contains
                                        ? BColors().background
                                        : null,
                                    fontWeight: .w800,
                                  ),
                                ),
                                HugeIcon(
                                  icon: contains
                                      ? HugeIcons.strokeRoundedRemoveCircle
                                      : HugeIcons.strokeRoundedAddCircle,
                                  color: contains
                                      ? Colors.red
                                      : BColors().primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (player.id != ref.watch(userProvider).id)
                          GestureDetector(
                            onTap: () {
                              showMoonModalBottomSheet(
                                context: context,
                                backgroundColor: BColors().background,
                                builder: (context) {
                                  final nameController = TextEditingController(
                                    text: player.name,
                                  );

                                  return Material(
                                    color: Colors.transparent,
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0).copyWith(
                                        bottom:
                                            16.0 +
                                            MediaQuery.of(
                                              context,
                                            ).viewInsets.bottom,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        spacing: 12,
                                        children: [
                                          TextField(
                                            controller: nameController,
                                            decoration: InputDecoration(
                                              hintText: "Нэр",
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          MoonFilledButton(
                                            label: BText("Хадгалах"),
                                            isFullWidth: true,
                                            onTap: () {
                                              if (nameController
                                                  .text
                                                  .isNotEmpty) {
                                                ref
                                                    .read(
                                                      playersProvider.notifier,
                                                    )
                                                    .updatePlayer(
                                                      player.copyWith(
                                                        name:
                                                            nameController.text,
                                                      ),
                                                    );
                                                setState(() {
                                                  final index = playersToPlay
                                                      .indexWhere(
                                                        (p) =>
                                                            p.id == player.id,
                                                      );
                                                  if (index != -1) {
                                                    playersToPlay[index] =
                                                        player.copyWith(
                                                          name: nameController
                                                              .text,
                                                        );
                                                  }
                                                });
                                                context.pop();
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedPencilEdit02,
                              color: BColors().primary,
                            ),
                          ),
                        if (player.id != ref.watch(userProvider).id)
                          GestureDetector(
                            onTap: () {
                              showDialogPro(
                                "Тоглогч устгах",
                                "Тоглогчийг устгахуу?",
                                context,
                                btnOkColor: Colors.red,
                                btnOkText: "Устгах",
                                onOkButton: () {
                                  ref
                                      .read(playersProvider.notifier)
                                      .deletePlayer(player.id);
                                  setState(() {
                                    playersToPlay.removeWhere(
                                      (p) => p.id == player.id,
                                    );
                                  });
                                  context.pop();
                                },
                              );
                            },
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedDelete01,
                              color: Colors.red,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            MoonFilledButton(
              label: BText("Эхлэх"),
              isFullWidth: true,
              onTap: playersToPlay.isEmpty
                  ? null
                  : () {
                      context.push(
                        '/game',
                        extra: Game(
                          date: DateTime.now(),
                          startFrom: startCount,
                          users: isRandom
                              ? secureShuffled(playersToPlay)
                              : playersToPlay,
                          rounds: [],
                        ),
                      );
                    },
            ),
            largeColumnSpacer,
          ],
        ),
      ),
    );
  }

  Widget _buildCard(User user, int index, {required Key key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ReorderableDragStartListener(
        index: index,
        enabled: !isRandom,
        child: BCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // drag handle
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: BColors().primary,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: BColors().background,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Spacer(),
                BText(
                  user.name,
                  fontWeight: .w800,
                  maxLine: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<T> secureShuffled<T>(List<T> input) {
  final copy = List<T>.from(input);
  final rnd = Random.secure();
  for (int i = copy.length - 1; i > 0; i--) {
    final j = rnd.nextInt(i + 1);
    final tmp = copy[i];
    copy[i] = copy[j];
    copy[j] = tmp;
  }
  return copy;
}
