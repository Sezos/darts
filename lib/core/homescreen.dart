import 'package:darts/core/providers/game/game.provider.dart';
import 'package:darts/utils/card.dart';
import 'package:darts/utils/colors.dart';
import 'package:darts/utils/constants.dart';
import 'package:darts/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:moon_design/moon_design.dart';

class Homescreen extends ConsumerStatefulWidget {
  const Homescreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomescreenState();
}

class _HomescreenState extends ConsumerState<Homescreen> {
  @override
  Widget build(BuildContext context) {
    var matches = ref.watch(historyProvider);

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/bg.png"),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: Container(),
          title: BText(
            "Дарцны оноо".toUpperCase(),
            color: const Color.fromARGB(255, 197, 183, 183),
            fontWeight: .w800,
            size: .l,
          ),
          actions: [
            Row(
              children: [
                MoonButton.icon(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedSettings01,
                  ),
                  onTap: () {
                    context.push("/settings");
                  },
                ),
                smallRowSpacer,
              ],
            ),
          ],
        ),
        body: Padding(
          padding: .all(16),
          child: Column(
            children: [
              largeColumnSpacer,
              Center(
                child: SizedBox(
                  width: 200,
                  child: Image.asset("assets/images/homescreen.png"),
                ),
              ),
              Spacer(),
              Row(
                spacing: 32,
                children: [
                  Expanded(
                    child: BCard(
                      borderColor: BColors().border,
                      child: Column(
                        children: [
                          BComment(
                            "Тоглосон тоо",
                            fontWeight: .w800,
                          ),
                          BTitle(matches.length.toString()),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: BCard(
                      borderColor: BColors().border,
                      child: Column(
                        children: [
                          BComment(
                            "Дундаж оноо",
                            fontWeight: .w800,
                          ),
                          BTitle(
                            ref.read(historyProvider.notifier).getAverage(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              largeColumnSpacer,
              Row(
                children: [
                  Expanded(
                    child: MoonFilledButton(
                      showPulseEffect: true,
                      buttonSize: .lg,
                      label: Row(
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedPlay,
                            strokeWidth: 3,
                            color: BColors().background,
                          ),
                          smallRowSpacer,
                          BText(
                            "Эхлэх",
                            color: BColors().background,
                            fontWeight: .w900,
                            size: .xl,
                          ),
                        ],
                      ),
                      onTap: () {
                        context.push("/players");
                      },
                    ).withHaptic(),
                  ),
                  smallRowSpacer,
                  MoonButton.icon(
                    backgroundColor: BColors().lighter,
                    borderColor: BColors().border,
                    showBorder: true,
                    buttonSize: .lg,
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedClock04,
                    ),
                    onTap: () {
                      context.push("/history");
                    },
                  ),
                ],
              ),
              bottomColumnSpacer,
            ],
          ),
        ),
      ),
    );
  }
}
