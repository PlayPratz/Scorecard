import 'package:flutter/material.dart';
import '../../styles/colorstyles.dart';

class TeamDummyTile extends StatefulWidget {
  final String primaryHint;
  final String secondaryHint;
  final Function? onSelect;
  final bool isHomeTeam;
  // final Widget? teamIcon;

  const TeamDummyTile({
    Key? key,
    required this.primaryHint,
    required this.secondaryHint,
    this.onSelect,
    this.isHomeTeam = true,
  }) : super(key: key);

  @override
  State<TeamDummyTile> createState() => _TeamDummyTileState();
}

class _TeamDummyTileState extends State<TeamDummyTile> {
  @override
  Widget build(BuildContext context) {
    final teamDummyTile = ListTile(
      title: Text(widget.primaryHint),
      subtitle: Text(widget.secondaryHint),
      leading: Icon(
        Icons.people,
        color: widget.isHomeTeam ? ColorStyles.homeTeam : ColorStyles.awayTeam,
      ),
      trailing: const Icon(Icons.chevron_right),
    );

    if (widget.onSelect == null) {
      return teamDummyTile;
    }

    return InkWell(
        onTap: () {
          widget.onSelect!();
        },
        child: teamDummyTile);
  }
}
