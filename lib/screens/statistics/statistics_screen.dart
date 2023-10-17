import 'package:flutter/material.dart';
import 'package:scorecard/screens/widgets/generic_item_tile.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GenericItemTile(
          primaryHint: "Coming soon!",
          trailing: null,
        ),
      ],
    );
  }
}
