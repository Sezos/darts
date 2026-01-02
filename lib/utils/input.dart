import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import './constants.dart';
import './text_styles.dart';
import 'package:moon_design/moon_design.dart';

class RegoInput extends StatefulWidget {
  const RegoInput({this.controller, this.onChanged, super.key});

  final TextEditingController? controller;
  final void Function(String value)? onChanged;
  @override
  State<RegoInput> createState() => _RegoInputState();
}

class _RegoInputState extends State<RegoInput> {
  String rego1 = "", rego2 = "";

  final TextEditingController tempController = TextEditingController();
  final FocusNode regoFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    if ((widget.controller?.text.length ?? 0) > 0) {
      rego1 = widget.controller!.text[0];
    }

    if ((widget.controller?.text.length ?? 0) > 1) {
      rego2 = widget.controller!.text[0];
    }

    if ((widget.controller?.text.length ?? 0) > 2) {
      tempController.text = widget.controller!.text.substring(2);
    }

    setState(() {});

    tempController.addListener(setText);
  }

  void setText() {
    final text = rego1 + rego2 + tempController.text;
    widget.controller?.text = text;

    setState(() {});

    if (widget.onChanged != null) {
      widget.onChanged!(text);
    }
  }

  void showBottomSheet() {
    showMoonModalBottomSheet(
      context: context,
      height: MediaQuery.of(context).size.height * 0.5,
      builder: (context) {
        var index = 0;
        return StatefulBuilder(
          builder: (context, setState1) {
            return Padding(
              padding: EdgeInsets.all(8.0).copyWith(
                bottom: 8.0 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 12,
                    children: [
                      Hero(
                        tag: "rego1",
                        child: MoonOutlinedButton(
                          label: BText(rego1),
                          borderColor: index == 0
                              ? Theme.of(context).primaryColor
                              : MoonColors.light.beerus,
                          onTap: showBottomSheet,
                        ),
                      ),
                      Hero(
                        tag: "rego2",
                        child: MoonOutlinedButton(
                          label: BText(rego2),
                          borderColor: index == 1
                              ? Theme.of(context).primaryColor
                              : MoonColors.light.beerus,
                          onTap: showBottomSheet,
                        ),
                      ),
                    ],
                  ),
                  mediumColumnSpacer,
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: alphabets
                        .map(
                          (e) => MoonOutlinedButton(
                            label: BText(e),
                            borderColor: MoonColors.light.beerus,
                            onTap: () {
                              setState1(() {
                                if (index == 0) {
                                  rego1 = e;
                                  index++;
                                  setText();
                                } else {
                                  rego2 = e;
                                  setText();
                                  setState(() {});
                                  context.pop();
                                  regoFocus.requestFocus();
                                }
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        Hero(
          tag: "rego1",
          child: MoonOutlinedButton(
            label: BText(rego1),
            borderColor: MoonColors.light.beerus,
            onTap: showBottomSheet,
          ),
        ),

        Hero(
          tag: "rego2",
          child: MoonOutlinedButton(
            label: BText(rego2),
            borderColor: MoonColors.light.beerus,
            onTap: showBottomSheet,
          ),
        ),

        Expanded(
          child: MoonTextInput(
            controller: tempController,
            hintText: "Регистрийн дугаар",
            focusNode: regoFocus,
            keyboardType: TextInputType.numberWithOptions(),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
      ],
    );
  }
}

class PhoneInput extends StatelessWidget {
  const PhoneInput({required this.controller, super.key});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MoonButton(
          label: BText("🇲🇳 +976"),
          borderColor: MoonColors.light.beerus,
          showBorder: true,
          height: 50,
          borderRadius: .circular(100),
          backgroundColor: Colors.white,
          onTap: () {},
        ),
        smallRowSpacer,
        Expanded(
          child: MoonTextInput(
            controller: controller,
            hintText: "Утасны дугаар",
            height: 50,
            borderRadius: .circular(100),
          ),
        ),
      ],
    );
  }
}
