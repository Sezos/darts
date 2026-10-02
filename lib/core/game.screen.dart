import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:darts/core/game/x01_engine.dart';
import 'package:darts/core/helper/darts.helper.dart';
import 'package:darts/core/providers/game/game.provider.dart';
import 'package:darts/core/providers/game/ongoing_game.provider.dart';
import 'package:darts/core/providers/settings/settings.provider.dart';
import 'package:darts/core/providers/user/user.provider.dart';
import 'package:darts/utils/analytics.dart';
import 'package:darts/utils/colors.dart';
import 'package:darts/utils/format.dart';
import 'package:darts/utils/interaction.dart';
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
  const GameScreen(this.game, {this.resumeRound, super.key});
  final Game game;

  /// The round in progress when a saved game is resumed.
  final Round? resumeRound;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GameScreenState();
}

extension on DartType {
  String get label => switch (this) {
    .s => "Single",
    .d => "Double",
    .t => "Triple",
  };

  Color get color => switch (this) {
    .s => BColors().textPrimary,
    .d => BColors().gold,
    .t => BColors().orange,
  };
}

class _FinalScore {
  final String name;
  final int remaining;
  const _FinalScore(this.name, this.remaining);
}

enum HapticType { light, medium, heavy }

class _GameScreenState extends ConsumerState<GameScreen> {
  late final X01Engine engine;
  DartType dartType = .s;

  // Bust: the round shows "BUST!" briefly, then play passes on.
  static const _bustHold = Duration(milliseconds: 650);
  Timer? _bustTimer;

  late final ConfettiController _confettiController;
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
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    final doubleOut = ref.read(settingsProvider).doubleOutRequired;
    final resume = widget.resumeRound;
    engine = resume == null
        ? X01Engine(widget.game, doubleOut: doubleOut)
        : X01Engine.resume(widget.game, resume, doubleOut: doubleOut);

    if (resume == null) {
      Analytics.gameStarted(
        gameType: widget.game.startFrom,
        playerCount: widget.game.users.length,
      );
    }
    _logSuggestionForTurn();
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

  // ─── Feedback ─────────────────────────────────────────────────────────────

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

  // ─── State plumbing ───────────────────────────────────────────────────────

  /// Saves the game so it can be resumed from the home screen.
  void _persist() {
    final ongoing = ref.read(ongoingGameProvider.notifier);
    if (engine.isFinished) return;
    if (engine.hasAnyThrow) {
      ongoing.save(engine.game, engine.current);
    } else {
      ongoing.clear();
    }
  }

  String _suggestionFor(int remaining) =>
      engine.doubleOut ? suggestDartsString(remaining) : '';

  /// Logs once per turn, when a player starts their round on a checkout.
  void _logSuggestionForTurn() {
    final remaining = engine.remaining(engine.player);
    if (_suggestionFor(remaining).isNotEmpty) {
      Analytics.checkoutSuggestionShown(score: remaining);
    }
  }

