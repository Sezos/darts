import 'package:darts/core/providers/settings/settings.provider.dart';
import 'package:darts/core/providers/user/user.provider.dart';
import 'package:darts/utils/colors.dart';
import 'package:darts/utils/interaction.dart';
import 'package:darts/utils/snackbar.dart';
import 'package:darts/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:moon_design/moon_design.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.text = ref.read(userProvider).name;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void save() {
    final name = controller.text.trim();
    if (name.isEmpty) {
      showSnackMsg("Нэрээ оруулна уу", context, type: SnackType.error);
      return;
    }
    ref.read(userProvider.notifier).updateUser(name: name);
    showSnackMsg("Нэр хадгалагдлаа", context, type: SnackType.success);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final name = ref.watch(userProvider).name;
    final settings = ref.watch(settingsProvider);
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: BColors().background,
      appBar: AppBar(
        backgroundColor: BColors().background,
        surfaceTintColor: Colors.transparent,
        title: BText("Тохиргоо", fontWeight: .w800, size: .l),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: BColors().border),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20,
                children: [
                  // Avatar
                  Center(
                    child: Column(
                      spacing: 10,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                BColors().primary,
                                BColors().primaryShade,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: BColors().primary.withAlpha(80),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Center(
                            child: BText(
                              initial,
                              color: BColors().background,
                              fontWeight: .w900,
                              size: .x3l,
                            ),
                          ),
                        ),
                        BText(name, fontWeight: .w700, size: .l),
                      ],
                    ),
                  ),

                  // Profile section
                  _SettingsCard(
                    icon: HugeIcons.strokeRoundedUser,
                    title: "Профайл",
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          BComment(
                            "Нэр",
                            color: BColors().textSecondary,
                            size: .s,
                          ),
                          MoonTextInput(
                            controller: controller,
                            hintText: "Нэрээ оруулна уу",
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => save(),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Game rules section
                  _SettingsCard(
                    icon: HugeIcons.strokeRoundedDart,
                    title: "Тоглоомын дүрэм",
                    children: [
                      _ToggleRow(
                        label: "Double-out шаардлагатай",
                        sublabel: "Дуусгахдаа double цохих ёстой",
                        value: settings.doubleOutRequired,
                        onChanged: (_) => ref
                            .read(settingsProvider.notifier)
                            .toggleDoubleOut(),
                      ),
                    ],
                  ),

                  // Audio & feedback section
                  _SettingsCard(
                    icon: HugeIcons.strokeRoundedVolumeHigh,
                    title: "Дуу & Мэдрэмж",
                    children: [
                      _ToggleRow(
                        label: "Дуу",
                        sublabel: "Цохилтын болон ялалтын дуу",
                        value: settings.soundEnabled,
                        onChanged: (_) =>
                            ref.read(settingsProvider.notifier).toggleSound(),
                      ),
                      Divider(height: 1, color: BColors().border),
                      _ToggleRow(
                        label: "Чичиргээ",
                        sublabel: "Товч дарах бүрт чичирнэ",
                        value: settings.hapticEnabled,
                        onChanged: (_) =>
                            ref.read(settingsProvider.notifier).toggleHaptic(),
                      ),
                    ],
                  ),

                  // Saves the name; the toggles above apply immediately.
                  PrimaryButton(label: "Нэр хадгалах", onTap: save),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.children,
  });
  final dynamic icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BColors().lighter,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BColors().border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              spacing: 8,
              children: [
                HugeIcon(icon: icon, color: BColors().primary, size: 16),
                BText(
                  title.toUpperCase(),
                  fontWeight: .w800,
                  size: .xs,
                  color: BColors().textSecondary,
                  letterSpacing: 1.5,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: BColors().border),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              spacing: 12,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.sublabel,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final String sublabel;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    // The whole row toggles, and reads as one switch to screen readers.
    return Semantics(
      toggled: value,
      label: "$label. $sublabel",
      excludeSemantics: true,
      onTap: () => onChanged(!value),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    BText(label, fontWeight: .w700),
                    BComment(
                      sublabel,
                      color: BColors().textSecondary,
                      size: .s,
                    ),
                  ],
                ),
              ),
              MoonSwitch(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}
