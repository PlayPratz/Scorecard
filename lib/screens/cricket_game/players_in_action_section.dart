import 'package:flutter/material.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';
import 'package:scorecard/modules/cricket_match/models/wicket_model.dart';
import 'package:scorecard/screens/cricket_game/cricket_game_screen.dart';

class PlayersInActionSection extends StatelessWidget {
  final CricketGameScreenState state;

  final bool isFirstTeamBatting;

  final void Function(BatterInnings batterInnings) onSetStrike;
  final void Function(BowlerInnings bowlerInnings, RetiredBowler retired)
      onRetireBowler;
  final void Function(BatterInnings batterInnings, RetiredBatter retired)
      onRetireBatter;
  final void Function() onPickBatter;
  final void Function() onPickBowler;

  const PlayersInActionSection(
    this.state, {
    super.key,
    required this.onSetStrike,
    required this.isFirstTeamBatting,
    required this.onRetireBowler,
    required this.onRetireBatter,
    required this.onPickBatter,
    required this.onPickBowler,
  });

  @override
  Widget build(BuildContext context) {
    final row = [
      Column(
        children: [
          _BatterTile(
            state.batter1,
            isOnStrike: state.striker == state.batter1,
            isOut: state.batter1 != null &&
                (state.batter1!.isOut || state.batter1!.isRetired),
            onSetStrike: onSetStrike,
            onRetireBatter: (b) => onRetireBatter, //TODO
            onPickBatter: onPickBatter,
          ),
          _BatterTile(
            state.batter2,
            isOnStrike: state.striker == state.batter2,
            isOut: state.batter2 != null &&
                (state.batter2!.isOut || state.batter2!.isRetired),
            onSetStrike: onSetStrike,
            onRetireBatter: (b) => onRetireBatter, //TODO
            onPickBatter: onPickBatter,
          ),
        ],
      ),
      Column(
        children: [
          _BowlerInAction(
            state.bowler,
            onPickBowler: onPickBowler,
            onRetireBowler: (b) => onRetireBowler, //TODO
          )
        ],
      ),
    ];
    return Card(
      child: Row(
        children: isFirstTeamBatting ? row : row.reversed.toList(),
      ),
    );
  }
}

class _BatterTile extends StatelessWidget {
  final BatterInnings? batterInnings;

  final bool isOnStrike;
  final bool isOut;

  // final Color color;
  final void Function(BatterInnings batterInnings) onSetStrike;
  final void Function(BatterInnings batterInnings) onRetireBatter;
  final void Function() onPickBatter;

  const _BatterTile(
    this.batterInnings, {
    super.key,
    required this.isOnStrike,
    required this.isOut,
    // required this.color,
    required this.onPickBatter,
    required this.onRetireBatter,
    required this.onSetStrike,
  });

  @override
  Widget build(BuildContext context) {
    if (batterInnings == null) {
      return ListTile(
        leading: const Icon(Icons.person),
        title: const Text("Pick Batter"),
        // tileColor: color,
        onTap: onPickBatter,
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
      subtitle: Text(batterInnings!.player.name.toUpperCase()),
      tileColor: isOut ? Colors.red.withOpacity(0.3) : null,
      onTap: () => onSetStrike(batterInnings!),
      onLongPress: () => onRetireBatter(batterInnings!),
      trailing: isOnStrike
          ? const Icon(Icons.chevron_left, color: Colors.greenAccent)
          : const SizedBox(),
    );
  }
}

class _BowlerInAction extends StatelessWidget {
  final BowlerInnings? bowlerInnings;

  // final Color color;
  final void Function(BowlerInnings bowlerInnings) onRetireBowler;
  final void Function() onPickBowler;

  const _BowlerInAction(
    this.bowlerInnings, {
    super.key,
    // required this.color,
    required this.onRetireBowler,
    required this.onPickBowler,
  });

  @override
  Widget build(BuildContext context) {
    if (bowlerInnings == null) {
      return ListTile(
        leading: const Icon(Icons.person),
        title: const Text("Pick Bowler"),
        onTap: onPickBowler,
        // tileColor: color,
      );
    }
    return ListTile(
      title:
          Text("${bowlerInnings!.runsConceded}-${bowlerInnings!.wicketCount}"),
      subtitle: Text(bowlerInnings!.player.name.toUpperCase()),
      onLongPress: () => onRetireBowler(bowlerInnings!),
      // tileColor: color,
    );
  }
}
