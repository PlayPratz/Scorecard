import 'package:flutter/material.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';
import 'package:scorecard/screens/cricket_game/cricket_game_screen.dart';

class PlayersInActionSection extends StatelessWidget {
  final CricketGameScreenController controller;

  const PlayersInActionSection(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final children = [
      _BattersInAction(controller.game.currentInnings, onSelect: onSelect),
    ];
    return Card();
  }
}

class _BattersInAction extends StatelessWidget {
  final Innings innings;
  final void Function(BatterInnings) onSelect;

  const _BattersInAction(
    this.innings, {
    super.key,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _BatterTile(innings.batter1,
            color: Color(innings.battingLineup.team.color),
            onSelect: () => onSelect),
        _BatterTile(innings.batter1,
            color: Color(innings.battingLineup.team.color),
            onSelect: () => onSelectBatter2())
      ],
    );
  }
}

class _BatterTile extends StatelessWidget {
  final BatterInnings? batterInnings;
  final Color color;
  final void Function() onSelect;
  const _BatterTile(
    this.batterInnings, {
    super.key,
    required this.color,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (batterInnings == null) {
      return ListTile(
        leading: const Icon(Icons.person),
        title: const Text("Please select Batter"),
        tileColor: color,
        onTap: onSelect,
      );
    }
    return ListTile(
      leading: const Icon(Icons.person),
      title: Row(
        children: [
          Text("${batterInnings!.runs}"),
          const SizedBox(width: 8),
          Text("(${batterInnings!.ballCount})",
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      subtitle: Text(batterInnings!.batter.name.toUpperCase()),
      tileColor: color,
      onTap: onSelect,
    );
  }
}

class _BowlerInAction extends StatelessWidget {
  final BowlerInnings? bowlerInnings;
  final Color color;
  const _BowlerInAction(this.bowlerInnings, {required this.color, super.key});

  @override
  Widget build(BuildContext context) {
    if (bowlerInnings == null) {
      return ListTile(
        leading: const Icon(Icons.person),
        title: const Text("Please select Bowler"),
        tileColor: color,
      );
    }
    return ListTile(
      title: Text("${bowlerInnings!.runs}-${bowlerInnings!.wicketCount}"),
      subtitle: Text(bowlerInnings!.bowler.name.toUpperCase()),
      tileColor: color,
    );
  }
}
