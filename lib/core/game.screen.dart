import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:darts/core/helper/darts.helper.dart';
import 'package:darts/core/providers/game/game.provider.dart';
import 'package:darts/core/providers/settings/settings.provider.dart';
import 'package:darts/core/providers/user/user.provider.dart';
import 'package:darts/utils/analytics.dart';
import 'package:darts/utils/colors.dart';
import 'package:darts/utils/format.dart';
import 'package:darts/utils/rating.dart';
import 'package:darts/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:just_audio/just_audio.dart';
import 'package:moon_design/moon_design.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen(this.game, {super.key});
  final Game game;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GameScreenState();
}

enum DartType { s, d, t }

extension DartTypeToNumber on DartType {
  int getNumber() => switch (this) { .s => 1, .d => 2, .t => 3 };
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

  // Bust animation
  int? _bustPlayerId;
  Timer? _bustTimer;

  // Confetti
  late ConfettiController _confettiController;

  final click = AudioPlayer();
  final win = AudioPlayer();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    WakelockPlus.enable();
    click.setUrl("asset:assets/sounds/click.wav");
    win.setUrl("asset:assets/sounds/win.wav");
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    setState(() {
      game = widget.game;
      currentRound = Round(user: widget.game.users.first);
    });

    Analytics.gameStarted(
      gameType: widget.game.startFrom,
      playerCount: widget.game.users.length,
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    WakelockPlus.disable();
    win.dispose();
    click.dispose();
    _confettiController.dispose();
    _bustTimer?.cancel();
    super.dispose();
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  void _playClick() {
    if (ref.read(settingsProvider).soundEnabled) {
      click.seek(Duration.zero).then((_) => click.play());
    }
  }

  void _playWin() {
    if (ref.read(settingsProvider).soundEnabled) {
      win.seek(Duration.zero).then((_) => win.play());
    }
  }

  void _haptic(HapticType type) {
    if (!ref.read(settingsProvider).hapticEnabled) return;
    switch (type) {
      case HapticType.light:
        HapticFeedback.lightImpact();
      case HapticType.medium:
        HapticFeedback.mediumImpact();
      case HapticType.heavy:
        HapticFeedback.heavyImpact();
    }
  }

  void _triggerBust(User player) {
    _bustTimer?.cancel();
    setState(() => _bustPlayerId = player.id);
    _bustTimer = Timer(
      const Duration(milliseconds: 650),
      () {
        if (mounted) setState(() => _bustPlayerId = null);
      },
    );
    _haptic(HapticType.heavy);
    Analytics.bust();
  }

  // ─── Game logic ───────────────────────────────────────────────────────────

  num getUserPoint(User player) {
    return game.startFrom -
        game.rounds
            .where((e) => e.user == player)
            .map((e) => (e.dart1 ?? 0) + (e.dart2 ?? 0) + (e.dart3 ?? 0))
            .fold(0, (v, e) => v + e) -
        (currentRound.user == player
            ? (currentRound.dart1 ?? 0) +
                  (currentRound.dart2 ?? 0) +
                  (currentRound.dart3 ?? 0)
            : 0);
  }

  void _nextPlayer() {
    game.rounds.add(currentRound);
    currentUserIndex = ((currentUserIndex + 1) % game.users.length).toInt();
    currentRound = Round(user: game.users[currentUserIndex]);
    setState(() => dartType = .s);
  }

  void onTapNumber(int number, [DartType? thrownDartType]) async {
    _haptic(HapticType.medium);
    final type = thrownDartType ?? dartType;
    _playClick();

    final player = game.users[currentUserIndex];
    int remaining = getUserPoint(player).toInt();

    if (remaining <= 1) {
      currentRound.dart1 ??= 0;
      currentRound.dart2 ??= 0;
      currentRound.dart3 ??= 0;
      _nextPlayer();
      return;
    }

    final int dartScore = number * type.getNumber();
    if (currentRound.dart1 == null) {
      currentRound.dart1 = dartScore;
    } else if (currentRound.dart2 == null) {
      currentRound.dart2 = dartScore;
    } else {
      currentRound.dart3 = dartScore;
    }

    remaining = getUserPoint(player).toInt();
    final settings = ref.read(settingsProvider);
    final bool isDoubleFinish =
        remaining == 0 && (!settings.doubleOutRequired || type.getNumber() == 2);
    final bool bust = remaining < 0 ||
        remaining == 1 ||
        (remaining == 0 && !isDoubleFinish);

    if (bust) {
      _triggerBust(player);
      currentRound
        ..dart1 = 0
        ..dart2 = 0
        ..dart3 = 0;
      await Future.delayed(const Duration(milliseconds: 400));
      _nextPlayer();
      return;
    }

    if (remaining == 0 && isDoubleFinish) {
      _playWin();
      _confettiController.play();

      final currentUser = ref.read(userProvider);
      final winner = game.users[currentUserIndex];
      Analytics.gameCompleted(
        gameType: game.startFrom,
        roundsPlayed: game.rounds.length,
        currentUserWon: winner.id == currentUser.id,
      );
      RatingService.onGameCompleted();

      showMoonGameFinishedDialog(
        winnerName: game.users[currentUserIndex].name,
        finalScores: game.users
            .map((u) => _FinalScore(u.name, getUserPoint(u).toInt()))
            .toList(),
        onNewGame: () {
          _nextPlayer();
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
          _nextPlayer();
          ref.read(historyProvider.notifier).addGame(game);
          context.go("/");
        },
      );
      return;
    }

    if (currentRound.dart1 != null &&
        currentRound.dart2 != null &&
        currentRound.dart3 != null) {
      _nextPlayer();
      return;
    }
    setState(() => dartType = .s);
  }

  void onTapBack() {
    _haptic(HapticType.medium);
    if (currentRound.dart3 != null) {
      currentRound.dart3 = null;
    } else if (currentRound.dart2 != null) {
      currentRound.dart2 = null;
    } else if (currentRound.dart1 != null) {
      currentRound.dart1 = null;
    } else {
      if (game.rounds.isEmpty) return;
      currentRound = game.rounds.last;
      currentUserIndex = game.users.indexOf(currentRound.user);
      game.rounds.removeLast();
    }
    setState(() => dartType = .s);
  }

  void onTapForward() {
    _playClick();
    currentRound.dart1 ??= 0;
    currentRound.dart2 ??= 0;
    currentRound.dart3 ??= 0;
    game.rounds.add(currentRound);
    currentUserIndex = ((currentUserIndex + 1) % game.users.length).toInt();
    currentRound = Round(user: game.users[currentUserIndex]);
    setState(() {});
  }

  // ─── Win dialog ───────────────────────────────────────────────────────────

  Future<void> showMoonGameFinishedDialog({
    required String winnerName,
    List<_FinalScore>? finalScores,
    VoidCallback? onNewGame,
    VoidCallback? onClose,
  }) {
    return showMoonModal<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => MoonModal(
        backgroundColor: BColors().surface,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Row(
                spacing: 10,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: BColors().gold.withAlpha(25),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.emoji_events,
                        color: BColors().gold,
                        size: 20,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BComment(
                        "Тоглолт дууслаа",
                        color: BColors().textSecondary,
                        size: .s,
                      ),
                      BText(
                        '$winnerName яллаа!',
                        fontWeight: .w900,
                        size: .l,
                        color: BColors().primary,
                      ),
                    ],
                  ),
                ],
              ),
              if (finalScores != null && finalScores.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: BColors().lighter,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: BColors().border),
                  ),
                  child: Column(
                    spacing: 6,
                    children: finalScores
                        .map(
                          (e) => Row(
                            mainAxisAlignment: .spaceBetween,
                            children: [
                              BComment(
                                e.name,
                                color: BColors().textSecondary,
                              ),
                              BText(
                                e.remaining.toString(),
                                fontWeight: .w800,
                                color: BColors().textPrimary,
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        context.pop();
                        onClose?.call();
                      },
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: BColors().lighter,
                          border: Border.all(color: BColors().border),
                        ),
                        child: Center(
                          child: BText("Дуусгах", fontWeight: .w700),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        context.pop();
                        onNewGame?.call();
                      },
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              BColors().primary,
                              const Color(0xFF00C278),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: BColors().primary.withAlpha(70),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: BText(
                            "Шинэ тоглолт",
                            color: BColors().background,
                            fontWeight: .w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: BColors().background,
      appBar: isPortrait ? _buildAppBar() : null,
      body: Stack(
        children: [
          GestureDetector(
            onHorizontalDragEnd: (details) {
              // Swipe right = undo
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! > 300) {
                onTapBack();
              }
            },
            child: isPortrait ? _portrait() : _landscape(),
          ),
          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              gravity: 0.15,
              colors: [
                BColors().primary,
                BColors().gold,
                BColors().orange,
                Colors.white,
                const Color(0xFF00C278),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: BColors().background,
      surfaceTintColor: Colors.transparent,
      title: Row(
        spacing: 8,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: BColors().primaryDim,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: BColors().primaryBorder),
            ),
            child: BText(
              "${game.startFrom}",
              color: BColors().primary,
              fontWeight: .w800,
              size: .s,
            ),
          ),
          BComment(
            formatDate(game.date),
            color: BColors().textSecondary,
            size: .s,
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: BColors().border),
      ),
    );
  }

  // ─── Portrait ─────────────────────────────────────────────────────────────

  Widget _portrait() {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final cardHeight = (screenHeight * 0.13).clamp(90.0, 130.0);
    final suggestion = suggestDartsString(
      getUserPoint(game.users[currentUserIndex]).toInt(),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Column(
        children: [
          // Player scorecards
          SizedBox(
            height: cardHeight,
            child: Row(
              spacing: 8,
              children: game.users.map((player) {
                final isCurr =
                    game.users.indexOf(player) == currentUserIndex;
                final isBusting = _bustPlayerId == player.id;
                final pt = getUserPoint(player);
                final rounds = game.rounds.where((e) => e.user == player);
                final ppr = rounds.isEmpty
                    ? "0.0"
                    : (rounds.fold(
                              0,
                              (v, e) =>
                                  v +
                                  (e.dart1 ?? 0) +
                                  (e.dart2 ?? 0) +
                                  (e.dart3 ?? 0),
                            ) /
                            rounds.length)
                        .toStringAsFixed(1);
                final lastRoundScore = game.rounds.isNotEmpty &&
                        game.rounds.last.user == player
                    ? (game.rounds.last.dart1 ?? 0) +
                        (game.rounds.last.dart2 ?? 0) +
                        (game.rounds.last.dart3 ?? 0)
                    : null;

                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: isBusting
                          ? LinearGradient(
                              colors: [
                                Colors.red.withAlpha(120),
                                Colors.red.withAlpha(60),
                              ],
                            )
                          : isCurr
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    BColors().primary,
                                    const Color(0xFF00B87A),
                                  ],
                                )
                              : null,
                      color: isBusting || isCurr ? null : BColors().lighter,
                      border: Border.all(
                        color: isBusting
                            ? Colors.red
                            : isCurr
                                ? BColors().primary
                                : BColors().border,
                        width: isBusting ? 2 : 1,
                      ),
                      boxShadow: isBusting
                          ? [
                              BoxShadow(
                                color: Colors.red.withAlpha(80),
                                blurRadius: 14,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : isCurr
                              ? [
                                  BoxShadow(
                                    color: BColors().primary.withAlpha(60),
                                    blurRadius: 14,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                BComment(
                                  player.name,
                                  color: isBusting
                                      ? Colors.white.withAlpha(200)
                                      : isCurr
                                          ? BColors().background.withAlpha(180)
                                          : BColors().textSecondary,
                                  size: .xs,
                                  maxLine: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                // Animated score number
                                BText(
                                  pt.toString(),
                                  color: isBusting
                                      ? Colors.white
                                      : isCurr
                                          ? BColors().background
                                          : BColors().textPrimary,
                                  fontWeight: .w900,
                                  size: .x3l,
                                )
                                    .animate(key: ValueKey('score_${player.id}_$pt'))
                                    .fadeIn(duration: 200.ms)
                                    .slideY(begin: -0.3, duration: 200.ms, curve: Curves.easeOut),
                                BComment(
                                  "PPR $ppr",
                                  color: isBusting
                                      ? Colors.white.withAlpha(160)
                                      : isCurr
                                          ? BColors().background.withAlpha(150)
                                          : BColors().textSecondary,
                                  size: .x2s,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isBusting)
                          Positioned.fill(
                            child: Center(
                              child: BText(
                                "BUST!",
                                color: Colors.white,
                                fontWeight: .w900,
                                size: .s,
                                letterSpacing: 2,
                              )
                                  .animate()
                                  .fadeIn(duration: 100.ms)
                                  .scale(begin: const Offset(0.6, 0.6), duration: 200.ms),
                            ),
                          ),
                        if (lastRoundScore != null && !isBusting)
                          Positioned(
                            top: 4,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: BColors().background.withAlpha(60),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: BText(
                                "+$lastRoundScore",
                                size: .x2s,
                                color: isCurr
                                    ? BColors().background
                                    : BColors().primary,
                                fontWeight: .w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Current throw display
          _ThrowDisplay(round: currentRound),

          const SizedBox(height: 6),

          // Checkout suggestion
          if (suggestion.isNotEmpty)
            Builder(builder: (_) {
              Analytics.checkoutSuggestionShown(
                score: getUserPoint(game.users[currentUserIndex]).toInt(),
              );
              return const SizedBox.shrink();
            }),
          if (suggestion.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: BColors().primaryDim,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: BColors().primaryBorder),
              ),
              child: Row(
                spacing: 8,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedBulb,
                    color: BColors().primary,
                    size: 16,
                  ),
                  Expanded(
                    child: BText(
                      suggestion,
                      color: BColors().primary,
                      size: .s,
                      fontWeight: .w700,
                    ),
                  ),
                ],
              ),
            ),

          const Spacer(),

          // Dart type selector
          _DartTypeSelector(
            selected: dartType,
            onSelect: (t) => setState(() => dartType = t),
          ),

          const SizedBox(height: 8),

          // Number grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
              childAspectRatio: 1,
            ),
            itemCount: 21,
            itemBuilder: (context, i) {
              final number = i == 20 ? 25 : i + 1;
              if (number == 25 && dartType == .t) return const SizedBox();
              return _NumberButton(
                number: number,
                dartType: dartType,
                onTap: () => onTapNumber(number),
              );
            },
          ),

          const SizedBox(height: 8),

          // Controls row
          _ControlsRow(
            canGoBack: !(game.rounds.isEmpty && currentRound.dart1 == null),
            onBack: onTapBack,
            onMiss: () => onTapNumber(0),
            onForward: onTapForward,
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
        ],
      ),
    );
  }

  // ─── Landscape ────────────────────────────────────────────────────────────

  Widget _landscape() {
    final mq = MediaQuery.of(context);
    final safeWidth =
        mq.size.width - mq.viewPadding.left - mq.viewPadding.right;
    final safeHeight = mq.size.height - mq.padding.top - mq.padding.bottom;
    final numbersHeight = safeHeight - 80 - 30;
    final numbersWidth = safeWidth - 80 - 75 - 32;

    return SafeArea(
      top: false,
      bottom: false,
      child: Column(
        children: [
          // Player row
          SizedBox(
            height: 80,
            child: Row(
              children: game.users.map((player) {
                final isCurr =
                    game.users.indexOf(player) == currentUserIndex;
                final isBusting = _bustPlayerId == player.id;
                final pt = getUserPoint(player);
                final rounds = game.rounds.where((e) => e.user == player);
                final ppr = rounds.isEmpty
                    ? "0.0"
                    : (rounds.fold(
                              0,
                              (v, e) =>
                                  v +
                                  (e.dart1 ?? 0) +
                                  (e.dart2 ?? 0) +
                                  (e.dart3 ?? 0),
                            ) /
                            rounds.length)
                        .toStringAsFixed(1);
                final lastScore = game.rounds.isNotEmpty &&
                        game.rounds.last.user == player
                    ? (game.rounds.last.dart1 ?? 0) +
                        (game.rounds.last.dart2 ?? 0) +
                        (game.rounds.last.dart3 ?? 0)
                    : null;

                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      gradient: isBusting
                          ? LinearGradient(
                              colors: [
                                Colors.red.withAlpha(120),
                                Colors.red.withAlpha(60),
                              ],
                            )
                          : isCurr
                              ? LinearGradient(
                                  colors: [
                                    BColors().primary,
                                    const Color(0xFF00B87A),
                                  ],
                                )
                              : null,
                      color: isBusting || isCurr ? null : BColors().lighter,
                      border: Border(
                        right: BorderSide(color: BColors().border),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              BComment(
                                player.name,
                                color: (isBusting || isCurr)
                                    ? BColors().background.withAlpha(180)
                                    : BColors().textSecondary,
                                size: .xs,
                                maxLine: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              BText(
                                isBusting ? "BUST!" : pt.toString(),
                                fontWeight: .w900,
                                size: .x2l,
                                color: (isBusting || isCurr)
                                    ? BColors().background
                                    : BColors().textPrimary,
                              )
                                  .animate(key: ValueKey('ls_${player.id}_$pt'))
                                  .fadeIn(duration: 180.ms)
                                  .slideY(begin: -0.3, duration: 180.ms),
                            ],
                          ),
                        ),
                        if (lastScore != null && !isBusting)
                          Positioned(
                            top: 4,
                            left: 6,
                            child: BComment(
                              "+$lastScore",
                              color: (isCurr)
                                  ? BColors().background.withAlpha(160)
                                  : BColors().primary,
                              size: .x2s,
                            ),
                          ),
                        Positioned(
                          top: 4,
                          right: 6,
                          child: BComment(
                            "PPR $ppr",
                            color: (isBusting || isCurr)
                                ? BColors().background.withAlpha(150)
                                : BColors().textSecondary,
                            size: .x2s,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Dart indicators
          Container(
            color: BColors().surface,
            child: Row(
              children: [
                Expanded(
                  child: _LandscapeDartCell(
                    value: currentRound.dart1,
                    isActive: currentRound.dart1 == null,
                  ),
                ),
                Expanded(
                  child: _LandscapeDartCell(
                    value: currentRound.dart2,
                    isActive: currentRound.dart1 != null &&
                        currentRound.dart2 == null,
                  ),
                ),
                Expanded(
                  child: _LandscapeDartCell(
                    value: currentRound.dart3,
                    isActive: currentRound.dart2 != null &&
                        currentRound.dart3 == null,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Row(
              children: [
                // Left: miss + bull
                SizedBox(
                  width: 75,
                  height: numbersHeight,
                  child: Column(
                    children: [
                      Expanded(
                        child: _LandscapeBtn(
                          label: "Miss",
                          onTap: () => onTapNumber(0),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: _LandscapeBtn(
                          label: "25",
                          sublabel: "Bull",
                          color: BColors().gold,
                          onTap: () => onTapNumber(25),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: _LandscapeBtn(
                          label: "50",
                          sublabel: "Bull",
                          color: BColors().orange,
                          onTap: () => onTapNumber(25, .d),
                        ),
                      ),
                    ],
                  ),
                ),
                // Center: S / D / T grids
                SizedBox(
                  width: numbersWidth,
                  height: numbersHeight,
                  child: Row(
                    children: [
                      Expanded(
                        child: _LandscapeNumberGrid(
                          height: numbersHeight,
                          width: numbersWidth / 3,
                          color: BColors().lighter,
                          onTap: (n) => onTapNumber(n, .s),
                          label: "S",
                        ),
                      ),
                      Expanded(
                        child: _LandscapeNumberGrid(
                          height: numbersHeight,
                          width: numbersWidth / 3,
                          color: BColors().gold.withAlpha(30),
                          borderColor: BColors().gold.withAlpha(60),
                          onTap: (n) => onTapNumber(n, .d),
                          label: "D",
                          labelColor: BColors().gold,
                        ),
                      ),
                      Expanded(
                        child: _LandscapeNumberGrid(
                          height: numbersHeight,
                          width: numbersWidth / 3,
                          color: BColors().orange.withAlpha(30),
                          borderColor: BColors().orange.withAlpha(60),
                          onTap: (n) => onTapNumber(n, .t),
                          label: "T",
                          labelColor: BColors().orange,
                        ),
                      ),
                    ],
                  ),
                ),
                // Right: back + next
                SizedBox(
                  width: 80,
                  child: Column(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: onTapBack,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red.withAlpha(40),
                              border:
                                  Border.all(color: Colors.red.withAlpha(60)),
                            ),
                            child: Center(
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedArrowLeft01,
                                color: Colors.red,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: GestureDetector(
                          onTap: onTapForward,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  BColors().primary,
                                  const Color(0xFF00B87A),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: BColors().primary.withAlpha(60),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  HugeIcon(
                                    icon: HugeIcons.strokeRoundedArrowRight01,
                                    color: BColors().background,
                                    size: 22,
                                  ),
                                  const SizedBox(height: 4),
                                  BText(
                                    "NEXT",
                                    color: BColors().background,
                                    fontWeight: .w900,
                                    size: .xs,
                                    letterSpacing: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Haptic type ──────────────────────────────────────────────────────────────

enum HapticType { light, medium, heavy }

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _ThrowDisplay extends StatelessWidget {
  const _ThrowDisplay({required this.round});
  final Round round;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: BColors().lighter,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BColors().border),
      ),
      child: Row(
        children: [
          _DartCell(value: round.dart1, isActive: round.dart1 == null),
          _Divider(),
          _DartCell(
            value: round.dart2,
            isActive: round.dart1 != null && round.dart2 == null,
          ),
          _Divider(),
          _DartCell(
            value: round.dart3,
            isActive: round.dart2 != null && round.dart3 == null,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      color: BColors().border,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class _DartCell extends StatelessWidget {
  const _DartCell({required this.value, required this.isActive});
  final int? value;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: value == null
            ? HugeIcon(
                icon: HugeIcons.strokeRoundedDart,
                color: isActive ? BColors().primary : BColors().border,
                size: 20,
              )
            : BText(
                value == 0 ? "Алдсан" : value!.toString(),
                fontWeight: .w800,
                size: .l,
                color: value == 0
                    ? Colors.red.withAlpha(180)
                    : BColors().textPrimary,
                textAlign: .center,
              )
                .animate(key: ValueKey(value))
                .fadeIn(duration: 150.ms)
                .scale(begin: const Offset(0.7, 0.7), duration: 150.ms),
      ),
    );
  }
}

class _DartTypeSelector extends StatelessWidget {
  const _DartTypeSelector({required this.selected, required this.onSelect});
  final DartType selected;
  final ValueChanged<DartType> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BColors().lighter,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BColors().border),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          _TypeBtn(
            label: "Single",
            isSelected: selected == .s,
            selectedColor: BColors().primary,
            onTap: () => onSelect(.s),
          ),
          _TypeBtn(
            label: "Double",
            isSelected: selected == .d,
            selectedColor: BColors().gold,
            onTap: () => onSelect(selected == .d ? .s : .d),
          ),
          _TypeBtn(
            label: "Triple",
            isSelected: selected == .t,
            selectedColor: BColors().orange,
            onTap: () => onSelect(selected == .t ? .s : .t),
          ),
        ],
      ),
    );
  }
}

class _TypeBtn extends StatelessWidget {
  const _TypeBtn({
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 34,
          decoration: BoxDecoration(
            color: isSelected ? selectedColor.withAlpha(30) : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            border:
                isSelected ? Border.all(color: selectedColor.withAlpha(100)) : null,
          ),
          child: Center(
            child: BText(
              label,
              fontWeight: .w700,
              size: .xs,
              color: isSelected ? selectedColor : BColors().textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _NumberButton extends StatelessWidget {
  const _NumberButton({
    required this.number,
    required this.dartType,
    required this.onTap,
  });
  final int number;
  final DartType dartType;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = dartType == .d
        ? BColors().gold
        : dartType == .t
            ? BColors().orange
            : BColors().textPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: BColors().lighter,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: BColors().border),
        ),
        child: Center(
          child: BText("$number", fontWeight: .w700, size: .s, color: accent),
        ),
      ),
    );
  }
}

class _ControlsRow extends StatelessWidget {
  const _ControlsRow({
    required this.canGoBack,
    required this.onBack,
    required this.onMiss,
    required this.onForward,
  });
  final bool canGoBack;
  final VoidCallback onBack;
  final VoidCallback onMiss;
  final VoidCallback onForward;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: _ControlBtn(
            color: canGoBack ? Colors.red.withAlpha(30) : BColors().lighter,
            borderColor:
                canGoBack ? Colors.red.withAlpha(80) : BColors().border,
            onTap: onBack,
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              color: canGoBack ? Colors.red : BColors().textSecondary,
              size: 20,
              strokeWidth: 2.5,
            ),
          ),
        ),
        Expanded(
          child: _ControlBtn(
            color: BColors().lighter,
            borderColor: BColors().border,
            onTap: onMiss,
            child: BText("Miss", fontWeight: .w700),
          ),
        ),
        Expanded(
          child: _ControlBtn(
            color: BColors().orange.withAlpha(30),
            borderColor: BColors().orange.withAlpha(80),
            onTap: onForward,
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRightDouble,
              color: BColors().orange,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}

class _ControlBtn extends StatelessWidget {
  const _ControlBtn({
    required this.color,
    required this.borderColor,
    required this.onTap,
    required this.child,
  });
  final Color color;
  final Color borderColor;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Center(child: child),
      ),
    );
  }
}

// Landscape helpers

class _LandscapeDartCell extends StatelessWidget {
  const _LandscapeDartCell({this.value, required this.isActive});
  final int? value;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: BColors().surface,
        border: Border(bottom: BorderSide(color: BColors().border)),
      ),
      child: Center(
        child: value == null
            ? HugeIcon(
                icon: HugeIcons.strokeRoundedDart,
                color: isActive ? BColors().primary : BColors().border,
                size: 14,
              )
            : BText(
                value == 0 ? "Алдсан" : value!.toString(),
                fontWeight: .w700,
                size: .s,
                color: value == 0
                    ? Colors.red.withAlpha(180)
                    : BColors().textPrimary,
                textAlign: .center,
              ),
      ),
    );
  }
}

class _LandscapeBtn extends StatelessWidget {
  const _LandscapeBtn({
    required this.label,
    required this.onTap,
    this.sublabel,
    this.color,
  });
  final String label;
  final String? sublabel;
  final Color? color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color?.withAlpha(25) ?? BColors().lighter,
          border: Border.all(
            color: color?.withAlpha(60) ?? BColors().border,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (sublabel != null)
                BComment(
                  sublabel!,
                  size: .x2s,
                  color: color ?? BColors().textSecondary,
                ),
              BText(
                label,
                fontWeight: .w800,
                size: .s,
                color: color ?? BColors().textPrimary,
                textAlign: .center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LandscapeNumberGrid extends StatelessWidget {
  const _LandscapeNumberGrid({
    required this.height,
    required this.width,
    required this.color,
    required this.onTap,
    required this.label,
    this.borderColor,
    this.labelColor,
  });
  final double height;
  final double width;
  final Color color;
  final Color? borderColor;
  final void Function(int) onTap;
  final String label;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: List.generate(20, (i) {
        final n = i + 1;
        return GestureDetector(
          onTap: () => onTap(n),
          child: Container(
            height: height / 5 - 2.8,
            width: width / 4 - 2,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(
                color: borderColor ?? BColors().border.withAlpha(80),
                width: 0.5,
              ),
            ),
            child: Center(
              child: BText(
                "$n",
                fontWeight: .w700,
                size: .xs,
                color: labelColor ?? BColors().textPrimary,
              ),
            ),
          ),
        );
      }),
    );
  }
}
