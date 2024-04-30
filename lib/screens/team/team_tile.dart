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
    return InkWell(
      onTap: () {
        if (onSelect != null) {
          onSelect!(team);
        }
      },
      child: TeamDummyTile(
        primaryHint: team.name,
        secondaryHint: team.shortName,
        color: Color(team.color),
      ),
    );
  }
}
