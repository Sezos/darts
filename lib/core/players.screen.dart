import 'dart:math';

import 'package:darts/core/providers/game/game.provider.dart';
import 'package:darts/core/providers/players/players.provider.dart';
import 'package:darts/core/providers/user/user.provider.dart';
import 'package:darts/utils/colors.dart';
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
    final players = ref.watch(playersProvider);

    return Scaffold(
      backgroundColor: BColors().background,
      appBar: AppBar(
        backgroundColor: BColors().background,
        surfaceTintColor: Colors.transparent,
        title: BText(
          "Тоглогч сонгох",
          fontWeight: .w800,
          size: .l,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: BColors().border),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20,
                children: [
                  // ── Game mode ──────────────────────────────────────────
                  _Section(
                    label: "Тоглоомын төрөл",
                    child: _GameModeSelector(
                      selected: startCount,
                      onSelect: (v) => setState(() => startCount = v),
                    ),
                  ),

                  // ── Selected players ───────────────────────────────────
                  _Section(
                    label: "Эрэмбэ",
                    trailing: Row(
                      spacing: 8,
                      children: [
                        BComment(
                          "Random",
                          color: BColors().textSecondary,
                          size: .s,
                        ),
                        MoonSwitch(
                          value: isRandom,
                          onChanged: (v) => setState(() => isRandom = v),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      height: (MediaQuery.sizeOf(context).height * 0.12).clamp(
                        90.0,
                        120.0,
                      ),
                      child: playersToPlay.isEmpty
                          ? Center(
                              child: BComment(
                                "Тоглогч сонгоно уу",
                                color: BColors().textSecondary,
                              ),
                            )
                          : ReorderableListView(
                              buildDefaultDragHandles: false,
                              scrollDirection: Axis.horizontal,
                              onReorder: (oldIndex, newIndex) {
                                setState(() {
                                  if (newIndex > oldIndex) newIndex--;
                                  final item = playersToPlay.removeAt(oldIndex);
                                  playersToPlay.insert(newIndex, item);
                                });
                              },
                              children: playersToPlay
                                  .asMap()
                                  .entries
                                  .map(
                                    (e) => _SelectedPlayerCard(
                                      key: Key(e.value.id.toString()),
                                      user: e.value,
                                      index: e.key,
                                      isRandom: isRandom,
                                    ),
                                  )
                                  .toList(),
                            ),
                    ),
                  ),

                  // ── All players ────────────────────────────────────────
                  _Section(
                    label: "Бүх тоглогчид",
                    trailing: GestureDetector(
                      onTap: () => _showPlayerSheet(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: BColors().primaryDim,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: BColors().primaryBorder),
                        ),
                        child: Row(
                          spacing: 4,
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedUserAdd01,
                              color: BColors().primary,
                              size: 14,
                            ),
                            BText(
                              "Нэмэх",
                              color: BColors().primary,
                              size: .s,
                              fontWeight: .w700,
                            ),
                          ],
                        ),
                      ),
                    ),
                    child: Column(
                      spacing: 8,
                      children: players
                          .map(
                            (player) => _PlayerRow(
                              player: player,
                              isSelected: playersToPlay.any(
                                (e) => e.id == player.id,
                              ),
                              isCurrentUser:
                                  player.id == ref.watch(userProvider).id,
                              onToggle: () {
                                HapticFeedback.mediumImpact();
                                setState(() {
                                  final has = playersToPlay.any(
                                    (e) => e.id == player.id,
                                  );
                                  if (has) {
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
                              onEdit: () => _showEditSheet(context, player),
                              onDelete: () => showDialogPro(
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
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom start button ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: [
                _StartButton(
                  enabled: playersToPlay.isNotEmpty,
                  onTap: () => context.push(
                    '/game',
                    extra: Game(
                      date: DateTime.now(),
                      startFrom: startCount,
                      users: isRandom
                          ? secureShuffled(playersToPlay)
                          : playersToPlay,
                      rounds: [],
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPlayerSheet(BuildContext context) {
    final controller = TextEditingController();
    showMoonModalBottomSheet(
      context: context,
      backgroundColor: BColors().surface,
      builder: (ctx) => _PlayerSheet(
        title: "Тоглогч нэмэх",
        controller: controller,
        onSave: () {
          if (controller.text.isNotEmpty) {
            ref
                .read(playersProvider.notifier)
                .addPlayer(
                  User(
                    id: DateTime.now().millisecondsSinceEpoch,
                    name: controller.text,
                  ),
                );
            ctx.pop();
          }
        },
      ),
    );
  }

  void _showEditSheet(BuildContext context, User player) {
    final controller = TextEditingController(text: player.name);
    showMoonModalBottomSheet(
      context: context,
      backgroundColor: BColors().surface,
      builder: (ctx) => _PlayerSheet(
        title: "Тоглогч засах",
        controller: controller,
        onSave: () {
          if (controller.text.isNotEmpty) {
            ref
                .read(playersProvider.notifier)
                .updatePlayer(
                  player.copyWith(name: controller.text),
                );
            setState(() {
              final i = playersToPlay.indexWhere((p) => p.id == player.id);
              if (i != -1) {
                playersToPlay[i] = player.copyWith(name: controller.text);
              }
            });
            ctx.pop();
          }
        },
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({
    required this.label,
    required this.child,
    this.trailing,
  });
  final String label;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Row(
          children: [
            BText(
              label.toUpperCase(),
              fontWeight: .w800,
              size: .xs,
              color: BColors().textSecondary,
              letterSpacing: 1.5,
            ),
            if (trailing != null) ...[const Spacer(), trailing!],
          ],
        ),
        child,
      ],
    );
  }
}

class _GameModeSelector extends StatelessWidget {
  const _GameModeSelector({required this.selected, required this.onSelect});
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BColors().lighter,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BColors().border),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [101, 301, 501, 701].map((v) {
          final isSelected = selected == v;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onSelect(v);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? BColors().primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: BColors().primary.withAlpha(80),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: BText(
                    "$v",
                    fontWeight: .w800,
                    color: isSelected
                        ? BColors().background
                        : BColors().textSecondary,
                    size: .s,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SelectedPlayerCard extends StatelessWidget {
  const _SelectedPlayerCard({
    required super.key,
    required this.user,
    required this.index,
    required this.isRandom,
  });
  final User user;
  final int index;
  final bool isRandom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ReorderableDragStartListener(
        index: index,
        enabled: !isRandom,
        child: Container(
          width: 72,
          decoration: BoxDecoration(
            color: BColors().lighter,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: BColors().primaryBorder),
            boxShadow: [
              BoxShadow(
                color: BColors().primaryGlow.withAlpha(50),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 6,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: BColors().primary,
                ),
                child: Center(
                  child: BText(
                    '${index + 1}',
                    color: BColors().background,
                    fontWeight: .w800,
                    size: .s,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: BText(
                  user.name,
                  fontWeight: .w700,
                  size: .xs,
                  maxLine: 2,
                  textAlign: .center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({
    required this.player,
    required this.isSelected,
    required this.isCurrentUser,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });
  final User player;
  final bool isSelected;
  final bool isCurrentUser;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? BColors().primaryDim : BColors().lighter,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? BColors().primaryBorder : BColors().border,
          ),
        ),
        child: Row(
          spacing: 12,
          children: [
            // Avatar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? BColors().primary.withAlpha(30)
                    : BColors().elevated,
                border: Border.all(
                  color: isSelected ? BColors().primary : BColors().border,
                ),
              ),
              child: Center(
                child: BText(
                  player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                  color: isSelected
                      ? BColors().primary
                      : BColors().textSecondary,
                  fontWeight: .w800,
                  size: .s,
                ),
              ),
            ),
            Expanded(
              child: BText(
                player.name,
                fontWeight: .w700,
                color: isSelected ? BColors().primary : BColors().textPrimary,
              ),
            ),
            if (!isCurrentUser) ...[
              _IconBtn(
                icon: HugeIcons.strokeRoundedPencilEdit02,
                color: BColors().textSecondary,
                onTap: onEdit,
              ),
              _IconBtn(
                icon: HugeIcons.strokeRoundedDelete01,
                color: Colors.red.withAlpha(180),
                onTap: onDelete,
              ),
            ],
            HugeIcon(
              icon: isSelected
                  ? HugeIcons.strokeRoundedCheckmarkCircle01
                  : HugeIcons.strokeRoundedAddCircle,
              color: isSelected ? BColors().primary : BColors().border,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final dynamic icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: HugeIcon(icon: icon, color: color, size: 18),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.enabled, required this.onTap});
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: enabled
              ? LinearGradient(
                  colors: [BColors().primary, const Color(0xFF00C278)],
                )
              : null,
          color: enabled ? null : BColors().lighter,
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: BColors().primary.withAlpha(80),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
          border: enabled ? null : Border.all(color: BColors().border),
        ),
        child: Center(
          child: BText(
            "Эхлэх",
            color: enabled ? BColors().background : BColors().textSecondary,
            fontWeight: .w900,
            size: .l,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _PlayerSheet extends StatelessWidget {
  const _PlayerSheet({
    required this.title,
    required this.controller,
    required this.onSave,
  });
  final String title;
  final TextEditingController controller;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Row(
              children: [
                BText(title, fontWeight: .w800, size: .l),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedCancel01,
                    color: BColors().textSecondary,
                    size: 20,
                  ),
                ),
              ],
            ),
            MoonTextInput(
              controller: controller,
              hintText: "Нэр",
              autofocus: true,
            ),
            GestureDetector(
              onTap: onSave,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [BColors().primary, const Color(0xFF00C278)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: BColors().primary.withAlpha(80),
                      blurRadius: 16,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: BText(
                    "Хадгалах",
                    color: BColors().background,
                    fontWeight: .w800,
                  ),
                ),
              ),
            ),
          ],
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
