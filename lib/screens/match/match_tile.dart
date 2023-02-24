import 'package:flutter/material.dart';
import 'package:scorecard/models/team.dart';
import '../../models/cricket_match.dart';
import '../../models/innings.dart';
import '../../styles/color_styles.dart';
import '../../util/strings.dart';

class MatchTile extends StatelessWidget {
  final CricketMatch match;
  final void Function(CricketMatch match)? onSelectMatch;
  final void Function(CricketMatch match)? onLongPress;

  const MatchTile({
    required this.match,
    this.onSelectMatch,
    this.onLongPress,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        color: ColorStyles.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: InkWell(
        onTap: onSelectMatch != null ? () => onSelectMatch!(match) : null,
        onLongPress: onLongPress != null ? () => onLongPress!(match) : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Column(
            children: [
              _wMatchDetails(),
              Row(
                children: [
                  Expanded(
                    child: _InningsTile(
                      innings: match.homeInnings,
                      team: match.homeTeam,
                    ),
                  ),
                  Expanded(
                    child: _InningsTile(
                      innings: match.awayInnings,
                      team: match.awayTeam,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8)
            ],
          ),
        ),
      ),
    );
  }

  Widget _wMatchDetails() {
    String text = match.isSuperOver
        ? Strings.matchScreenSuperOver
        : match.maxOvers.toString() + Strings.scoreOvers;
    return Align(
      alignment: Alignment.centerRight,
      child: Text(text),
    );
  }
}

class _InningsTile extends StatelessWidget {
  final Innings? innings;
  final Team team;

  const _InningsTile({required this.innings, required this.team});

  @override
  Widget build(BuildContext context) {
    if (innings == null) {
      return ScoreTileInner(
          teamName: team.shortName, score: "YTB", color: team.color);
    }

    return ScoreTileInner(
      teamName: team.shortName,
      score: innings!.strScore,
      color: team.color,
      // useShortName: true,
    );
  }
}

class ScoreTile extends StatelessWidget {
  final Team team;
  final Innings battingInnings;
  final bool useShortName;

  const ScoreTile({
    super.key,
    required this.team,
    required this.battingInnings,
    this.useShortName = false,
  });

  @override
  Widget build(BuildContext context) {
    final score = team == battingInnings.battingTeam
        ? battingInnings.strScore
        : battingInnings.strOvers;
    final teamName = useShortName ? team.shortName : team.name;
    return ScoreTileInner(score: score, teamName: teamName, color: team.color);
  }
}

class ScoreTileInner extends StatelessWidget {
  final String teamName;
  final String score;
  final Color color;

  const ScoreTileInner({
    super.key,
    required this.teamName,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        height: 96,
        width: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color.withOpacity(0.8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              teamName,
              style: Theme.of(context).textTheme.titleSmall?.merge(
                    const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
            ),
            Text(
              score,
              style: Theme.of(context).textTheme.displaySmall,
            )
          ],
        ),
      ),
    );
  }
}
