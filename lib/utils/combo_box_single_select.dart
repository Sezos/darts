import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import './text_styles.dart';

class ComboBoxOption {
  final String label;
  final dynamic value;
  final bool isDisabled;
  ComboBoxOption({
    required this.label,
    required this.value,
    this.isDisabled = false,
  });
}

class ComboboxSingleSelect extends StatefulWidget {
  const ComboboxSingleSelect({
    super.key,
    required this.options,
    this.onSelect,
    this.initialOption,
    this.hintText,
    this.noResultText,
    this.content,
    this.leading,
    this.textController,
    this.enabled = true,
    this.borderColorWhenEnabled,
    this.maxHeight = 200,
    this.validator,
  });

  final Widget? leading;
  final ComboBoxOption? initialOption;
  final TextEditingController? textController;
  final List<ComboBoxOption> options;
  final Function(dynamic value)? onSelect;
  final String? hintText, noResultText;
  final Widget? content;
  final bool enabled;
  final Color? borderColorWhenEnabled;
  final double maxHeight;
  final String? Function(String?)? validator;
  @override
  State<ComboboxSingleSelect> createState() => _ComboboxSingleSelectState();
}

class _ComboboxSingleSelectState extends State<ComboboxSingleSelect> {
  final FocusNode _focusNode = FocusNode();
  late TextEditingController _searchController;

  List<ComboBoxOption> _filteredOptionsList = [];
  ComboBoxOption? _selectedOption;

  bool _showDropdown = false;

  bool get _optionIsSelected =>
      _selectedOption?.label == _searchController.text;

  // String get _inputValue => _searchController.text.trim().toLowerCase();

  @override
  void initState() {
    super.initState();
    _searchController = widget.textController ?? TextEditingController();

    if (widget.initialOption != null) {
      _searchController.text = widget.initialOption!.label;
    }
  }

  void _performSearch() {
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      if (!_optionIsSelected && _selectedOption != null) _selectedOption = null;

      _filteredOptionsList = widget.options.toList();
      _showDropdown = !_showDropdown;
    });
    if (widget.onSelect != null) {
      widget.onSelect!(null);
    }
  }

  void _handleSelect(ComboBoxOption option) {
    setState(() {
      _showDropdown = false;
      _searchController.text = option.label;
      _selectedOption = option;
      _focusNode.unfocus();
    });
    if (widget.onSelect != null) widget.onSelect!(option.value);
  }

  void _showAllOptionsList() {
    setState(() {
      _filteredOptionsList = widget.options;
      _showDropdown = !_showDropdown;
    });
  }

  void _handleDropdownTapOutside() {
    setState(() {
      _showDropdown = false;
      if (!_optionIsSelected) _searchController.clear();
      _focusNode.unfocus();
    });
  }

  void _handleInputTapOutside() {
    if (_focusNode.hasFocus && !_showDropdown) {
      if (!_optionIsSelected) _searchController.clear();
      _focusNode.unfocus();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MoonDropdown(
        show: _showDropdown,
        constrainWidthToChild: true,
        onTapOutside: () => _handleDropdownTapOutside(),
        content: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: widget.maxHeight),
          child: _filteredOptionsList.isEmpty
              ? MoonMenuItem(
                  label: BText(widget.noResultText ?? 'No results found.'),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _filteredOptionsList.length,
                  itemBuilder: (BuildContext _, int index) {
                    if (index >= _filteredOptionsList.length) {
                      return const SizedBox.shrink();
                    }
                    final ComboBoxOption option = _filteredOptionsList[index];

                    return MoonMenuItem(
                      onTap: option.isDisabled
                          ? null
                          : () => _handleSelect(option),
                      label: BText(option.label),
                    );
                  },
                ),
        ),
        child: MoonFormTextInput(
          focusNode: _focusNode,
          inactiveBorderColor: widget.enabled
              ? widget.borderColorWhenEnabled
              : null,
          activeBorderColor: widget.enabled
              ? widget.borderColorWhenEnabled
              : null,
          hoverBorderColor: widget.enabled
              ? widget.borderColorWhenEnabled
              : null,
          hintText: widget.hintText ?? "Select single component",
          controller: _searchController,
          leading: widget.leading,
          enabled: widget.enabled,
          validator: widget.validator,
          readOnly: true,
          canRequestFocus: false,
          mouseCursor: MouseCursor.defer,
          onTap: widget.enabled ? () => _performSearch() : null,
          onTapOutside: (PointerDownEvent _) => _handleInputTapOutside(),
          onChanged: widget.enabled ? (String _) => _performSearch() : null,
          trailing: MoonButton.icon(
            buttonSize: MoonButtonSize.xs,
            hoverEffectColor: Colors.transparent,
            onTap: () => _showAllOptionsList(),
            icon: AnimatedRotation(
              duration: const Duration(milliseconds: 200),
              turns: _showDropdown ? -0.5 : 0,
              child: const Icon(MoonIcons.controls_chevron_down_16_light),
            ),
          ),
        ),
      ),
    );
  }
}
