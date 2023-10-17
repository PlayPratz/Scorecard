import 'package:flutter/material.dart';
import 'package:scorecard/screens/widgets/generic_item_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GenericItemTile(
          leading: Icon(Icons.system_update),
          primaryHint: "App Version",
          secondaryHint: "v0.20.0beta",
          trailing: null,
        ),
      ],
    );
  }
}
