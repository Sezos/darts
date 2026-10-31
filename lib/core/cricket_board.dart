import 'dart:math';

import 'package:darts/core/game/cricket_engine.dart';
import 'package:darts/core/providers/user/user.provider.dart';
import 'package:darts/utils/colors.dart';
import 'package:darts/utils/cricket_strings.dart';
import 'package:darts/utils/interaction.dart';
import 'package:darts/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// The Cricket scoreboard: one row per number, one column of marks per
/// player, with each player's points on top.
///
/// Two players sit either side of the numbers, like a chalkboard by the
/// oche; with more, the numbers run down the left. The player on throw has
/// their column lit mint. Rows share the height they are given.
class CricketBoard extends StatelessWidget {
  const CricketBoard({required this.engine, this.compact = false, super.key});
  final CricketEngine engine;

  /// Landscape: a shorter header and smaller numbers.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final users = engine.game.users;
    // Left to right; null is the number column.
    final columns = users.length == 2
        ? <User?>[users[0], null, users[1]]
        : <User?>[null, ...users];
    final headerHeight = compact
        ? 64.0
        : (MediaQuery.sizeOf(context).height * 0.11).clamp(76.0, 108.0);

    return Column(
      children: [
        SizedBox(
          height: headerHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final user in columns)
                Expanded(
                  flex: _flex(user),
                  child: user == null
                      ? const SizedBox()
                      : _PlayerHeader(
                          name: user.name,
                          points: engine.points(user),
                          mpr: engine.mpr(user).toStringAsFixed(2),
                          isCurrent: _isCurrent(user),
                          compact: compact,
                        ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: BColors().lighter,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: BColors().border),
            ),
            child: Column(
              children: [
                for (final (i, target) in CricketEngine.targets.indexed)
                  Expanded(
                    child: Container(
                      decoration: i == CricketEngine.targets.length - 1
                          ? null
                          : BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: BColors().borderSubtle,
                                ),
                              ),
                            ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final user in columns)
                            Expanded(
                              flex: _flex(user),
                              child: user == null
                                  ? _NumberCell(
                                      target: target,
                                      dead: engine.isDead(target),
                                      compact: compact,
                                    )
                                  : _MarksCell(
                                      name: user.name,
                                      target: target,
                                      marks: engine.marks(user, target),
                                      dead: engine.isDead(target),
                                      isCurrent: _isCurrent(user),
                                    ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  int _flex(User? column) => column == null ? 2 : 3;

  bool _isCurrent(User user) =>
      !engine.isFinished && user.id == engine.player.id;
}

class _PlayerHeader extends StatelessWidget {
  const _PlayerHeader({
    required this.name,
    required this.points,
    required this.mpr,
    required this.isCurrent,
    required this.compact,
  });
  final String name;
  final int points;
  final String mpr;
  final bool isCurrent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final reduce = context.reduceMotion;
    final fg = isCurrent ? BColors().onPrimary : BColors().textPrimary;
    final fgMuted = isCurrent
        ? BColors().onPrimary.withAlpha(180)
        : BColors().textSecondary;

    Widget score = BText(
      '$points',
      color: fg,
      fontWeight: .w900,
      size: compact ? .x2l : .x3l,
    );
    if (!reduce) {
      score = score
          .animate(key: ValueKey('points_${name}_$points'))
          .fadeIn(duration: 200.ms)
          .slideY(begin: -0.3, duration: 200.ms, curve: Curves.easeOut);
    }

    return Semantics(
      label: CricketText.playerSemantics(name, points, turn: isCurrent),
      selected: isCurrent,
      liveRegion: isCurrent,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: AnimatedContainer(
          duration: reduce ? Duration.zero : const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: isCurrent ? BColors().primaryGradientDiagonal : null,
            color: isCurrent ? null : BColors().lighter,
            border: Border.all(
              color: isCurrent ? BColors().primary : BColors().border,
            ),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: BColors().primary.withAlpha(70),
                      blurRadius: 14,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          // Scales down instead of clipping at large text sizes.
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BComment(
                    name,
                    color: fgMuted,
                    size: .xs,
                    maxLine: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  score,
                  BComment(CricketText.mpr(mpr), color: fgMuted, size: .x2s),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NumberCell extends StatelessWidget {
  const _NumberCell({
    required this.target,
    required this.dead,
    required this.compact,
  });
  final int target;
  final bool dead;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = dead
        ? BColors().textSecondary.withAlpha(120)
        : BColors().textPrimary;
    return Semantics(
      label: dead
          ? CricketText.deadSemantics(target)
          : CricketText.targetLabel(target),
      excludeSemantics: true,
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: BText(
            CricketText.targetLabel(target),
            fontWeight: .w900,
            size: target == 25 ? (compact ? .s : .l) : (compact ? .l : .x2l),
            color: color,
            decoration: dead ? TextDecoration.lineThrough : null,
            decorationColor: color,
            decorationThickness: 2,
          ),
        ),
      ),
    );
  }
}

class _MarksCell extends StatelessWidget {
  const _MarksCell({
    required this.name,
    required this.target,
    required this.marks,
    required this.dead,
    required this.isCurrent,
  });
  final String name;
  final int target;
  final int marks;
  final bool dead;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final closed = marks >= CricketEngine.closingMarks;
    final color = dead
        ? BColors().textSecondary.withAlpha(140)
        : closed
        ? BColors().primary
        : BColors().textPrimary;

    return Semantics(
      label: CricketText.marksSemantics(name, target, marks),
      excludeSemantics: true,
      child: ColoredBox(
        color: isCurrent ? BColors().primaryDim : Colors.transparent,
        child: LayoutBuilder(
          builder: (context, box) {
            final side = (min(box.maxWidth, box.maxHeight) * 0.74).clamp(
              14.0,
              44.0,
            );
            Widget glyph = MarkGlyph(marks: marks, size: side, color: color);
            if (marks > 0 && !context.reduceMotion) {
              glyph = glyph
                  .animate(key: ValueKey('marks_${name}_${target}_$marks'))
                  .fadeIn(duration: 150.ms)
                  .scale(begin: const Offset(0.6, 0.6), duration: 150.ms);
            }
            return Center(child: glyph);
          },
        ),
      ),
    );
  }
}

/// Chalkboard marks: "/" for one, "X" for two, a circled X once closed.
class MarkGlyph extends StatelessWidget {
  const MarkGlyph({
    required this.marks,
    required this.size,
    required this.color,
    super.key,
  });
  final int marks;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: _MarkPainter(min(marks, CricketEngine.closingMarks), color),
  );
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter(this.marks, this.color);
  final int marks;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (marks == 0) return;
    final w = size.width;
    final stroke = max(2.0, w * 0.11);
    final paint = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // The circle needs room, so a closed X sits further in.
    final inset = marks >= 3 ? w * 0.3 : w * 0.16;
    canvas.drawLine(Offset(inset, w - inset), Offset(w - inset, inset), paint);
    if (marks >= 2) {
      canvas.drawLine(
        Offset(inset, inset),
        Offset(w - inset, w - inset),
        paint,
      );
    }
    if (marks >= 3) {
      canvas.drawCircle(Offset(w / 2, w / 2), (w - stroke) / 2, paint);
    }
  }

  @override
  bool shouldRepaint(_MarkPainter old) =>
      old.marks != marks || old.color != color;
}
