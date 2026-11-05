import 'package:darts/core/game/skill_rating.dart';
import 'package:darts/core/online/friends.screen.dart';
import 'package:darts/core/online/online.dart';
import 'package:darts/core/online/online.provider.dart';
import 'package:darts/core/rank_widgets.dart';
import 'package:darts/core/tabs.dart';
import 'package:darts/l10n/l10n.dart';
import 'package:darts/utils/analytics.dart';
import 'package:darts/utils/colors.dart';
import 'package:darts/utils/dialogs.dart';
import 'package:darts/utils/interaction.dart';
import 'package:darts/utils/snackbar.dart';
import 'package:darts/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

/// A player's online profile, opened from a QR code, a link, a typed code or
/// the friends leaderboard. Shows their ranks and lets the owner add them.
class FriendProfileScreen extends ConsumerStatefulWidget {
  const FriendProfileScreen(this.code, {super.key});
  final String code;

  @override
  ConsumerState<FriendProfileScreen> createState() =>
      _FriendProfileScreenState();
}

class _FriendProfileScreenState extends ConsumerState<FriendProfileScreen> {
  var _busy = false;

  @override
  void initState() {
    super.initState();
    Analytics.friendProfileViewed();
  }

  Future<void> _add(OnlineProfile p) async {
    setState(() => _busy = true);
    try {
      await Online.addFriend(p.uid);
      Analytics.friendAdded();
      if (mounted) {
        showSnackMsg(
          context.l10n.friendAdded(p.name),
          context,
          type: SnackType.success,
        );
      }
    } catch (_) {
      if (mounted) {
        showSnackMsg(context.l10n.onlineError, context, type: SnackType.error);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove(OnlineProfile p) async {
    final l10n = context.l10n;
    final ok = await showConfirmDialog(
      context,
      title: l10n.removeFriendTitle(p.name),
      message: l10n.removeFriendMessage,
      confirmLabel: l10n.remove,
      destructive: true,
    );
    if (!ok) return;
    setState(() => _busy = true);
    try {
      await Online.removeFriend(p.uid);
      Analytics.friendRemoved();
    } catch (_) {
      if (mounted) {
        showSnackMsg(l10n.onlineError, context, type: SnackType.error);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final profile = Online.available
        ? ref.watch(profileByCodeProvider(widget.code))
        : null;
    return Scaffold(
      backgroundColor: BColors().background,
      appBar: AppBar(
        backgroundColor: BColors().background,
        surfaceTintColor: Colors.transparent,
        title: BText(l10n.profile, fontWeight: .w800, size: .l),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: BColors().border),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: switch (profile) {
          null => OnlineMessage(text: l10n.onlineUnavailable),
          AsyncData(value: null) => OnlineMessage(text: l10n.codeNotFound),
          AsyncData(:final value?) => _content(value),
          AsyncError() => OnlineMessage(
            text: l10n.onlineError,
            onRetry: () => ref.invalidate(profileByCodeProvider(widget.code)),
          ),
          _ => Center(
            child: CircularProgressIndicator(color: BColors().primary),
          ),
        },
      ),
    );
  }

  Widget _content(OnlineProfile p) {
    final l10n = context.l10n;
    final me = ref.watch(myProfileProvider).value;
    final friendIds = {
      for (final f in ref.watch(friendsProvider).value ?? const []) f.uid,
    };
    final isMe = me?.uid == p.uid;
    final isFriend = friendIds.contains(p.uid);
    final played = [
      for (final mode in RatingMode.values)
        if (p.rating(mode).games > 0) mode,
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView(
          padding: AppTabs.listPadding(context),
          children: [
            const SizedBox(height: 8),
            Center(child: Avatar(p.name, size: 72)),
            const SizedBox(height: 12),
            Center(
              child: BText(p.name, fontWeight: .w900, size: .x2l),
            ),
            Center(
              child: BComment(
                Online.display(p.code),
                color: BColors().textSecondary,
                size: .s,
              ),
            ),
            const SizedBox(height: 20),
            if (isMe)
              Center(
                child: BComment(l10n.isYou, color: BColors().textSecondary),
              )
            else if (isFriend)
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: l10n.added,
                      icon: HugeIcons.strokeRoundedUserCheck01,
                      onTap: null,
                    ),
                  ),
                  IconTile(
                    icon: HugeIcons.strokeRoundedUserRemove01,
                    label: l10n.removeFriend,
                    color: BColors().danger,
                    size: 52,
                    onTap: _busy ? null : () => _remove(p),
                  ),
                ],
              )
            else
              PrimaryButton(
                label: l10n.addFriend,
                icon: HugeIcons.strokeRoundedUserAdd01,
                onTap: _busy || me == null ? null : () => _add(p),
              ),
            const SizedBox(height: 20),
            if (played.isEmpty)
              Center(
                child: BComment(
                  l10n.ranksEmptyHint(placementGames),
                  color: BColors().textSecondary,
                  textAlign: TextAlign.center,
                ),
              ),
            for (final mode in played)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: RankCard(
                  p.rating(mode),
                  title: mode == RatingMode.x01 ? 'x01' : 'Cricket',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
