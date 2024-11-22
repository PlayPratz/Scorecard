import 'package:flutter/material.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';
import 'package:scorecard/modules/team/models/team_model.dart';
import 'package:scorecard/screens/cricket_game/cricket_game_screen.dart';

class LimitedOversScoreSection extends StatelessWidget {
  final LimitedOversScoreState state;

  const LimitedOversScoreSection(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BattingTeamTile(
                teamName: state.battingTeam.name,
                color: Color(state.battingTeam.color),
                runs: state.runs,
                wickets: state.wickets,
                isLeftAligned: state.isLeftTeamBatting,
              ),
              Center(
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: Text(
                    'v',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white),
                  ),
                ),
              ),
              _BowlingTeamTile(
                teamName: state.bowlingTeam.name,
                color: Color(state.bowlingTeam.color),
                currentIndex: state.currentIndex,
                totalOvers: state.oversToBowl,
                isLeftAligned: !state.isLeftTeamBatting,
              )
            ],
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Row(),
        )
      ],
    );
  }
}

sealed class LimitedOversScoreState {
  final int runs;
  final int wickets;

  final Team battingTeam;
  final Team bowlingTeam;

  final InningsIndex currentIndex;
  final int oversToBowl;

  final bool isLeftTeamBatting;

  LimitedOversScoreState({
    required this.runs,
    required this.wickets,
    required this.battingTeam,
    required this.bowlingTeam,
    required this.currentIndex,
    required this.oversToBowl,
    required this.isLeftTeamBatting,
  });

  // LimitedOversScoreState.fromGameScreenState(CricketGameScreenState state,
  //     {required this.isLeftTeamBatting})
  //     : battingTeam = state.battingTeam,
  //       bowlingTeam = state.bowlingTeam,
  //       currentIndex = state.latestPost.index,
  //       runs = state.runs,
  //       wickets = state.wickets,
  //       oversToBowl = state.rules.ovre;
}

class LimitedOversScoreFirstInningsState extends LimitedOversScoreState {
  LimitedOversScoreFirstInningsState({
    required super.runs,
    required super.wickets,
    required super.battingTeam,
    required super.bowlingTeam,
    required super.currentIndex,
    required super.oversToBowl,
    required super.isLeftTeamBatting,
  });
}

class LimitedOversScoreSecondInningsState extends LimitedOversScoreState {
  final int target;

  LimitedOversScoreSecondInningsState({
    required super.runs,
    required super.wickets,
    required super.battingTeam,
    required super.bowlingTeam,
    required super.currentIndex,
    required super.oversToBowl,
    required super.isLeftTeamBatting,
    required this.target,
  });
}

class _BattingTeamTile extends StatelessWidget {
  final String teamName;
  final int runs;
  final int wickets;

  final Color color;
  // final Innings innings;
  final bool isLeftAligned;

  const _BattingTeamTile({
    super.key,
    required this.teamName,
    required this.color,
    required this.runs,
    required this.wickets,
    required this.isLeftAligned,
  });

  @override
  Widget build(BuildContext context) {
    // final innings = game.currentInnings;
    return Column(
      mainAxisAlignment:
          isLeftAligned ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        Text(
          teamName.toUpperCase(),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Text(
          "$runs-$wickets",
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }
}

class _BowlingTeamTile extends StatelessWidget {
  final String teamName;
  final int totalOvers;

  final Color color;
  final InningsIndex currentIndex;

  final bool isLeftAligned;

  const _BowlingTeamTile({
    super.key,
    required this.teamName,
    required this.color,
    required this.currentIndex,
    required this.totalOvers,
    required this.isLeftAligned,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment:
          isLeftAligned ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        Text(
          teamName.toUpperCase(),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Text("Overs $currentIndex/$totalOvers"),
      ],
    );
  }
}

class _NumberBox extends StatelessWidget {
  final num number;
  final String label;

  const _NumberBox({
    super.key,
    required this.number,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        Text(
          number is int ? number.toString() : number.toStringAsPrecision(2),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall)
      ]),
    );
  }
}
