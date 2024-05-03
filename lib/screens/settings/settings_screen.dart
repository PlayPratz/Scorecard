import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/screens/widgets/generic_item_tile.dart';
import 'package:scorecard/services/player_service.dart';
import 'package:scorecard/util/strings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GenericItemTile(
          leading: const Icon(Icons.people),
          primaryHint: Strings.exportAllPlayers,
          secondaryHint: Strings.exportAllPlayersHint,
          trailing: const Icon(Icons.ios_share),
          onSelect: () {
            context.read<PlayerService>().shareAll();
          },
        ),
        const GenericItemTile(
          leading: Icon(Icons.system_update),
          primaryHint: Strings.settingsAppVersion,
          secondaryHint: "v0.21.2beta",
          trailing: null,
        ),
      ],
    );
  }
}
