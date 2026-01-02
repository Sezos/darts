import 'package:darts/core/providers/user/user.provider.dart';
import 'package:darts/utils/colors.dart';
import 'package:darts/utils/constants.dart';
import 'package:darts/utils/snackbar.dart';
import 'package:darts/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moon_design/moon_design.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  TextEditingController controller = TextEditingController(text: "Player 1");

  @override
  void initState() {
    super.initState();
    Future.microtask(getUser);
  }

  void getUser() {
    setState(() {
      controller.text = ref.watch(userProvider).name;
    });
  }

  void save() {
    if (controller.text.isEmpty) {
      showSnackMsg("Нэрээ оруулна уу", context, type: "errorPro");
      return;
    }

    ref.read(userProvider.notifier).updateUser(name: controller.text);
    showSnackMsg("Амжилттай хадгалагдлаа", context);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BSubtitle(
          "Тохиргоо",
          fontWeight: .w900,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 8,
            crossAxisAlignment: .start,
            children: [
              BText("Нэр"),
              MoonTextInput(
                hintText: "Нэр",
                controller: controller,
              ),
              largeColumnSpacer,
              MoonFilledButton(
                isFullWidth: true,
                label: BText(
                  "ХАДГАЛАХ",
                  fontWeight: .w800,
                  color: BColors().background,
                ),
                onTap: save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
