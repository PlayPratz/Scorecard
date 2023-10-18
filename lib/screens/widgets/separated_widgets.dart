import 'package:flutter/material.dart';

class SeparatedWidgetPair extends StatelessWidget {
  final Widget top;
  final Widget bottom;
  final Color? color;
  const SeparatedWidgetPair(
      {super.key, required this.top, required this.bottom, this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      // decoration: BoxDecoration(
      //   border: Border.all(color: ColorStyles.highlight),
      //   borderRadius: BorderRadius.circular(20),
      // ),
      color: color,
      child: Column(
        children: [
          top,
          const Divider(
            thickness: 2,
            height: 0,
            color: Colors.black12,
          ),
          bottom,
        ],
      ),
    );
  }
}
