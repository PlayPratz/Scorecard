import 'package:flutter/material.dart';
import 'package:scorecard/modules/team/team_model.dart';

class TeamListScreen extends StatelessWidget {
  const TeamListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class TeamTile extends StatelessWidget {
  final Team team;
  final void Function()? onSelect;
  const TeamTile(this.team, {super.key, this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isSelectable = onSelect != null;
    final color = Color(team.color);
    // final brightness = ThemeData.estimateBrightnessForColor(color);
    return Card(
      color: color.withOpacity(0.9),
      child: ListTile(
        leading: const Icon(Icons.groups),
        title: Text(team.name),
        trailing: isSelectable ? const Icon(Icons.chevron_right) : null,
        onTap: onSelect,
      ),
    );
  }
}
