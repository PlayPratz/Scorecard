import 'package:flutter/material.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';
import 'package:scorecard/modules/cricket_match/models/wicket_model.dart';
import 'package:scorecard/screens/cricket_game/cricket_game_screen.dart';
import 'package:scorecard/ui/ball_colors.dart';
import 'package:scorecard/ui/stringify.dart';

class PlayersInActionSection extends StatelessWidget {
  final CricketGameScreenState state;

  final bool isFirstTeamBatting;

  final void Function(BatterInnings batterInnings)? onSetStrike;
  final void Function(BowlerInnings bowlerInnings) onRetireBowler;
  // final void Function(BatterInnings batterInnings, RetiredBatter retired)
  //     onRetireBatter;
  final void Function() onPickBatter;
  final void Function() onPickBowler;

  const PlayersInActionSection(
    this.state, {
    super.key,
    required this.onSetStrike,
    required this.isFirstTeamBatting,
    required this.onRetireBowler,
    // required this.onRetireBatter,
    required this.onPickBatter,
    required this.onPickBowler,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              children: isFirstTeamBatting ? row1 : row1.reversed.toList(),
            ),
            TableRow(
              children: isFirstTeamBatting ? row2 : row2.reversed.toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> get row1 => [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: _BatterTile(
            state.batter1,
            isOnStrike: state.striker == state.batter1,
            // isOut: state.batter1 != null &&
            //     (state.batter1!.isOut || state.batter1!.isRetired),
            onSetStrike: onSetStrike,
            // onRetireBatter: (b) => onRetireBatter,
            onPickBatter: onPickBatter,
          ),
        ),
        _BowlerInAction(
          state.bowler,
          onPickBowler: onPickBowler,
          onRetireBowler: (b) => onRetireBowler(b), //TODO
        ),
      ];

  List<Widget> get row2 => [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: _BatterTile(
            state.batter2,
            isOnStrike: state.striker == state.batter2,
            // isOut: state.batter2 != null &&
            //     (state.batter2!.isOut || state.batter2!.isRetired),
            onSetStrike: onSetStrike,
            // onRetireBatter: (b) => onRetireBatter, //TODO
            onPickBatter: onPickBatter,
          ),
        ),
        const _InfoTile(),
      ];
}

class _BatterTile extends StatelessWidget {
  final BatterInnings? batterInnings;

  // final Color? color;
  final bool isOnStrike;
  // final bool isOut;

  // final Color color;
  final void Function(BatterInnings batterInnings)? onSetStrike;
  // final void Function(BatterInnings batterInnings) onRetireBatter;
  final void Function() onPickBatter;

  const _BatterTile(
    this.batterInnings, {
    super.key,
    required this.isOnStrike,
    // required this.isOut,
    // required this.color,
    required this.onPickBatter,
    // required this.onRetireBatter,
    required this.onSetStrike,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      // side: const BorderSide(width: 0.5),
    );

    if (batterInnings == null) {
      return ListTile(
        leading: const Icon(Icons.sports_motorsports),
        title: const Text("Pick Batter"),
        subtitle: Text(
          "Tap to continue",
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.black54),
        ),
        // tileColor: color,
        // trailing: Icon(Icons.chevron_right),
        onTap: onPickBatter,
        shape: shape,
      );
    }
    return ListTile(
      leading: const Icon(Icons.sports_motorsports),
      title: Row(
        children: [
          Text("${batterInnings!.runs}"),
          const SizedBox(width: 4),
          Text("${batterInnings!.ballCount}",
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      subtitle: Text(
        batterInnings!.player.name.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      tileColor: color,
      onTap: onSetStrike == null ? null : () => onSetStrike!(batterInnings!),
      // onLongPress: () => onRetireBatter(batterInnings!),
      // trailing: isOnStrike
      //     ? const Icon(Icons.chevron_left, color: Colors.greenAccent)
      //     : const SizedBox(),
      shape: shape,
    );
  }

  bool get isOut =>
      batterInnings != null &&
      (batterInnings!.isOut || batterInnings!.isRetired);

  Color? get color => isOut
      ? BallColors.wicket
      : isOnStrike
          ? Colors.greenAccent
          : null;
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
        leading: const Icon(Icons.sports_baseball),
        title: const Text("Pick Bowler"),
        subtitle: Text(
          "Tap to continue",
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.black54),
        ),
        onTap: onPickBowler,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );
    }
    return ListTile(
      leading: const Icon(Icons.sports_baseball),
      title: Row(
        children: [
          Text("${bowlerInnings!.runsConceded}-${bowlerInnings!.wicketCount}"),
          const SizedBox(width: 6),
          Text(
              Stringify.ballCount(
                  bowlerInnings!.ballCount, bowlerInnings!.ballsPerOver),
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      subtitle: Text(
        bowlerInnings!.player.name.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onLongPress: () => onRetireBowler(bowlerInnings!),
      tileColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Color? get color =>
      (bowlerInnings != null && bowlerInnings!.posts.lastOrNull is BowlerRetire)
          ? BallColors.wicket
          : null;
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.info_outline, color: Colors.black54),
      title: Text("Tap a batter to set strike",
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.black54,
              )),
    );
  }
}
