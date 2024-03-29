import 'package:flutter/material.dart';
import '../../models/team.dart';
import 'team_dummy_tile.dart';

class TeamTile extends StatelessWidget {
  final Team team;
  final void Function(Team)? onSelect;

  const TeamTile({Key? key, required this.team, this.onSelect})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    /* return ListTile(
      title: Text(team.name),
      subtitle: Text(team.shortName),
      leading: const Icon(Icons.people),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        if (onSelect != null) {
          onSelect!(team);
        }
      },
    ); */

    return InkWell(
      onTap: () {
        if (onSelect != null) {
          onSelect!(team);
        }
      },
      child: TeamDummyTile(
        primaryHint: team.name,
        secondaryHint: team.shortName,
        color: team.color,
      ),
    );
  }
}
