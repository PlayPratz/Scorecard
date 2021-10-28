import 'package:flutter/material.dart';
import 'package:scorecard/models/team.dart';

class TeamTile extends StatelessWidget {
  final Team team;

  const TeamTile({Key? key, required this.team}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(team.name),
      subtitle: Text(team.shortName),
      leading: const Icon(Icons.people),
      // trailing: const Icon(Icons.chevron_right),
    );
  }
}