  void _cancelBust() {
    _bustTimer?.cancel();
    _bustTimer = null;
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  void onTapNumber(int number, [DartType? thrownDartType]) {
    final type = thrownDartType ?? dartType;
    engine.doubleOut = ref.read(settingsProvider).doubleOutRequired;
    final result = engine.throwDart(number, type);
    if (result == ThrowResult.ignored) return;

    _haptic(HapticType.medium);
    _playClick();

    switch (result) {
      case ThrowResult.scored:
        setState(() => dartType = .s);
      case ThrowResult.turnOver:
        setState(() => dartType = .s);
        _logSuggestionForTurn();
      case ThrowResult.bust:
        _haptic(HapticType.heavy);
        Analytics.bust();
        setState(() => dartType = .s);
        _bustTimer = Timer(_bustHold, () {
          if (!mounted) return;
          setState(engine.endTurn);
          _persist();
          _logSuggestionForTurn();
        });
      case ThrowResult.win:
        setState(() => dartType = .s);
        _onWin();
        return;
      case ThrowResult.ignored:
        return;
    }
    _persist();
  }

  void onTapBack() {
    if (!engine.canUndo) return;
    _cancelBust();
    _haptic(HapticType.medium);
    setState(() {
      engine.undo();
      dartType = .s;
    });
    _persist();
  }

  void onTapForward() {
    if (engine.isFinished) return;
    _cancelBust();
    _playClick();
    setState(() {
      engine.endTurn();
      dartType = .s;
    });
    _persist();
    _logSuggestionForTurn();
  }

  void _onWin() {
    final game = engine.game;
    final winner = engine.player;

    // Save first: the dialog may never be answered if the app is closed.
    ref.read(historyProvider.notifier).addGame(game);
    ref.read(ongoingGameProvider.notifier).clear();

    _playWin();
    if (!context.reduceMotion) _confettiController.play();
    _haptic(HapticType.heavy);

    Analytics.gameCompleted(
      gameType: game.startFrom,
      roundsPlayed: game.rounds.length,
      currentUserWon: winner.id == ref.read(userProvider).id,
    );
    RatingService.onGameCompleted();

    showGameFinishedDialog(
      winnerName: winner.name,
      finalScores: game.users
          .map((u) => _FinalScore(u.name, engine.remaining(u)))
          .toList(),
      onNewGame: () => context.pushReplacement(
        "/game",
        extra: Game(
          startFrom: game.startFrom,
          date: DateTime.now(),
          users: X01Engine.rotatedForRematch(game.users),
        ),
      ),
      onClose: () => context.go("/"),
    );
  }

  // ─── Win dialog ───────────────────────────────────────────────────────────

  Future<void> showGameFinishedDialog({
    required String winnerName,
    required List<_FinalScore> finalScores,
    required VoidCallback onNewGame,
    required VoidCallback onClose,
  }) {
    return showMoonModal<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => MoonModal(
        backgroundColor: BColors().surface,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Semantics(
                header: true,
                liveRegion: true,
                child: Row(
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
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedChampion,
                          color: BColors().gold,
                          size: 20,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
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
                    ),
                  ],
                ),
              ),
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
                            Flexible(
                              child: BComment(
                                e.name,
                                color: BColors().textSecondary,
                                maxLine: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
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
              const SizedBox(height: 16),
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: "Дуусгах",
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                        onClose();
                      },
                    ),
                  ),
                  Expanded(
                    child: PrimaryButton(
                      label: "Дахин тоглох",
                      height: 48,
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                        onNewGame();
                      },
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

  _CardData _cardData(User player) {
    final last = engine.lastRound;
    return _CardData(
      name: player.name,
      remaining: engine.remaining(player),
      ppr: engine.ppr(player).toStringAsFixed(1),
      lastScore: last != null && last.user.id == player.id ? last.total : null,
      isCurrent: player.id == engine.player.id && !engine.isFinished,
      isBusting: engine.isBust && player.id == engine.player.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.orientationOf(context) == Orientation.portrait;

    return Scaffold(
      backgroundColor: BColors().background,
      appBar: isPortrait ? _buildAppBar() : null,
      body: Stack(
        children: [
          isPortrait ? _portrait() : _landscape(),
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
                BColors().textPrimary,
                BColors().primaryDeep,
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
              "${engine.game.startFrom}",
              color: BColors().primary,
              fontWeight: .w800,
              size: .s,
            ),
          ),
          Flexible(
            child: BComment(
              formatDate(engine.game.date),
              color: BColors().textSecondary,
              size: .s,
              maxLine: 1,
              overflow: TextOverflow.ellipsis,
            ),
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
    final size = MediaQuery.sizeOf(context);
    final cardHeight = (size.height * 0.13).clamp(90.0, 130.0);
    final suggestion = _suggestionFor(engine.remaining(engine.player));
    // Narrow phones (iPhone SE) get 5 columns so keys stay ≥44pt.
    final columns = size.width < 360 ? 5 : 7;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: Column(
            children: [
              SizedBox(
                height: cardHeight,
                child: Row(
                  spacing: 8,
                  children: [
                    for (final player in engine.game.users)
                      Expanded(child: _ScoreCard(_cardData(player))),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              _ThrowDisplay(round: engine.current),

              const SizedBox(height: 6),

              if (suggestion.isNotEmpty)
                Semantics(
                  label: "Дуусгах санал: $suggestion",
                  excludeSemantics: true,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
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
                ),

              const Spacer(),

              _DartTypeSelector(
                selected: dartType,
                onSelect: (t) => setState(() => dartType = t),
              ),

              const SizedBox(height: 8),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  childAspectRatio: columns == 5 ? 1.4 : 1,
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

              _ControlsRow(
                canGoBack: engine.canUndo,
                onBack: onTapBack,
                onMiss: () => onTapNumber(0),
                onForward: onTapForward,
              ),

              SizedBox(height: MediaQuery.paddingOf(context).bottom + 12),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Landscape ────────────────────────────────────────────────────────────

  Widget _landscape() {
    final width = MediaQuery.sizeOf(context).width;
    // Side columns give up width on small phones so the 12 number columns
    // stay as wide as possible.
    final side = width < 700 ? 64.0 : 80.0;

    return SafeArea(
      top: false,
      child: Column(
        children: [
          SizedBox(
            height: 72,
            child: Row(
              children: [
                for (final player in engine.game.users)
                  Expanded(
                    child: _ScoreCard(_cardData(player), compact: true),
                  ),
              ],
            ),
          ),

          Container(
            height: 32,
            decoration: BoxDecoration(
              color: BColors().surface,
              border: Border(bottom: BorderSide(color: BColors().border)),
            ),
            child: Row(
              children: [
                for (var i = 0; i < 3; i++)
                  Expanded(
                    child: _DartCell(
                      index: i,
                      round: engine.current,
                      compact: true,
                    ),
                  ),
              ],
            ),
          ),

          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: side,
                  child: Column(
                    children: [
                      Expanded(
                        child: _LandscapeKey(
                          semanticLabel: "Тоглолтоос гарах",
                          onTap: () => context.pop(),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedCancel01,
                            color: BColors().textSecondary,
                            size: 20,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _LandscapeKey(
                          onTap: () => onTapNumber(0),
                          child: _keyLabel("Алдсан"),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: _LandscapeKey(
                          color: BColors().gold,
                          semanticLabel: "Bull 25",
                          onTap: () => onTapNumber(25),
                          child: _keyLabel(
                            "25",
                            sublabel: "Bull",
                            color: BColors().gold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: _LandscapeKey(
                          color: BColors().orange,
                          semanticLabel: "Bull 50",
                          onTap: () => onTapNumber(25, .d),
                          child: _keyLabel(
                            "50",
                            sublabel: "Bull",
                            color: BColors().orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                for (final type in DartType.values)
                  Expanded(
                    child: _LandscapeNumberGrid(
                      type: type,
                      onTap: (n) => onTapNumber(n, type),
                    ),
                  ),
                SizedBox(
                  width: side,
                  child: Column(
                    children: [
                      Expanded(
                        child: _LandscapeKey(
                          color: engine.canUndo
                              ? BColors().danger
                              : BColors().textSecondary,
                          semanticLabel: "Сүүлийн шидэлтийг буцаах",
                          onTap: engine.canUndo ? onTapBack : null,
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowLeft01,
                            color: engine.canUndo
                                ? BColors().danger
                                : BColors().textSecondary,
                            size: 22,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Pressable(
                          semanticLabel: "Дараагийн тоглогч",
                          minSize: 0,
                          onTap: onTapForward,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  BColors().primary,
                                  BColors().primaryShade,
                                ],
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: 4,
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedArrowRight01,
                                  color: BColors().onPrimary,
                                  size: 22,
                                ),
                                BText(
                                  "ДАРААХ",
                                  color: BColors().onPrimary,
                                  fontWeight: .w900,
                                  size: .xs,
                                  letterSpacing: 1,
                                ),
                              ],
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

  Widget _keyLabel(String label, {String? sublabel, Color? color}) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (sublabel != null)
            BComment(
              sublabel,
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
    );
  }
}

// ─── Scorecard ──────────────────────────────────────────────────────────────

class _CardData {
  const _CardData({
    required this.name,
    required this.remaining,
    required this.ppr,
    required this.lastScore,
    required this.isCurrent,
    required this.isBusting,
  });
  final String name;
  final int remaining;
  final String ppr;
  final int? lastScore;
  final bool isCurrent;
  final bool isBusting;
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard(this.data, {this.compact = false});
  final _CardData data;

  /// Landscape strip: square edges, smaller score, PPR in the corner.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final reduce = context.reduceMotion;
    final busting = data.isBusting;
    final current = data.isCurrent;
    final filled = busting || current;
    final danger = BColors().danger;

    final fg = busting
        ? Colors.white
        : current
        ? BColors().onPrimary
        : BColors().textPrimary;
    final fgMuted = busting
        ? Colors.white.withAlpha(200)
        : current
        ? BColors().onPrimary.withAlpha(180)
        : BColors().textSecondary;

    final gradient = busting
        ? LinearGradient(colors: [danger.withAlpha(120), danger.withAlpha(60)])
        : current
        ? BColors().primaryGradientDiagonal
        : null;

    Widget score = BText(
      busting && compact ? "BUST!" : data.remaining.toString(),
      color: fg,
      fontWeight: .w900,
      size: compact ? .x2l : .x3l,
    );
    if (!reduce) {
      score = score
          .animate(key: ValueKey('score_${data.name}_${data.remaining}'))
          .fadeIn(duration: 200.ms)
          .slideY(begin: -0.3, duration: 200.ms, curve: Curves.easeOut);
    }

    final label =
        "${data.name}, ${data.remaining} оноо үлдсэн"
        "${current ? ', ээлж' : ''}${busting ? ', bust' : ''}";

    return Semantics(
      label: label,
      selected: current,
      liveRegion: current,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: reduce ? Duration.zero : const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: compact ? null : BorderRadius.circular(14),
          gradient: gradient,
          color: filled ? null : BColors().lighter,
          border: compact
              ? Border(right: BorderSide(color: BColors().border))
              : Border.all(
                  color: busting
                      ? danger
                      : current
                      ? BColors().primary
                      : BColors().border,
                  width: busting ? 2 : 1,
                ),
          boxShadow: filled && !compact
              ? [
                  BoxShadow(
                    color: (busting ? danger : BColors().primary).withAlpha(70),
                    blurRadius: 14,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 14, 4, 4),
              child: Center(
                // Scales down instead of clipping at large text sizes.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BComment(
                        data.name,
                        color: fgMuted,
                        size: .xs,
                        maxLine: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      score,
                      if (!compact)
                        BComment("PPR ${data.ppr}", color: fgMuted, size: .x2s),
                    ],
                  ),
                ),
              ),
            ),
            if (busting && !compact)
              Positioned.fill(
                child: Center(
                  child: _maybeAnimate(
                    reduce,
                    BText(
                      "BUST!",
                      color: Colors.white,
                      fontWeight: .w900,
                      size: .s,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            if (data.lastScore != null && !busting)
              Positioned(
                top: 4,
                left: 6,
                child: BText(
                  "+${data.lastScore}",
                  size: .x2s,
                  color: current ? BColors().onPrimary : BColors().primary,
                  fontWeight: .w700,
                ),
              ),
            if (compact)
              Positioned(
                top: 4,
                right: 6,
                child: BComment("PPR ${data.ppr}", color: fgMuted, size: .x2s),
              ),
          ],
        ),
      ),
    );
  }

  Widget _maybeAnimate(bool reduce, Widget child) => reduce
      ? child
      : child
            .animate()
            .fadeIn(duration: 100.ms)
            .scale(begin: const Offset(0.6, 0.6), duration: 200.ms);
}

// ─── Throw display ──────────────────────────────────────────────────────────

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
          Expanded(child: _DartCell(index: 0, round: round)),
          const _Divider(),
          Expanded(child: _DartCell(index: 1, round: round)),
          const _Divider(),
          Expanded(child: _DartCell(index: 2, round: round)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

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
  const _DartCell({
    required this.index,
    required this.round,
    this.compact = false,
  });
  final int index;
  final Round round;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final value = round.darts[index];
    final isActive = !round.bust && round.dartsThrown == index;
    final ordinal = "${index + 1}-р сум";

    if (value == null) {
      return Semantics(
        label: isActive ? "$ordinal, дараагийнх" : "$ordinal, шидээгүй",
        excludeSemantics: true,
        child: Center(
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedDart,
            color: isActive
                ? BColors().primary
                : BColors().textSecondary.withAlpha(90),
            size: compact ? 16 : 20,
          ),
        ),
      );
    }

    Widget text = BText(
      value == 0 ? "Алдсан" : value.toString(),
      fontWeight: compact ? .w700 : .w800,
      size: compact ? .s : .l,
      color: value == 0
          ? BColors().danger.withAlpha(200)
          : BColors().textPrimary,
      textAlign: .center,
    );
    if (!compact && !context.reduceMotion) {
      text = text
          .animate(key: ValueKey('dart_${index}_$value'))
          .fadeIn(duration: 150.ms)
          .scale(begin: const Offset(0.7, 0.7), duration: 150.ms);
    }
    return Semantics(
      label: "$ordinal: ${value == 0 ? 'алдсан' : value}",
      excludeSemantics: true,
      child: Center(
        child: FittedBox(fit: BoxFit.scaleDown, child: text),
      ),
    );
  }
}

// ─── Input ──────────────────────────────────────────────────────────────────

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
          for (final type in DartType.values)
            Expanded(
              child: _TypeBtn(
                type: type,
                isSelected: selected == type,
                // Tapping the active multiplier again returns to single.
                onTap: () => onSelect(
                  selected == type && type != .s ? .s : type,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TypeBtn extends StatelessWidget {
  const _TypeBtn({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });
  final DartType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = type == .s ? BColors().primary : type.color;
    return Pressable(
      onTap: onTap,
      selected: isSelected,
      child: AnimatedContainer(
        duration: context.reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 180),
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(30) : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          border: isSelected ? Border.all(color: color.withAlpha(100)) : null,
        ),
        child: Center(
          child: BText(
            type.label,
            fontWeight: .w700,
            size: .s,
            color: isSelected ? color : BColors().textSecondary,
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
    return Pressable(
      onTap: onTap,
      minSize: 0,
      semanticLabel: "${dartType.label} $number",
      child: Container(
        decoration: BoxDecoration(
          color: BColors().lighter,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: BColors().border),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: BText(
              "$number",
              fontWeight: .w700,
              size: .m,
              color: dartType.color,
            ),
          ),
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
    final danger = BColors().danger;
    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: _ControlBtn(
            semanticLabel: "Сүүлийн шидэлтийг буцаах",
            color: canGoBack ? danger.withAlpha(30) : BColors().lighter,
            borderColor: canGoBack ? danger.withAlpha(80) : BColors().border,
            onTap: canGoBack ? onBack : null,
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              color: canGoBack ? danger : BColors().textSecondary,
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
            child: BText("Алдсан", fontWeight: .w700),
          ),
        ),
        Expanded(
          child: _ControlBtn(
            semanticLabel: "Дараагийн тоглогч",
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
    this.semanticLabel,
  });
  final Color color;
  final Color borderColor;
  final VoidCallback? onTap;
  final Widget child;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: Container(
        height: 48,
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

// ─── Landscape input ────────────────────────────────────────────────────────

class _LandscapeKey extends StatelessWidget {
  const _LandscapeKey({
    required this.onTap,
    required this.child,
    this.color,
    this.semanticLabel,
  });
  final VoidCallback? onTap;
  final Widget child;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      minSize: 0,
      semanticLabel: semanticLabel,
      child: Container(
        decoration: BoxDecoration(
          color: color?.withAlpha(25) ?? BColors().lighter,
          border: Border.all(color: color?.withAlpha(60) ?? BColors().border),
        ),
        child: Center(child: child),
      ),
    );
  }
}

/// 20 keys for one multiplier, 4 across and 5 down, filling the space given.
class _LandscapeNumberGrid extends StatelessWidget {
  const _LandscapeNumberGrid({required this.type, required this.onTap});
  final DartType type;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final tint = type == .s ? null : type.color;
    final fill = tint?.withAlpha(30) ?? BColors().lighter;
    final border = tint?.withAlpha(60) ?? BColors().border.withAlpha(80);

    return Column(
      children: [
        for (var row = 0; row < 5; row++)
          Expanded(
            child: Row(
              children: [
                for (var col = 0; col < 4; col++)
                  Expanded(
                    child: Pressable(
                      minSize: 0,
                      semanticLabel: "${type.label} ${row * 4 + col + 1}",
                      onTap: () => onTap(row * 4 + col + 1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: fill,
                          border: Border.all(color: border, width: 0.5),
                        ),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: BText(
                              "${row * 4 + col + 1}",
                              fontWeight: .w700,
                              size: .s,
                              color: type.color,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
