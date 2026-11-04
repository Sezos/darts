import 'package:darts/core/game/skill_rating.dart';
import 'package:darts/core/online/online.dart';
import 'package:darts/core/online/online.provider.dart';
import 'package:darts/core/rank_widgets.dart';
import 'package:darts/l10n/l10n.dart';
import 'package:darts/utils/analytics.dart';
import 'package:darts/utils/colors.dart';
import 'package:darts/utils/interaction.dart';
import 'package:darts/utils/snackbar.dart';
import 'package:darts/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:moon_design/moon_design.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

/// The owner's online card (friend code and QR), adding friends, and a
/// leaderboard of the owner and their friends.
class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  var mode = RatingMode.x01;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: BColors().background,
      appBar: AppBar(
        backgroundColor: BColors().background,
        surfaceTintColor: Colors.transparent,
        title: BText(l10n.friends, fontWeight: .w800, size: .l),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: BColors().border),
        ),
      ),
      body: SafeArea(
        child: !Online.available
            ? OnlineMessage(text: l10n.onlineUnavailable)
            : switch (ref.watch(myProfileProvider)) {
                AsyncData(:final value) => _content(value),
                AsyncError() => OnlineMessage(
                  text: l10n.onlineError,
                  onRetry: () => ref.invalidate(myProfileProvider),
                ),
                _ => Center(
                  child: CircularProgressIndicator(color: BColors().primary),
                ),
              },
      ),
    );
  }

  Widget _content(OnlineProfile me) {
    final l10n = context.l10n;
    final friends = ref.watch(friendsProvider);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myProfileProvider);
            await ref.read(myProfileProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _MyCard(me),
              const SizedBox(height: 24),
              BText(
                l10n.friendsLeaderboard.toUpperCase(),
                fontWeight: .w800,
                size: .xs,
                color: BColors().textSecondary,
                letterSpacing: 1.5,
              ),
              const SizedBox(height: 10),
              SegmentedPicker(
                options: {
                  RatingMode.x01: 'x01',
                  RatingMode.cricket: 'Cricket',
                },
                selected: mode,
                onSelect: (m) => setState(() => mode = m),
              ),
              const SizedBox(height: 12),
              ...switch (friends) {
                AsyncData(:final value) => _board(me, value),
                AsyncError() => [
                  OnlineMessage(
                    text: l10n.onlineError,
                    onRetry: () => ref.invalidate(friendsProvider),
                  ),
                ],
                _ => [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: BColors().primary,
                      ),
                    ),
                  ),
                ],
              },
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _board(OnlineProfile me, List<OnlineProfile> friends) {
    final l10n = context.l10n;
    final everyone = [me, ...friends];
    final ranked = everyone.where((p) => !p.rating(mode).isPlacement).toList()
      ..sort(
        (a, b) => b.rating(mode).value!.compareTo(a.rating(mode).value!),
      );
    final placement = everyone.where((p) => p.rating(mode).isPlacement);
    return [
      for (final (i, p) in ranked.indexed) _row(i + 1, p, me),
      for (final p in placement) _row(null, p, me),
      if (friends.isEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Column(
            spacing: 8,
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedUserGroup,
                color: BColors().textSecondary,
                size: 32,
              ),
              BText(l10n.friendsEmpty, fontWeight: .w700),
              BComment(
                l10n.friendsEmptyHint,
                color: BColors().textSecondary,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
    ];
  }

  Widget _row(int? position, OnlineProfile p, OnlineProfile me) {
    final isMe = p.uid == me.uid;
    return LeaderboardRow(
      position: position,
      name: isMe ? '${p.name} (${context.l10n.you})' : p.name,
      rating: p.rating(mode),
      highlight: isMe,
      onTap: () => context.push('/f/${p.code}'),
    );
  }
}

class _MyCard extends StatelessWidget {
  const _MyCard(this.me);
  final OnlineProfile me;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BColors().lighter,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BColors().primaryBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 14,
        children: [
          Row(
            spacing: 14,
            children: [
              Avatar(me.name, size: 48),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    BText(me.name, fontWeight: .w900, size: .l),
                    Semantics(
                      label: '${l10n.yourCode}: ${me.code.split('').join(' ')}',
                      excludeSemantics: true,
                      child: BComment(
                        '${l10n.yourCode}: ${Online.display(me.code)}',
                        color: BColors().textSecondary,
                        size: .s,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: SecondaryButton(
                  label: l10n.showQr,
                  onTap: () => showQrSheet(context, me),
                ),
              ),
              Expanded(
                child: PrimaryButton(
                  label: l10n.addFriend,
                  height: 48,
                  onTap: () => showAddFriendSheet(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A round initial in mint, like the stats screen's.
class Avatar extends StatelessWidget {
  const Avatar(this.name, {this.size = 48, super.key});
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: BColors().primaryGradientDiagonal,
        ),
        child: Center(
          child: BText(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            color: BColors().background,
            fontWeight: .w900,
            size: size >= 56 ? .x2l : .l,
          ),
        ),
      ),
    );
  }
}

/// Big QR of the owner's profile link, their code, and a share button.
Future<void> showQrSheet(BuildContext context, OnlineProfile me) {
  Analytics.qrShown();
  final l10n = context.l10n;
  final link = Online.linkFor(me.code);
  return showMoonModalBottomSheet<void>(
    context: context,
    backgroundColor: BColors().surface,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 14,
          children: [
            BText(l10n.qrTitle, fontWeight: .w900, size: .xl),
            Semantics(
              image: true,
              label: '${l10n.qrTitle}. ${l10n.yourCode}: ${me.code}',
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: QrImageView(
                  data: link,
                  size: 220,
                  backgroundColor: Colors.white,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: BColors().background,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: BColors().background,
                  ),
                ),
              ),
            ),
            BText(
              Online.display(me.code),
              fontWeight: .w900,
              size: .x3l,
              letterSpacing: 4,
            ),
            BComment(
              l10n.qrHint,
              color: BColors().textSecondary,
              textAlign: TextAlign.center,
            ),
            SecondaryButton(
              label: l10n.shareLink,
              onTap: () => SharePlus.instance.share(
                ShareParams(text: l10n.shareText(link)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Scan a QR, or type a code.
Future<void> showAddFriendSheet(BuildContext context) {
  final l10n = context.l10n;
  return showMoonModalBottomSheet<void>(
    context: context,
    backgroundColor: BColors().surface,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            BText(l10n.addFriend, fontWeight: .w900, size: .xl),
            PrimaryButton(
              label: l10n.scanQr,
              icon: HugeIcons.strokeRoundedQrCode,
              onTap: () {
                ctx.pop();
                context.push('/scan');
              },
            ),
            SecondaryButton(
              label: l10n.enterCode,
              onTap: () {
                ctx.pop();
                _showCodeSheet(context);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _showCodeSheet(BuildContext context) {
  final controller = TextEditingController();
  final l10n = context.l10n;
  void submit(BuildContext ctx) {
    final code = Online.parseCode(controller.text);
    if (code == null) {
      showSnackMsg(l10n.codeInvalid, ctx, type: SnackType.error);
      return;
    }
    Analytics.friendCodeEntered();
    ctx.pop();
    context.push('/f/$code');
  }

  return showMoonModalBottomSheet<void>(
    context: context,
    backgroundColor: BColors().surface,
    // MoonTextInput needs a Material ancestor, which sheets don't give it.
    builder: (ctx) => Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            BText(l10n.enterCode, fontWeight: .w900, size: .xl),
            MoonTextInput(
              controller: controller,
              hintText: l10n.codeHint,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.go,
              onSubmitted: (_) => submit(ctx),
            ),
            PrimaryButton(label: l10n.addFriend, onTap: () => submit(ctx)),
          ],
        ),
      ),
    ),
  ).whenComplete(controller.dispose);
}

/// A centred message, with a retry button when [onRetry] is given.
class OnlineMessage extends StatelessWidget {
  const OnlineMessage({required this.text, this.onRetry, super.key});
  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 14,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedWifiDisconnected01,
              color: BColors().textSecondary,
              size: 32,
            ),
            BComment(
              text,
              color: BColors().textSecondary,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null)
              SecondaryButton(label: context.l10n.retry, onTap: onRetry!),
          ],
        ),
      ),
    );
  }
}
