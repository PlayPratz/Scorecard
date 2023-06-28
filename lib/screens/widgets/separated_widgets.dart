import 'package:flutter/material.dart';
import 'package:scorecard/styles/color_styles.dart';

class SeparatedWidgetPair extends StatelessWidget {
  final Widget top;
  final Widget bottom;
  const SeparatedWidgetPair(
      {super.key, required this.top, required this.bottom});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: ColorStyles.highlight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: top,
          ),
          const Divider(thickness: 1),
          bottom,
        ],
      ),
    );
  }
}
