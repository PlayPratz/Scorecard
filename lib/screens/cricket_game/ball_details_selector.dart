import 'package:flutter/material.dart';
import 'package:scorecard/ui/ball_colors.dart';

class BallDetailsSelector extends StatelessWidget {
  const BallDetailsSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [],
        )
      ],
    );
  }
}

class _RunSelectorSection extends StatelessWidget {
  const _RunSelectorSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RunSelector(0, isSelected: isSelected, onSelect: ()=> _onSelect(0),)
        _RunSelector(1, isSelected: isSelected, onSelect: ()=> _onSelect(1))
        _RunSelector(2, isSelected: isSelected, onSelect: ()=> _onSelect(2))
        _RunSelector(3, isSelected: isSelected, onSelect: ()=> _onSelect(3))
        _RunSelector(4, isSelected: isSelected, onSelect: ()=> _onSelect(4), color: BallColors.four)
        _RunSelector(5, isSelected: isSelected, onSelect: ()=> _onSelect(5))
        _RunSelector(6, isSelected: isSelected, onSelect: ()=> _onSelect(6), color: BallColors.six)
      ],
    );
  }

  void _onSelect(int x) {}
}

class _RunSelector extends StatelessWidget {
  final int runs;

  final bool isSelected;

  final void Function() onSelect;

  final Color? color;
  const _RunSelector(
    this.runs, {
    required this.isSelected,
    required this.onSelect,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return IconButton.filled(
          onPressed: onSelect, icon: Text(runs.toString()));
    }

    return IconButton.outlined(
        onPressed: onSelect, icon: Text(runs.toString()));
  }
}
