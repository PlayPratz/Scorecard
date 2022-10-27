import 'package:flutter/material.dart';

class BatterSelector extends StatefulWidget {
  const BatterSelector({Key? key}) : super(key: key);

  @override
  State<BatterSelector> createState() => _BatterSelectorState();
}

class _BatterSelectorState extends State<BatterSelector> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Select Batter"),
      ],
    );
  }
}
