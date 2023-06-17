import 'package:flutter/material.dart';
import 'package:scorecard/models/series.dart';
import 'package:scorecard/screens/widgets/generic_item_tile.dart';

class SeriesTile extends StatelessWidget {
  final Series series;
  final void Function()? onSelect;
  const SeriesTile({super.key, required this.series, this.onSelect});

  @override
  Widget build(BuildContext context) {
    return GenericItemTile(
        primaryHint: series.teams.map((team) => team.name).join(", "),
        secondaryHint: "Yay");
  }
}
