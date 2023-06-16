import 'package:flutter/material.dart';
import 'package:scorecard/screens/widgets/generic_item_tile.dart';
import 'package:scorecard/screens/widgets/item_list.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          StatisticsChip(
            primaryHint: "Batters",
            secondaryHint:
                "Statistics on batters like runs, strike rate and average.",
            color: Colors.red.withOpacity(0.7),
            leading: const Icon(Icons.sports_cricket),
          ),
          StatisticsChip(
              primaryHint: "Bowlers",
              secondaryHint:
                  "Statistics on batters like runs, strike rate and average.",
              color: Colors.blue.withOpacity(0.7),
              leading: const Icon(
                Icons.sports_baseball,
              )),
          StatisticsChip(
            primaryHint: "Fielders",
            secondaryHint:
                "Statistics on batters like runs, strike rate and average.",
            color: Colors.greenAccent.withOpacity(0.7),
            leading: Icon(Icons.run_circle),
          ),
        ],
      ),
    );
  }
}

class StatisticsChip extends StatelessWidget {
  final Color color;
  final String primaryHint;
  final String secondaryHint;
  final Widget leading;

  const StatisticsChip({
    super.key,
    required this.color,
    required this.primaryHint,
    required this.secondaryHint,
    required this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Chip(
          surfaceTintColor: color,
          label: Row(
            children: [
              leading,
              const SizedBox(width: 8),
              Text(primaryHint),
            ],
          )),

      // GenericItemTile(
      //   primaryHint: primaryHint,
      //   secondaryHint: secondaryHint,
      //   leading: leading,
      //   color: color,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(48),
      //   ),
      //   contentPadding: EdgeInsets.symmetric(vertical: 32, horizontal: 18),
      // ),
    );
  }
}
